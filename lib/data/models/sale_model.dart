import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mi_tienda_app/domain/entities/sale_entity.dart';
import 'package:mi_tienda_app/domain/entities/sale_item_entity.dart';

/// Modelo de datos de Venta para Firestore
class SaleModel extends SaleEntity {
  SaleModel({
    required super.id,
    required super.timestamp,
    required super.total,
    required super.paymentMethod,
    required super.userId,
    required super.storeId,
    required super.items,
    super.synced = false,
  });

  /// Convierte el modelo a Map para Firestore
  Map<String, dynamic> toMap() {
    return {
      'timestamp': Timestamp.fromDate(timestamp),
      'total': total,
      'paymentMethod': paymentMethod,
      'userId': userId,
      'storeId': storeId,
      'synced': synced,
    };
  }

  /// Crea un modelo desde un documento de Firestore
  factory SaleModel.fromFirestore(
    DocumentSnapshot doc,
    List<SaleItemEntity> items,
  ) {
    final data = doc.data() as Map<String, dynamic>;
    return SaleModel(
      id: doc.id,
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      total: (data['total'] ?? 0).toDouble(),
      paymentMethod: data['paymentMethod'] ?? '',
      userId: data['userId'] ?? '',
      storeId: data['storeId'] ?? '',
      items: items,
      synced: data['synced'] ?? true,
    );
  }

  /// Crea un modelo desde un Map
  factory SaleModel.fromMap(
    String id,
    Map<String, dynamic> map,
    List<SaleItemEntity> items,
  ) {
    return SaleModel(
      id: id,
      timestamp: map['timestamp'] is Timestamp
          ? (map['timestamp'] as Timestamp).toDate()
          : DateTime.parse(map['timestamp']),
      total: (map['total'] ?? 0).toDouble(),
      paymentMethod: map['paymentMethod'] ?? '',
      userId: map['userId'] ?? '',
      storeId: map['storeId'] ?? '',
      items: items,
      synced: map['synced'] ?? true,
    );
  }

  /// Convierte la entidad de dominio a modelo
  factory SaleModel.fromEntity(SaleEntity entity) {
    return SaleModel(
      id: entity.id,
      timestamp: entity.timestamp,
      total: entity.total,
      paymentMethod: entity.paymentMethod,
      userId: entity.userId,
      storeId: entity.storeId,
      items: entity.items,
      synced: entity.synced,
    );
  }
}

