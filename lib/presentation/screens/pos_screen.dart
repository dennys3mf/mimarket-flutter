import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:mi_tienda_app/presentation/providers/auth_provider.dart';
import 'package:mi_tienda_app/presentation/providers/cart_provider.dart';
import 'package:mi_tienda_app/presentation/providers/product_provider.dart';
import 'package:mi_tienda_app/presentation/widgets/quick_add_product_dialog.dart';
import 'package:mi_tienda_app/presentation/widgets/checkout_dialog.dart';
import 'package:mi_tienda_app/presentation/widgets/cart_item_widget.dart';
import 'package:intl/intl.dart';

/// Pantalla principal de ventas (POS)
/// Implementa el flujo de escaneo único
class POSScreen extends StatefulWidget {
  const POSScreen({super.key});

  @override
  State<POSScreen> createState() => _POSScreenState();
}

class _POSScreenState extends State<POSScreen> {
  final MobileScannerController _scannerController = MobileScannerController();
  bool _isProcessingBarcode = false;

  @override
  void dispose() {
    _scannerController.dispose();
    super.dispose();
  }

  Future<void> _handleBarcodeScan(String barcode) async {
    if (_isProcessingBarcode) return;

    setState(() {
      _isProcessingBarcode = true;
    });

    final productProvider = context.read<ProductProvider>();
    final cartProvider = context.read<CartProvider>();

    try {
      // Buscar producto por código de barras
      final product = await productProvider.getProductByBarcode(barcode);

      if (product != null) {
        // Producto existe: agregar al carrito
        cartProvider.addProduct(product);
      } else {
        // Producto no existe: mostrar diálogo de alta rápida
        if (!mounted) return;
        final newProduct = await showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => QuickAddProductDialog(barcode: barcode),
        );

        if (newProduct != null) {
          cartProvider.addProduct(newProduct);
        }
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al procesar código: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isProcessingBarcode = false;
      });
    }
  }

  Future<void> _handleCheckout() async {
    final cartProvider = context.read<CartProvider>();
    
    if (cartProvider.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('El carrito está vacío'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final result = await showDialog(
      context: context,
      builder: (context) => const CheckoutDialog(),
    );

    if (result == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('¡Venta registrada exitosamente!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final cartProvider = context.watch<CartProvider>();
    final currencyFormat = NumberFormat.currency(symbol: 'S/ ', decimalDigits: 2);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Modo Venta'),
        actions: [
          // Indicador de sincronización
          Consumer<CartProvider>(
            builder: (context, cart, child) {
              return const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Icon(Icons.cloud_done, color: Colors.green),
              );
            },
          ),
          
          // Botón de cerrar sesión
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              authProvider.signOut();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Scanner de código de barras
          Container(
            height: 250,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.all(16),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: MobileScanner(
                controller: _scannerController,
                onDetect: (capture) {
                  final List<Barcode> barcodes = capture.barcodes;
                  if (barcodes.isNotEmpty && barcodes.first.rawValue != null) {
                    _handleBarcodeScan(barcodes.first.rawValue!);
                  }
                },
              ),
            ),
          ),

          // Información del carrito
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Productos: ${cartProvider.itemCount}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Text(
                  'Total: ${currencyFormat.format(cartProvider.total)}',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColor,
                      ),
                ),
              ],
            ),
          ),

          const Divider(height: 32),

          // Lista de productos en el carrito
          Expanded(
            child: cartProvider.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.shopping_cart_outlined,
                          size: 64,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Escanea un producto para comenzar',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: cartProvider.items.length,
                    itemBuilder: (context, index) {
                      final item = cartProvider.items[index];
                      return CartItemWidget(item: item);
                    },
                  ),
          ),

          // Botón de cobrar
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: FilledButton(
                  onPressed: cartProvider.isEmpty ? null : _handleCheckout,
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                  child: Text(
                    'COBRAR ${currencyFormat.format(cartProvider.total)}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

