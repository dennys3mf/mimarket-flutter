import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mi_tienda_app/domain/entities/product_entity.dart';

/// Modelo de datos de Producto para Firestore
class ProductModel extends ProductEntity {
  ProductModel({
    required super.id,
    required super.barcode,
    required super.name,
    required super.price,
    required super.stock,
  });

  /// Convierte el modelo a Map para Firestore
  Map<String, dynamic> toMap() {
    return {
      'barcode': barcode,
      'name': name,
      'price': price,
      'stock': stock,
    };
  }

  /// Crea un modelo desde un documento de Firestore
  factory ProductModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ProductModel(
      id: doc.id,
      barcode: data['barcode'] ?? '',
      name: data['name'] ?? '',
      price: (data['price'] ?? 0).toDouble(),
      stock: Map<String, int>.from(data['stock'] ?? {}),
    );
  }

  /// Crea un modelo desde un Map
  factory ProductModel.fromMap(String id, Map<String, dynamic> map) {
    return ProductModel(
      id: id,
      barcode: map['barcode'] ?? '',
      name: map['name'] ?? '',
      price: (map['price'] ?? 0).toDouble(),
      stock: Map<String, int>.from(map['stock'] ?? {}),
    );
  }

  /// Convierte la entidad de dominio a modelo
  factory ProductModel.fromEntity(ProductEntity entity) {
    return ProductModel(
      id: entity.id,
      barcode: entity.barcode,
      name: entity.name,
      price: entity.price,
      stock: entity.stock,
    );
  }
}

