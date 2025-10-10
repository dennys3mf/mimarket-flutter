import 'package:mi_tienda_app/data/services/firestore_service.dart';
import 'package:mi_tienda_app/data/services/offline_sync_service.dart';
import 'package:mi_tienda_app/domain/entities/sale_entity.dart';
import 'package:mi_tienda_app/data/models/sale_model.dart';
import 'package:uuid/uuid.dart';

/// Repositorio de ventas
/// Gestiona el acceso a datos de ventas con soporte offline
class SaleRepository {
  final FirestoreService _firestoreService;
  final OfflineSyncService _offlineSyncService;

  SaleRepository(
    this._firestoreService,
    this._offlineSyncService,
  );

  /// Crear nueva venta
  /// Intenta guardar en Firebase, si falla guarda localmente
  Future<SaleEntity> createSale(SaleEntity sale) async {
    try {
      final saleModel = SaleModel.fromEntity(sale);
      
      // Verificar conexión
      final hasConnection = await _offlineSyncService.hasInternetConnection();
      
      if (hasConnection) {
        // Intentar guardar directamente en Firebase
        await _firestoreService.createSale(saleModel);
        return sale.copyWith(synced: true);
      } else {
        // Guardar localmente para sincronizar después
        await _offlineSyncService.savePendingSale(saleModel);
        return sale.copyWith(synced: false);
      }
    } catch (e) {
      // Si falla, guardar localmente
      try {
        final saleModel = SaleModel.fromEntity(sale);
        await _offlineSyncService.savePendingSale(saleModel);
        return sale.copyWith(synced: false);
      } catch (offlineError) {
        throw Exception('Error crítico al guardar venta: $offlineError');
      }
    }
  }

  /// Generar ID único para venta
  String generateSaleId() {
    return const Uuid().v4();
  }

  /// Obtener ventas de un día específico
  Future<List<SaleEntity>> getSalesByDate(
    DateTime date,
    String storeId,
  ) async {
    try {
      return await _firestoreService.getSalesByDate(date, storeId);
    } catch (e) {
      throw Exception('Error en repositorio al obtener ventas: $e');
    }
  }

  /// Stream de ventas del día actual
  Stream<List<SaleEntity>> getTodaySalesStream(String storeId) {
    return _firestoreService.getTodaySalesStream(storeId);
  }

  /// Sincronizar ventas pendientes
  Future<void> syncPendingSales() async {
    await _offlineSyncService.syncPendingSales();
  }

  /// Obtener ventas pendientes de sincronización
  Future<List<Map<String, dynamic>>> getPendingSales() async {
    return await _offlineSyncService.getPendingSales();
  }

  /// Stream del estado de sincronización
  Stream<bool> get syncStatus => _offlineSyncService.syncStatus;
}

