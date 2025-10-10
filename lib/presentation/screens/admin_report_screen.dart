import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mi_tienda_app/presentation/providers/sales_report_provider.dart';
import 'package:mi_tienda_app/presentation/providers/auth_provider.dart';
import 'package:intl/intl.dart';

/// Pantalla de reportes de administrador
/// Muestra el cierre de caja y estadísticas de ventas
class AdminReportScreen extends StatefulWidget {
  const AdminReportScreen({super.key});

  @override
  State<AdminReportScreen> createState() => _AdminReportScreenState();
}

class _AdminReportScreenState extends State<AdminReportScreen> {
  @override
  void initState() {
    super.initState();
    _loadReport();
  }

  Future<void> _loadReport() async {
    final authProvider = context.read<AuthProvider>();
    final reportProvider = context.read<SalesReportProvider>();
    await reportProvider.loadTodaySales(authProvider.currentUser!.storeId);
  }

  @override
  Widget build(BuildContext context) {
    final reportProvider = context.watch<SalesReportProvider>();
    final currencyFormat = NumberFormat.currency(symbol: 'S/ ', decimalDigits: 2);
    final dateFormat = DateFormat('dd/MM/yyyy');

    if (reportProvider.isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final report = reportProvider.generateDailyReport();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reporte de Ventas'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadReport,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadReport,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Fecha
              Text(
                'Reporte del ${dateFormat.format(DateTime.now())}',
                style: Theme.of(context).textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),

              // Total de ventas del día
              _SummaryCard(
                title: 'VENTAS TOTALES DEL DÍA',
                value: currencyFormat.format(report.totalSales),
                icon: Icons.attach_money,
                color: Colors.green,
              ),
              const SizedBox(height: 16),

              // Transacciones
              _SummaryCard(
                title: 'TRANSACCIONES',
                value: '${report.totalTransactions}',
                icon: Icons.receipt_long,
                color: Colors.blue,
              ),
              const SizedBox(height: 24),

              // Desglose por método de pago
              Text(
                'Desglose por Método de Pago',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 12),

              _PaymentMethodCard(
                method: 'Efectivo',
                amount: currencyFormat.format(report.cashSales),
                icon: Icons.money,
                color: Colors.green,
              ),
              const SizedBox(height: 8),

              _PaymentMethodCard(
                method: 'Yape',
                amount: currencyFormat.format(report.yapeSales),
                icon: Icons.phone_android,
                color: Colors.purple,
              ),
              const SizedBox(height: 8),

              _PaymentMethodCard(
                method: 'Tarjeta',
                amount: currencyFormat.format(report.cardSales),
                icon: Icons.credit_card,
                color: Colors.blue,
              ),
              const SizedBox(height: 24),

              // Productos vendidos
              Text(
                'Productos Vendidos',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 12),

              if (report.productsSold.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: Text(
                      'No hay ventas registradas hoy',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                )
              else
                ...report.productsSold.entries.map((entry) {
                  return _ProductSoldCard(
                    productName: entry.key,
                    quantity: entry.value,
                  );
                }).toList(),

              const SizedBox(height: 24),

              // Indicador de sincronización
              if (reportProvider.hasPendingSales)
                Card(
                  color: Colors.orange.withOpacity(0.2),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        const Icon(Icons.cloud_upload, color: Colors.orange),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            'Hay ventas pendientes de sincronizar',
                            style: TextStyle(color: Colors.orange),
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            reportProvider.syncPendingSales();
                          },
                          child: const Text('Sincronizar'),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Card de resumen
class _SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _SummaryCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Icon(icon, size: 48, color: color),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Card de método de pago
class _PaymentMethodCard extends StatelessWidget {
  final String method;
  final String amount;
  final IconData icon;
  final Color color;

  const _PaymentMethodCard({
    required this.method,
    required this.amount,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                method,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Text(
              amount,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Card de producto vendido
class _ProductSoldCard extends StatelessWidget {
  final String productName;
  final int quantity;

  const _ProductSoldCard({
    required this.productName,
    required this.quantity,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            const Icon(Icons.shopping_bag, color: Colors.grey),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                productName,
                style: const TextStyle(fontSize: 14),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '$quantity unidades',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

