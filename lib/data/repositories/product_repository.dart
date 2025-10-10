import 'package:mi_tienda_app/data/services/firestore_service.dart';
import 'package:mi_tienda_app/domain/entities/product_entity.dart';
import 'package:mi_tienda_app/data/models/product_model.dart';

/// Repositorio de productos
/// Gestiona el acceso a datos de productos
class ProductRepository {
  final FirestoreService _firestoreService;

  ProductRepository(this._firestoreService);

  /// Buscar producto por código de barras
  Future<ProductEntity?> getProductByBarcode(String barcode) async {
    try {
      return await _firestoreService.getProductByBarcode(barcode);
    } catch (e) {
      throw Exception('Error en repositorio al buscar producto: $e');
    }
  }

  /// Crear nuevo producto
  Future<ProductEntity> createProduct({
    required String barcode,
    required String name,
    required double price,
    required String storeId,
    int initialStock = 0,
  }) async {
    try {
      final product = ProductModel(
        id: barcode, // Usar barcode como ID
        barcode: barcode,
        name: name,
        price: price,
        stock: {storeId: initialStock},
      );

      return await _firestoreService.createProduct(product);
    } catch (e) {
      throw Exception('Error en repositorio al crear producto: $e');
    }
  }

  /// Actualizar producto existente
  Future<void> updateProduct(ProductEntity product) async {
    try {
      final productModel = ProductModel.fromEntity(product);
      await _firestoreService.updateProduct(productModel);
    } catch (e) {
      throw Exception('Error en repositorio al actualizar producto: $e');
    }
  }

  /// Obtener stream de productos
  Stream<List<ProductEntity>> getProductsStream() {
    return _firestoreService.getProductsStream();
  }

  /// Actualizar stock de producto
  Future<void> updateProductStock(
    String productId,
    String storeId,
    int newStock,
  ) async {
    try {
      await _firestoreService.updateProductStock(productId, storeId, newStock);
    } catch (e) {
      throw Exception('Error en repositorio al actualizar stock: $e');
    }
  }
}

