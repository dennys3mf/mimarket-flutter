import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mi_tienda_app/domain/entities/sale_item_entity.dart';
import 'package:mi_tienda_app/domain/entities/product_entity.dart';

/// Modelo de datos de Item de Venta para Firestore
class SaleItemModel extends SaleItemEntity {
  SaleItemModel({
    required super.product,
    required super.quantity,
    required super.priceAtSale,
  });

  /// Convierte el modelo a Map para Firestore
  Map<String, dynamic> toMap() {
    return {
      'productId': product.id,
      'productName': product.name, // Guardamos el nombre para reportes
      'quantity': quantity,
      'priceAtSale': priceAtSale,
    };
  }

  /// Crea un modelo desde un documento de Firestore
  /// Nota: Requiere el producto completo para reconstruir la entidad
  factory SaleItemModel.fromFirestore(
    DocumentSnapshot doc,
    ProductEntity product,
  ) {
    final data = doc.data() as Map<String, dynamic>;
    return SaleItemModel(
      product: product,
      quantity: data['quantity'] ?? 0,
      priceAtSale: (data['priceAtSale'] ?? 0).toDouble(),
    );
  }

  /// Crea un modelo desde un Map
  factory SaleItemModel.fromMap(
    Map<String, dynamic> map,
    ProductEntity product,
  ) {
    return SaleItemModel(
      product: product,
      quantity: map['quantity'] ?? 0,
      priceAtSale: (map['priceAtSale'] ?? 0).toDouble(),
    );
  }

  /// Convierte la entidad de dominio a modelo
  factory SaleItemModel.fromEntity(SaleItemEntity entity) {
    return SaleItemModel(
      product: entity.product,
      quantity: entity.quantity,
      priceAtSale: entity.priceAtSale,
    );
  }
}

