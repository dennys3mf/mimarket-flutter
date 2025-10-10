import 'package:flutter/foundation.dart';
import 'package:mi_tienda_app/domain/entities/product_entity.dart';
import 'package:mi_tienda_app/domain/entities/sale_item_entity.dart';
import 'package:mi_tienda_app/domain/entities/sale_entity.dart';
import 'package:mi_tienda_app/data/repositories/sale_repository.dart';
import 'package:audioplayers/audioplayers.dart';

/// Provider del carrito de ventas
/// Gestiona los productos en el carrito y el proceso de checkout
class CartProvider with ChangeNotifier {
  final SaleRepository _saleRepository;
  final AudioPlayer _audioPlayer = AudioPlayer();

  final List<SaleItemEntity> _items = [];
  bool _isProcessing = false;
  String? _errorMessage;

  CartProvider(this._saleRepository);

  // Getters
  List<SaleItemEntity> get items => List.unmodifiable(_items);
  bool get isProcessing => _isProcessing;
  String? get errorMessage => _errorMessage;
  bool get isEmpty => _items.isEmpty;
  int get itemCount => _items.length;

  /// Calcular total del carrito
  double get total {
    return _items.fold(0.0, (sum, item) => sum + item.subtotal);
  }

  /// Agregar producto al carrito
  void addProduct(ProductEntity product) {
    try {
      // Buscar si el producto ya está en el carrito
      final existingIndex = _items.indexWhere(
        (item) => item.product.id == product.id,
      );

      if (existingIndex >= 0) {
        // Incrementar cantidad
        final existingItem = _items[existingIndex];
        _items[existingIndex] = existingItem.copyWith(
          quantity: existingItem.quantity + 1,
        );
      } else {
        // Agregar nuevo item
        _items.add(SaleItemEntity(
          product: product,
          quantity: 1,
          priceAtSale: product.price,
        ));
      }

      // Reproducir sonido de confirmación
      _playBeepSound();

      notifyListeners();
    } catch (e) {
      _errorMessage = 'Error al agregar producto';
      notifyListeners();
    }
  }

  /// Actualizar cantidad de un item
  void updateItemQuantity(String productId, int newQuantity) {
    try {
      if (newQuantity <= 0) {
        removeItem(productId);
        return;
      }

      final index = _items.indexWhere(
        (item) => item.product.id == productId,
      );

      if (index >= 0) {
        _items[index] = _items[index].copyWith(quantity: newQuantity);
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = 'Error al actualizar cantidad';
      notifyListeners();
    }
  }

  /// Eliminar item del carrito
  void removeItem(String productId) {
    try {
      _items.removeWhere((item) => item.product.id == productId);
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Error al eliminar producto';
      notifyListeners();
    }
  }

  /// Limpiar carrito
  void clearCart() {
    _items.clear();
    _errorMessage = null;
    notifyListeners();
  }

  /// Procesar venta (checkout)
  Future<bool> checkout({
    required String paymentMethod,
    required String userId,
    required String storeId,
  }) async {
    if (_items.isEmpty) {
      _errorMessage = 'El carrito está vacío';
      notifyListeners();
      return false;
    }

    try {
      _isProcessing = true;
      _errorMessage = null;
      notifyListeners();

      // Crear venta
      final sale = SaleEntity(
        id: _saleRepository.generateSaleId(),
        timestamp: DateTime.now(),
        total: total,
        paymentMethod: paymentMethod,
        userId: userId,
        storeId: storeId,
        items: List.from(_items),
      );

      // Guardar venta (offline-first)
      await _saleRepository.createSale(sale);

      // Limpiar carrito
      _items.clear();
      _isProcessing = false;
      notifyListeners();

      return true;
    } catch (e) {
      _isProcessing = false;
      _errorMessage = 'Error al procesar venta: $e';
      notifyListeners();
      return false;
    }
  }

  /// Reproducir sonido de confirmación
  Future<void> _playBeepSound() async {
    try {
      // Nota: Necesitarás agregar un archivo de sonido en assets/sounds/beep.mp3
      // Por ahora usamos un sonido del sistema
      await _audioPlayer.play(AssetSource('sounds/beep.mp3'));
    } catch (e) {
      // Silenciar error si no hay sonido disponible
    }
  }

  /// Limpiar mensaje de error
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }
}

