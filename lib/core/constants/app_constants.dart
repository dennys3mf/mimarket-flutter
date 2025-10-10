/// Constantes de la aplicación
class AppConstants {
  // Roles de usuario
  static const String roleAdmin = 'admin';
  static const String roleEmployee = 'employee';
  
  // IDs de sucursales
  static const String storeSucursal1 = 'sucursal_1';
  static const String storeSucursal2 = 'sucursal_2';
  
  // Métodos de pago
  static const String paymentYape = 'yape';
  static const String paymentCash = 'efectivo';
  static const String paymentCard = 'tarjeta';
  
  // Colecciones de Firestore
  static const String usersCollection = 'users';
  static const String productsCollection = 'products';
  static const String salesCollection = 'sales';
  static const String inventoryTransfersCollection = 'inventoryTransfers';
  
  // Subcolecciones
  static const String soldItemsSubcollection = 'soldItems';
  static const String transferredItemsSubcollection = 'transferredItems';
  
  // Límites de rendimiento
  static const int scanToCartMaxMs = 500;
  static const int checkoutMaxMs = 2000;
  
  // Configuración de sincronización
  static const Duration syncRetryDelay = Duration(seconds: 5);
  static const int maxSyncRetries = 3;
}

