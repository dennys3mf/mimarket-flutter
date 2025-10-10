import 'package:mi_tienda_app/domain/entities/product_entity.dart';

/// Entidad de Item de Venta (producto en el carrito)
class SaleItemEntity {
  final ProductEntity product;
  final int quantity;
  final double priceAtSale; // Precio al momento de la venta

  SaleItemEntity({
    required this.product,
    required this.quantity,
    required this.priceAtSale,
  });

  double get subtotal => priceAtSale * quantity;

  SaleItemEntity copyWith({
    ProductEntity? product,
    int? quantity,
    double? priceAtSale,
  }) {
    return SaleItemEntity(
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
      priceAtSale: priceAtSale ?? this.priceAtSale,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SaleItemEntity &&
          runtimeType == other.runtimeType &&
          product.id == other.product.id;

  @override
  int get hashCode => product.id.hashCode;
}

