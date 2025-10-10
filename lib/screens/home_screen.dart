import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mi_tienda_app/screens/add_edit_product_screen.dart';
import 'package:mi_tienda_app/screens/processing_screen.dart';
import 'package:mi_tienda_app/screens/scanner_screen.dart';

// <<< CORRECCIÓN: Devolvemos HomeScreen a un StatefulWidget >>>
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Future<void> _signOut() async {
    await FirebaseAuth.instance.signOut();
    // La navegación ya la maneja el AuthWrapper de main.dart
  }

  Future<void> _openScanner() async {
    // La lógica del scanner ahora vive dentro del State
    final Map<String, int>? scanResults = await Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const ScannerScreen()),
    );

    if (scanResults == null || scanResults.isEmpty || !mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Procesando códigos...')),
    );

    final List<String> scannedSkus = scanResults.keys.toList();
    final db = FirebaseFirestore.instance;

    final querySnapshot = await db
        .collection('products')
        .where('sku', whereIn: scannedSkus)
        .get();

    final List<DocumentSnapshot> foundDocs = querySnapshot.docs;
    final Set<String> foundSkus = foundDocs
        .map((doc) => (doc.data() as Map<String, dynamic>)['sku'] as String)
        .toSet();
    final List<String> newSkus =
        scannedSkus.where((sku) => !foundSkus.contains(sku)).toList();

    if (!mounted) return;

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ProcessingScreen(
          foundDocs: foundDocs,
          newSkus: newSkus,
          scanResults: scanResults,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Inventario'),
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code_scanner),
            onPressed: _openScanner,
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _signOut,
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('products')
            .orderBy('name')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inventory_2_outlined, size: 60, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text('Tu inventario está vacío', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Text('Añade tu primer producto manualmente\no usando el escáner.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey)),
                ],
              ),
            );
          }
          final products = snapshot.data!.docs;
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              return _ProductListItem(product: product);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const AddEditProductScreen()),
          );
        },
        child: const Icon(Icons.add),
        tooltip: 'Añadir Producto',
      ),
    );
  }
}

// El widget personalizado para los items no necesita cambios
class _ProductListItem extends StatelessWidget {
  const _ProductListItem({required this.product});

  final DocumentSnapshot product;

  @override
  Widget build(BuildContext context) {
    final data = product.data() as Map<String, dynamic>;
    final stock = data['stock'] ?? 0;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => AddEditProductScreen(product: product),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data['name'] ?? 'Sin Nombre',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'SKU: ${data['sku'] ?? 'N/A'}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey[400]),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: stock > 10 ? Colors.green.withOpacity(0.2) : Colors.red.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    Text(
                      '$stock',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: stock > 10 ? Colors.green : Colors.red,
                      ),
                    ),
                    Text(
                      'Stock',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: stock > 10 ? Colors.green.shade200 : Colors.red.shade200,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}