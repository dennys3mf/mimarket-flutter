import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mi_tienda_app/screens/add_edit_product_screen.dart';

class ProcessingScreen extends StatelessWidget {
  final List<DocumentSnapshot> foundDocs;
  final List<String> newSkus;
  final Map<String, int> scanResults;

  const ProcessingScreen({
    super.key,
    required this.foundDocs,
    required this.newSkus,
    required this.scanResults,
  });

  Future<void> _updateStock(BuildContext context) async {
    if (foundDocs.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No hay productos existentes para actualizar.')),
      );
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final db = FirebaseFirestore.instance;
      final writeBatch = db.batch();

      for (final doc in foundDocs) {
        final sku = (doc.data() as Map<String, dynamic>)['sku'];
        final newStock = scanResults[sku];
        if (newStock != null) {
          writeBatch.update(doc.reference, {'stock': newStock});
        }
      }

      await writeBatch.commit();

      if (!context.mounted) return;
      Navigator.of(context).pop(); // Cierra el loading
      Navigator.of(context).pop(); // Vuelve a HomeScreen
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('¡Stock actualizado con éxito!')),
      );
    } catch (e) {
      if (!context.mounted) return;
      Navigator.of(context).pop(); // Cierra el loading
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al actualizar: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Procesar Inventario'),
          actions: [
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: () => _updateStock(context),
              tooltip: 'Guardar Cambios de Stock',
            )
          ],
          bottom: TabBar(
            tabs: [
              Tab(text: 'Reconocidos (${foundDocs.length})'),
              Tab(text: 'Nuevos (${newSkus.length})'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Pestaña para productos existentes
            ListView.builder(
              itemCount: foundDocs.length,
              itemBuilder: (context, index) {
                final doc = foundDocs[index];
                final data = doc.data() as Map<String, dynamic>;
                final sku = data['sku'];
                final newStock = scanResults[sku];
                return ListTile(
                  title: Text(data['name'] ?? 'Sin Nombre'),
                  subtitle: Text('SKU: $sku'),
                  trailing: Text(
                    'Nuevo Stock: $newStock',
                    style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
                  ),
                );
              },
            ),
            // Pestaña para SKUs nuevos
            ListView.builder(
              itemCount: newSkus.length,
              itemBuilder: (context, index) {
                final sku = newSkus[index];
                return ListTile(
                  leading: const Icon(Icons.add_box_outlined),
                  title: Text(sku),
                  subtitle: const Text('Este código no está en la base de datos.'),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => AddEditProductScreen(scannedSku: sku),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}