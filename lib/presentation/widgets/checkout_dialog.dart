import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mi_tienda_app/presentation/providers/cart_provider.dart';
import 'package:mi_tienda_app/presentation/providers/auth_provider.dart';
import 'package:mi_tienda_app/core/constants/app_constants.dart';
import 'package:intl/intl.dart';

/// Diálogo de checkout (cobro)
/// Permite seleccionar el método de pago y confirmar la venta
class CheckoutDialog extends StatefulWidget {
  const CheckoutDialog({super.key});

  @override
  State<CheckoutDialog> createState() => _CheckoutDialogState();
}

class _CheckoutDialogState extends State<CheckoutDialog> {
  String? _selectedPaymentMethod;
  bool _isProcessing = false;

  Future<void> _handleConfirm() async {
    if (_selectedPaymentMethod == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecciona un método de pago'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    final cartProvider = context.read<CartProvider>();
    final authProvider = context.read<AuthProvider>();

    final success = await cartProvider.checkout(
      paymentMethod: _selectedPaymentMethod!,
      userId: authProvider.currentUser!.uid,
      storeId: authProvider.currentUser!.storeId,
    );

    if (!mounted) return;

    if (success) {
      Navigator.of(context).pop(true);
    } else {
      setState(() {
        _isProcessing = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(cartProvider.errorMessage ?? 'Error al procesar venta'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = context.watch<CartProvider>();
    final currencyFormat = NumberFormat.currency(symbol: 'S/ ', decimalDigits: 2);

    return AlertDialog(
      title: const Text('Confirmar Venta'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Total a cobrar
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                const Text(
                  'Total a Cobrar',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
                const SizedBox(height: 8),
                Text(
                  currencyFormat.format(cartProvider.total),
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Título de métodos de pago
          const Text(
            'Selecciona el método de pago:',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          // Botones de método de pago
          _PaymentMethodButton(
            icon: Icons.phone_android,
            label: 'YAPE',
            value: AppConstants.paymentYape,
            selectedValue: _selectedPaymentMethod,
            onSelected: (value) {
              setState(() {
                _selectedPaymentMethod = value;
              });
            },
          ),
          const SizedBox(height: 12),
          _PaymentMethodButton(
            icon: Icons.money,
            label: 'EFECTIVO',
            value: AppConstants.paymentCash,
            selectedValue: _selectedPaymentMethod,
            onSelected: (value) {
              setState(() {
                _selectedPaymentMethod = value;
              });
            },
          ),
          const SizedBox(height: 12),
          _PaymentMethodButton(
            icon: Icons.credit_card,
            label: 'TARJETA',
            value: AppConstants.paymentCard,
            selectedValue: _selectedPaymentMethod,
            onSelected: (value) {
              setState(() {
                _selectedPaymentMethod = value;
              });
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _isProcessing ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: _isProcessing ? null : _handleConfirm,
          style: FilledButton.styleFrom(
            backgroundColor: Colors.green,
          ),
          child: _isProcessing
              ? const SizedBox(
                  height: 16,
                  width: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Text('Confirmar Venta'),
        ),
      ],
    );
  }
}

/// Botón de método de pago
class _PaymentMethodButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String? selectedValue;
  final ValueChanged<String> onSelected;

  const _PaymentMethodButton({
    required this.icon,
    required this.label,
    required this.value,
    required this.selectedValue,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = value == selectedValue;

    return InkWell(
      onTap: () => onSelected(value),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).primaryColor
              : Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected
                ? Theme.of(context).primaryColor
                : Colors.grey.withOpacity(0.3),
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : Colors.grey,
              size: 28,
            ),
            const SizedBox(width: 16),
            Text(
              label,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.white : Colors.grey,
              ),
            ),
            const Spacer(),
            if (isSelected)
              const Icon(
                Icons.check_circle,
                color: Colors.white,
              ),
          ],
        ),
      ),
    );
  }
}

