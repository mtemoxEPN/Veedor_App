class AppConstants {
  // Appwrite Project & DB
  static const String projectId = '6a3d88c70024b0b40bab';
  static const String databaseId = '6a3d8e8a003536d98c4a'; // DB principal
  
  // Por favor asegúrate de que el ID de tus colecciones en Appwrite sea exactamente este (o cámbialos aquí si Appwrite generó uno aleatorio)
  static const String usersCollectionId = 'users'; // Colección de usuarios
  static const String recintosCollectionId = 'recintos'; // Colección de recintos
  static const String mesasCollectionId = 'mesas'; // Colección de mesas
  static const String asignacionesCollectionId = 'asignaciones'; // Colección de asignaciones
  static const String actasCollectionId = 'actas'; // Colección de actas (Paso 6)
  static const String storageBucketId = 'actas-fotos';

  // Roles
  static const String rolProvincial = 'provincial';
  static const String rolRecinto = 'recinto';
  static const String rolVeedor = 'veedor';
}
