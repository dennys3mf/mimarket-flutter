import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mi_tienda_app/core/constants/app_constants.dart';
import 'package:mi_tienda_app/data/models/product_model.dart';
import 'package:mi_tienda_app/data/models/sale_model.dart';
import 'package:mi_tienda_app/data/models/sale_item_model.dart';

/// Servicio de Firestore para operaciones de base de datos
class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ==================== PRODUCTOS ====================

  /// Obtener producto por código de barras
  Future<ProductModel?> getProductByBarcode(String barcode) async {
    try {
      final querySnapshot = await _firestore
          .collection(AppConstants.productsCollection)
          .where('barcode', isEqualTo: barcode)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        return ProductModel.fromFirestore(querySnapshot.docs.first);
      }
      return null;
    } catch (e) {
      throw Exception('Error al buscar producto: $e');
    }
  }

  /// Crear nuevo producto
  Future<ProductModel> createProduct(ProductModel product) async {
    try {
      // Usar el barcode como ID del documento para búsquedas rápidas
      final docRef = _firestore
          .collection(AppConstants.productsCollection)
          .doc(product.barcode);

      await docRef.set(product.toMap());

      return product.copyWith(id: product.barcode);
    } catch (e) {
      throw Exception('Error al crear producto: $e');
    }
  }

  /// Actualizar producto
  Future<void> updateProduct(ProductModel product) async {
    try {
      await _firestore
          .collection(AppConstants.productsCollection)
          .doc(product.id)
          .update(product.toMap());
    } catch (e) {
      throw Exception('Error al actualizar producto: $e');
    }
  }

  /// Stream de todos los productos
  Stream<List<ProductModel>> getProductsStream() {
    return _firestore
        .collection(AppConstants.productsCollection)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ProductModel.fromFirestore(doc))
            .toList());
  }

  /// Actualizar stock de producto
  Future<void> updateProductStock(
    String productId,
    String storeId,
    int newStock,
  ) async {
    try {
      await _firestore
          .collection(AppConstants.productsCollection)
          .doc(productId)
          .update({
        'stock.$storeId': newStock,
      });
    } catch (e) {
      throw Exception('Error al actualizar stock: $e');
    }
  }

  // ==================== VENTAS ====================

  /// Crear nueva venta con sus items
  Future<void> createSale(SaleModel sale) async {
    try {
      final batch = _firestore.batch();

      // Crear documento de venta
      final saleRef = _firestore
          .collection(AppConstants.salesCollection)
          .doc(sale.id);
      batch.set(saleRef, sale.toMap());

      // Crear subcolección de items vendidos
      for (final item in sale.items) {
        final itemRef = saleRef
            .collection(AppConstants.soldItemsSubcollection)
            .doc();
        batch.set(itemRef, SaleItemModel.fromEntity(item).toMap());

        // Actualizar stock del producto
        final productRef = _firestore
            .collection(AppConstants.productsCollection)
            .doc(item.product.id);
        batch.update(productRef, {
          'stock.${sale.storeId}': FieldValue.increment(-item.quantity),
        });
      }

      await batch.commit();
    } catch (e) {
      throw Exception('Error al crear venta: $e');
    }
  }

  /// Obtener ventas de un día específico
  Future<List<SaleModel>> getSalesByDate(
    DateTime date,
    String storeId,
  ) async {
    try {
      final startOfDay = DateTime(date.year, date.month, date.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      final querySnapshot = await _firestore
          .collection(AppConstants.salesCollection)
          .where('storeId', isEqualTo: storeId)
          .where('timestamp', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
          .where('timestamp', isLessThan: Timestamp.fromDate(endOfDay))
          .orderBy('timestamp', descending: true)
          .get();

      final sales = <SaleModel>[];
      for (final doc in querySnapshot.docs) {
        final items = await _getSaleItems(doc.id);
        sales.add(SaleModel.fromFirestore(doc, items));
      }

      return sales;
    } catch (e) {
      throw Exception('Error al obtener ventas: $e');
    }
  }

  /// Obtener items de una venta
  Future<List<SaleItemModel>> _getSaleItems(String saleId) async {
    try {
      final querySnapshot = await _firestore
          .collection(AppConstants.salesCollection)
          .doc(saleId)
          .collection(AppConstants.soldItemsSubcollection)
          .get();

      final items = <SaleItemModel>[];
      for (final doc in querySnapshot.docs) {
        final data = doc.data();
        final productId = data['productId'];
        
        // Obtener el producto (necesario para reconstruir el SaleItem)
        final productDoc = await _firestore
            .collection(AppConstants.productsCollection)
            .doc(productId)
            .get();

        if (productDoc.exists) {
          final product = ProductModel.fromFirestore(productDoc);
          items.add(SaleItemModel.fromMap(data, product));
        }
      }

      return items;
    } catch (e) {
      throw Exception('Error al obtener items de venta: $e');
    }
  }

  /// Stream de ventas del día actual
  Stream<List<SaleModel>> getTodaySalesStream(String storeId) {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);

    return _firestore
        .collection(AppConstants.salesCollection)
        .where('storeId', isEqualTo: storeId)
        .where('timestamp', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .orderBy('timestamp', descending: true)
        .snapshots()
        .asyncMap((snapshot) async {
      final sales = <SaleModel>[];
      for (final doc in snapshot.docs) {
        final items = await _getSaleItems(doc.id);
        sales.add(SaleModel.fromFirestore(doc, items));
      }
      return sales;
    });
  }
}

