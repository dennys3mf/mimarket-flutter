import 'package:mi_tienda_app/domain/entities/sale_item_entity.dart';

/// Entidad de Venta del dominio
class SaleEntity {
  final String id;
  final DateTime timestamp;
  final double total;
  final String paymentMethod; // 'yape', 'efectivo', 'tarjeta'
  final String userId;
  final String storeId;
  final List<SaleItemEntity> items;
  final bool synced; // Indica si ya se sincronizó con Firebase

  SaleEntity({
    required this.id,
    required this.timestamp,
    required this.total,
    required this.paymentMethod,
    required this.userId,
    required this.storeId,
    required this.items,
    this.synced = false,
  });

  SaleEntity copyWith({
    String? id,
    DateTime? timestamp,
    double? total,
    String? paymentMethod,
    String? userId,
    String? storeId,
    List<SaleItemEntity>? items,
    bool? synced,
  }) {
    return SaleEntity(
      id: id ?? this.id,
      timestamp: timestamp ?? this.timestamp,
      total: total ?? this.total,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      userId: userId ?? this.userId,
      storeId: storeId ?? this.storeId,
      items: items ?? this.items,
      synced: synced ?? this.synced,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SaleEntity &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}

