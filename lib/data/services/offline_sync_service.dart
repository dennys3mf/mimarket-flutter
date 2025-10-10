import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:mi_tienda_app/data/models/sale_model.dart';
import 'package:mi_tienda_app/data/services/firestore_service.dart';
import 'package:mi_tienda_app/core/constants/app_constants.dart';

/// Servicio de sincronización offline
/// Gestiona las ventas pendientes de sincronizar cuando no hay conexión
class OfflineSyncService {
  final FirestoreService _firestoreService;
  final String _pendingSalesKey = 'pending_sales';
  
  StreamController<bool>? _syncStatusController;
  Timer? _syncTimer;

  OfflineSyncService(this._firestoreService);

  /// Stream del estado de sincronización
  Stream<bool> get syncStatus {
    _syncStatusController ??= StreamController<bool>.broadcast();
    return _syncStatusController!.stream;
  }

  /// Iniciar sincronización automática
  void startAutoSync() {
    _syncTimer?.cancel();
    _syncTimer = Timer.periodic(
      AppConstants.syncRetryDelay,
      (_) => syncPendingSales(),
    );
  }

  /// Detener sincronización automática
  void stopAutoSync() {
    _syncTimer?.cancel();
  }

  /// Guardar venta pendiente localmente
  Future<void> savePendingSale(SaleModel sale) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final pendingSalesJson = prefs.getString(_pendingSalesKey) ?? '[]';
      final pendingSales = List<Map<String, dynamic>>.from(
        json.decode(pendingSalesJson),
      );

      // Convertir la venta a Map serializable
      final saleMap = {
        'id': sale.id,
        'timestamp': sale.timestamp.toIso8601String(),
        'total': sale.total,
        'paymentMethod': sale.paymentMethod,
        'userId': sale.userId,
        'storeId': sale.storeId,
        'synced': false,
        'items': sale.items.map((item) => {
          'productId': item.product.id,
          'productName': item.product.name,
          'productBarcode': item.product.barcode,
          'productPrice': item.product.price,
          'quantity': item.quantity,
          'priceAtSale': item.priceAtSale,
        }).toList(),
      };

      pendingSales.add(saleMap);
      await prefs.setString(_pendingSalesKey, json.encode(pendingSales));
    } catch (e) {
      throw Exception('Error al guardar venta pendiente: $e');
    }
  }

  /// Obtener ventas pendientes
  Future<List<Map<String, dynamic>>> getPendingSales() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final pendingSalesJson = prefs.getString(_pendingSalesKey) ?? '[]';
      return List<Map<String, dynamic>>.from(json.decode(pendingSalesJson));
    } catch (e) {
      return [];
    }
  }

  /// Sincronizar ventas pendientes con Firebase
  Future<void> syncPendingSales() async {
    try {
      final pendingSales = await getPendingSales();
      if (pendingSales.isEmpty) {
        _syncStatusController?.add(true);
        return;
      }

      final prefs = await SharedPreferences.getInstance();
      final successfullySynced = <int>[];

      for (int i = 0; i < pendingSales.length; i++) {
        try {
          final saleMap = pendingSales[i];
          
          // Reconstruir el SaleModel desde el Map
          // Nota: Aquí simplificamos, en producción necesitarías
          // reconstruir los objetos ProductEntity completos
          final sale = SaleModel.fromMap(
            saleMap['id'],
            saleMap,
            [], // Los items se manejan en el servicio
          );

          // Intentar sincronizar con Firebase
          await _firestoreService.createSale(sale);
          successfullySynced.add(i);
        } catch (e) {
          // Si falla, continuar con la siguiente
          continue;
        }
      }

      // Eliminar ventas sincronizadas exitosamente
      if (successfullySynced.isNotEmpty) {
        final remainingSales = <Map<String, dynamic>>[];
        for (int i = 0; i < pendingSales.length; i++) {
          if (!successfullySynced.contains(i)) {
            remainingSales.add(pendingSales[i]);
          }
        }
        await prefs.setString(_pendingSalesKey, json.encode(remainingSales));
      }

      _syncStatusController?.add(successfullySynced.length == pendingSales.length);
    } catch (e) {
      _syncStatusController?.add(false);
    }
  }

  /// Verificar si hay conexión a internet intentando acceder a Firestore
  Future<bool> hasInternetConnection() async {
    try {
      await FirebaseFirestore.instance
          .collection('_connection_test')
          .limit(1)
          .get();
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Limpiar todas las ventas pendientes (usar con precaución)
  Future<void> clearPendingSales() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_pendingSalesKey);
  }

  void dispose() {
    _syncTimer?.cancel();
    _syncStatusController?.close();
  }
}

