/// Entidad de Producto del dominio
class ProductEntity {
  final String id; // Puede ser el código de barras
  final String barcode;
  final String name;
  final double price;
  final Map<String, int> stock; // {"sucursal_1": 15, "sucursal_2": 20}

  ProductEntity({
    required this.id,
    required this.barcode,
    required this.name,
    required this.price,
    required this.stock,
  });

  int getStockForStore(String storeId) {
    return stock[storeId] ?? 0;
  }

  ProductEntity copyWith({
    String? id,
    String? barcode,
    String? name,
    double? price,
    Map<String, int>? stock,
  }) {
    return ProductEntity(
      id: id ?? this.id,
      barcode: barcode ?? this.barcode,
      name: name ?? this.name,
      price: price ?? this.price,
      stock: stock ?? this.stock,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProductEntity &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}

