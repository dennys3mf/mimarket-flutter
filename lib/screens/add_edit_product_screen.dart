import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AddEditProductScreen extends StatefulWidget {
  final DocumentSnapshot? product;
  // <<< CAMBIO: Añadimos un campo para recibir el SKU del escáner
  final String? scannedSku;

  const AddEditProductScreen({super.key, this.product, this.scannedSku});

  @override
  State<AddEditProductScreen> createState() => _AddEditProductScreenState();
}

class _AddEditProductScreenState extends State<AddEditProductScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _stockController = TextEditingController();
  // <<< CAMBIO: Añadimos un controlador para el nuevo campo SKU
  final _skuController = TextEditingController();

  bool _isLoading = false;

  bool get isEditing => widget.product != null;

  @override
  void initState() {
    super.initState();
    if (isEditing) {
      final data = widget.product!.data() as Map<String, dynamic>;
      _nameController.text = data['name'] ?? '';
      _priceController.text = (data['price'] ?? 0.0).toString();
      _stockController.text = (data['stock'] ?? 0).toString();
      // <<< CAMBIO: Rellenamos el SKU si estamos editando
      _skuController.text = data['sku'] ?? '';
    } else if (widget.scannedSku != null) {
      // <<< CAMBIO: Rellenamos el SKU si viene de un escaneo nuevo
      _skuController.text = widget.scannedSku!;
    }
  }

  Future<void> _saveProduct() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final collection = FirebaseFirestore.instance.collection('products');
        final data = {
          'name': _nameController.text,
          'price': double.tryParse(_priceController.text) ?? 0.0,
          'stock': int.tryParse(_stockController.text) ?? 0,
          // <<< CAMBIO: Añadimos el SKU a los datos que se guardan
          'sku': _skuController.text.trim(),
          'lastUpdatedAt': Timestamp.now(),
        };

        if (isEditing) {
          await widget.product!.reference.update(data);
        } else {
          data['createdAt'] = Timestamp.now();
          await collection.add(data);
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Producto ${isEditing ? 'actualizado' : 'guardado'} con éxito',
            ),
          ),
        );

        Navigator.of(context).pop();
      } catch (e) {
        // ... (el resto del código de error no cambia)
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    // <<< CAMBIO: No olvides hacer dispose del nuevo controlador
    _skuController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Editar Producto' : 'Añadir Producto'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            // La lógica para deshabilitar el botón mientras carga ya está en la función
            onPressed: _isLoading ? null : _saveProduct,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: SingleChildScrollView(
                // Usamos SingleChildScrollView para evitar overflow
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    // ... TextFormField de Nombre ...
                    // <<< CAMBIO: Añadimos el nuevo campo de texto para el SKU
                    TextFormField(
                      controller: _skuController,
                      decoration: const InputDecoration(
                        labelText: 'SKU / Código de Barras',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor, introduce un SKU';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Nombre del Producto',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor, introduce un nombre';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _priceController,
                      decoration: const InputDecoration(labelText: 'Precio'),
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor, introduce un precio';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Por favor, introduce un número válido';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _stockController,
                      decoration: const InputDecoration(labelText: 'Stock'),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor, introduce el stock';
                        }
                        if (int.tryParse(value) == null) {
                          return 'Por favor, introduce un número entero';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
