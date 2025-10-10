import 'package:flutter/foundation.dart';
import 'package:mi_tienda_app/domain/entities/product_entity.dart';
import 'package:mi_tienda_app/data/repositories/product_repository.dart';

/// Provider de productos
/// Gestiona el estado de productos y operaciones relacionadas
class ProductProvider with ChangeNotifier {
  final ProductRepository _productRepository;

  List<ProductEntity> _products = [];
  bool _isLoading = false;
  String? _errorMessage;

  ProductProvider(this._productRepository) {
    _initProductsStream();
  }

  // Getters
  List<ProductEntity> get products => List.unmodifiable(_products);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Inicializar stream de productos
  void _initProductsStream() {
    _productRepository.getProductsStream().listen(
      (products) {
        _products = products;
        notifyListeners();
      },
      onError: (error) {
        _errorMessage = 'Error al cargar productos';
        notifyListeners();
      },
    );
  }

  /// Buscar producto por código de barras
  Future<ProductEntity?> getProductByBarcode(String barcode) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final product = await _productRepository.getProductByBarcode(barcode);

      _isLoading = false;
      notifyListeners();

      return product;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Error al buscar producto';
      notifyListeners();
      return null;
    }
  }

  /// Crear nuevo producto
  Future<ProductEntity?> createProduct({
    required String barcode,
    required String name,
    required double price,
    required String storeId,
    int initialStock = 0,
  }) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final product = await _productRepository.createProduct(
        barcode: barcode,
        name: name,
        price: price,
        storeId: storeId,
        initialStock: initialStock,
      );

      _isLoading = false;
      notifyListeners();

      return product;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Error al crear producto: $e';
      notifyListeners();
      return null;
    }
  }

  /// Actualizar producto
  Future<bool> updateProduct(ProductEntity product) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      await _productRepository.updateProduct(product);

      _isLoading = false;
      notifyListeners();

      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Error al actualizar producto';
      notifyListeners();
      return false;
    }
  }

  /// Actualizar stock de producto
  Future<bool> updateProductStock(
    String productId,
    String storeId,
    int newStock,
  ) async {
    try {
      await _productRepository.updateProductStock(productId, storeId, newStock);
      return true;
    } catch (e) {
      _errorMessage = 'Error al actualizar stock';
      notifyListeners();
      return false;
    }
  }

  /// Buscar productos por nombre
  List<ProductEntity> searchProducts(String query) {
    if (query.isEmpty) return _products;

    return _products.where((product) {
      return product.name.toLowerCase().contains(query.toLowerCase()) ||
          product.barcode.contains(query);
    }).toList();
  }

  /// Limpiar mensaje de error
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}

