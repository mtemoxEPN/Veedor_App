import 'package:appwrite/appwrite.dart';
import '../../../../core/config/appwrite_config.dart';
import '../../../../core/config/constants.dart';
import '../models/mesa_model.dart';

abstract class RecintoRemoteDataSource {
  Future<List<MesaModel>> getMesasByRecinto(String recintoId);
  Future<MesaModel> createMesa({
    required String numeroMesa,
    required String recintoId,
  });
  Future<void> createVeedorMesa({
    required String cedula,
    required String nombres,
    required String apellidos,
    required String telefono,
    required String correo,
    required String mesaId,
    required String recintoId,
  });
}

class AppwriteRecintoDataSource implements RecintoRemoteDataSource {
  final AppwriteConfig appwriteConfig;

  AppwriteRecintoDataSource(this.appwriteConfig);

  @override
  Future<List<MesaModel>> getMesasByRecinto(String recintoId) async {
    try {
      final response = await appwriteConfig.databases.listDocuments(
        databaseId: AppConstants.databaseId,
        collectionId: AppConstants.mesasCollectionId,
        queries: [
          Query.equal('recintoId', recintoId),
        ],
      );
      return response.documents.map((doc) => MesaModel.fromJson(doc.data)).toList();
    } on AppwriteException catch (e) {
      throw Exception(e.message ?? 'Error al obtener mesas');
    }
  }

  @override
  Future<MesaModel> createMesa({
    required String numeroMesa,
    required String recintoId,
  }) async {
    try {
      final response = await appwriteConfig.databases.createDocument(
        databaseId: AppConstants.databaseId,
        collectionId: AppConstants.mesasCollectionId,
        documentId: ID.unique(),
        data: {
          'numeroMesa': numeroMesa,
          'recintoId': recintoId,
        },
      );
      return MesaModel.fromJson(response.data);
    } on AppwriteException catch (e) {
      throw Exception(e.message ?? 'Error al crear mesa');
    }
  }

  @override
  Future<void> createVeedorMesa({
    required String cedula,
    required String nombres,
    required String apellidos,
    required String telefono,
    required String correo,
    required String mesaId,
    required String recintoId,
  }) async {
    try {
      // 1. Crear el Auth de Appwrite
      final authResponse = await appwriteConfig.account.create(
        userId: ID.custom(cedula),
        email: correo,
        password: 'Ecuador2026',
        name: '\$nombres \$apellidos',
      );

      // 2. Crear el documento en la colección Users
      await appwriteConfig.databases.createDocument(
        databaseId: AppConstants.databaseId,
        collectionId: AppConstants.usersCollectionId,
        documentId: authResponse.$id,
        data: {
          'cedula': cedula,
          'nombres': nombres,
          'apellidos': apellidos,
          'telefono': telefono,
          'correo': correo,
          'rol': AppConstants.rolVeedor,
          'recintoId': recintoId,
          'requiresPasswordChange': true,
        },
      );

      // 3. Actualizar la Mesa para asignarle este veedor
      await appwriteConfig.databases.updateDocument(
        databaseId: AppConstants.databaseId,
        collectionId: AppConstants.mesasCollectionId,
        documentId: mesaId,
        data: {
          'veedorId': authResponse.$id,
        },
      );
    } on AppwriteException catch (e) {
      throw Exception(e.message ?? 'Error al crear veedor');
    }
  }
}
