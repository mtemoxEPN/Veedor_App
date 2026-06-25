import 'package:appwrite/appwrite.dart';
import '../../../../core/config/appwrite_config.dart';
import '../../../../core/config/constants.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> login(String cedula, String password);
  Future<UserModel> getCurrentUser();
  Future<void> changePassword(String newPassword);
  Future<void> recoverPassword(String cedula);
  Future<void> logout();
}

class AppwriteAuthDataSource implements AuthRemoteDataSource {
  final AppwriteConfig appwriteConfig;

  AppwriteAuthDataSource(this.appwriteConfig);

  @override
  Future<UserModel> login(String cedula, String password) async {
    try {
      // 1. Buscar el correo real del usuario basado en la cédula
      final docs = await appwriteConfig.databases.listDocuments(
        databaseId: AppConstants.databaseId,
        collectionId: AppConstants.usersCollectionId,
        queries: [Query.equal('cedula', cedula.trim())],
      );

      if (docs.documents.isEmpty) {
        throw Exception('No se encontró ninguna cuenta con esa cédula.');
      }

      final email = docs.documents.first.data['correo'] as String?;
      if (email == null || email.isEmpty) {
        throw Exception('El usuario no tiene un correo válido registrado.');
      }

      // 2. Iniciar sesión con el correo real
      await appwriteConfig.account.createEmailPasswordSession(
        email: email,
        password: password.trim(),
      );
      return getCurrentUser();
    } on AppwriteException catch (e) {
      throw Exception(e.message ?? 'Error de autenticación');
    }
  }

  @override
  Future<UserModel> getCurrentUser() async {
    try {
      // Obtenemos los datos base de autenticación
      final accountData = await appwriteConfig.account.get();
      
      // Consultamos la colección de usuarios para obtener los datos extendidos (rol, nombres, etc)
      final userDoc = await appwriteConfig.databases.getDocument(
        databaseId: AppConstants.databaseId,
        collectionId: AppConstants.usersCollectionId,
        documentId: accountData.$id,
      );

      return UserModel.fromJson(userDoc.data);
    } on AppwriteException catch (e) {
      throw Exception(e.message ?? 'Error al obtener usuario actual');
    }
  }

  @override
  Future<void> changePassword(String newPassword) async {
    try {
      // 1. Cambiar la clave en Appwrite Auth
      await appwriteConfig.account.updatePassword(password: newPassword);
      
      // 2. Actualizar el flag en la base de datos
      final accountData = await appwriteConfig.account.get();
      await appwriteConfig.databases.updateDocument(
        databaseId: AppConstants.databaseId,
        collectionId: AppConstants.usersCollectionId,
        documentId: accountData.$id,
        data: {'requiresPasswordChange': false},
      );
    } on AppwriteException catch (e) {
      throw Exception(e.message ?? 'Error al cambiar la contraseña');
    }
  }

  @override
  Future<void> recoverPassword(String cedula) async {
    try {
      final docs = await appwriteConfig.databases.listDocuments(
        databaseId: AppConstants.databaseId,
        collectionId: AppConstants.usersCollectionId,
        queries: [Query.equal('cedula', cedula.trim())],
      );

      if (docs.documents.isEmpty) {
        throw Exception('No se encontró ninguna cuenta con esa cédula.');
      }

      final email = docs.documents.first.data['correo'] as String?;
      if (email == null || email.isEmpty) {
        throw Exception('El usuario no tiene un correo válido registrado para recuperar la contraseña.');
      }

      // Supabase / Appwrite native recovery
      await appwriteConfig.account.createRecovery(
        email: email,
        url: 'https://veedorapp.com/reset-password', // Dummy URL for the flow
      );
    } on AppwriteException catch (e) {
      throw Exception(e.message ?? 'Error al enviar correo de recuperación');
    }
  }

  @override
  Future<void> logout() async {
    try {
      await appwriteConfig.account.deleteSession(sessionId: 'current');
    } on AppwriteException catch (e) {
      throw Exception(e.message ?? 'Error al cerrar sesión');
    }
  }
}
