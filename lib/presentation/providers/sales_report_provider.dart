import 'package:flutter/foundation.dart';
import 'package:mi_tienda_app/domain/entities/sale_entity.dart';
import 'package:mi_tienda_app/data/repositories/sale_repository.dart';
import 'package:mi_tienda_app/core/constants/app_constants.dart';

/// Modelo de reporte de ventas del día
class DailySalesReport {
  final double totalSales;
  final double cashSales;
  final double yapeSales;
  final double cardSales;
  final int totalTransactions;
  final Map<String, int> productsSold; // productName -> quantity
  final List<SaleEntity> sales;

  DailySalesReport({
    required this.totalSales,
    required this.cashSales,
    required this.yapeSales,
    required this.cardSales,
    required this.totalTransactions,
    required this.productsSold,
    required this.sales,
  });
}

/// Provider de reportes de ventas
/// Gestiona los reportes y estadísticas de ventas
class SalesReportProvider with ChangeNotifier {
  final SaleRepository _saleRepository;

  List<SaleEntity> _todaySales = [];
  bool _isLoading = false;
  String? _errorMessage;
  bool _hasPendingSales = false;

  SalesReportProvider(this._saleRepository) {
    _initSalesStream();
    _initSyncStatusStream();
  }

  // Getters
  List<SaleEntity> get todaySales => List.unmodifiable(_todaySales);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasPendingSales => _hasPendingSales;

  /// Inicializar stream de ventas del día
  void _initSalesStream() {
    // Este método se llamará cuando se necesite con el storeId
  }

  /// Inicializar stream de estado de sincronización
  void _initSyncStatusStream() {
    _saleRepository.syncStatus.listen((isSynced) {
      _checkPendingSales();
    });
  }

  /// Cargar ventas del día para una sucursal
  Future<void> loadTodaySales(String storeId) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      _todaySales = await _saleRepository.getSalesByDate(
        DateTime.now(),
        storeId,
      );

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Error al cargar ventas: $e';
      notifyListeners();
    }
  }

  /// Generar reporte del día
  DailySalesReport generateDailyReport() {
    double totalSales = 0;
    double cashSales = 0;
    double yapeSales = 0;
    double cardSales = 0;
    final Map<String, int> productsSold = {};

    for (final sale in _todaySales) {
      totalSales += sale.total;

      // Sumar por método de pago
      switch (sale.paymentMethod) {
        case AppConstants.paymentCash:
          cashSales += sale.total;
          break;
        case AppConstants.paymentYape:
          yapeSales += sale.total;
          break;
        case AppConstants.paymentCard:
          cardSales += sale.total;
          break;
      }

      // Contar productos vendidos
      for (final item in sale.items) {
        final productName = item.product.name;
        productsSold[productName] = (productsSold[productName] ?? 0) + item.quantity;
      }
    }

    return DailySalesReport(
      totalSales: totalSales,
      cashSales: cashSales,
      yapeSales: yapeSales,
      cardSales: cardSales,
      totalTransactions: _todaySales.length,
      productsSold: productsSold,
      sales: _todaySales,
    );
  }

  /// Sincronizar ventas pendientes
  Future<void> syncPendingSales() async {
    try {
      await _saleRepository.syncPendingSales();
      await _checkPendingSales();
    } catch (e) {
      _errorMessage = 'Error al sincronizar ventas';
      notifyListeners();
    }
  }

  /// Verificar si hay ventas pendientes
  Future<void> _checkPendingSales() async {
    try {
      final pending = await _saleRepository.getPendingSales();
      _hasPendingSales = pending.isNotEmpty;
      notifyListeners();
    } catch (e) {
      // Silenciar error
    }
  }

  /// Limpiar mensaje de error
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}

