import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mi_tienda_app/domain/entities/sale_item_entity.dart';
import 'package:mi_tienda_app/presentation/providers/cart_provider.dart';
import 'package:intl/intl.dart';

/// Widget de item del carrito
class CartItemWidget extends StatelessWidget {
  final SaleItemEntity item;

  const CartItemWidget({
    super.key,
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    final cartProvider = context.watch<CartProvider>();
    final currencyFormat = NumberFormat.currency(symbol: 'S/ ', decimalDigits: 2);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // Información del producto
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.product.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    currencyFormat.format(item.priceAtSale),
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[400],
                    ),
                  ),
                ],
              ),
            ),

            // Controles de cantidad
            Row(
              children: [
                // Botón decrementar
                IconButton(
                  icon: const Icon(Icons.remove_circle_outline),
                  onPressed: () {
                    if (item.quantity > 1) {
                      cartProvider.updateItemQuantity(
                        item.product.id,
                        item.quantity - 1,
                      );
                    } else {
                      cartProvider.removeItem(item.product.id);
                    }
                  },
                  color: Colors.red,
                ),

                // Cantidad
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    '${item.quantity}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                // Botón incrementar
                IconButton(
                  icon: const Icon(Icons.add_circle_outline),
                  onPressed: () {
                    cartProvider.updateItemQuantity(
                      item.product.id,
                      item.quantity + 1,
                    );
                  },
                  color: Colors.green,
                ),
              ],
            ),

            const SizedBox(width: 8),

            // Subtotal
            SizedBox(
              width: 80,
              child: Text(
                currencyFormat.format(item.subtotal),
                textAlign: TextAlign.right,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

