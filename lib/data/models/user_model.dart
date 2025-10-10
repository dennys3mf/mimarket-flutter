import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mi_tienda_app/domain/entities/user_entity.dart';

/// Modelo de datos de Usuario para Firestore
class UserModel extends UserEntity {
  UserModel({
    required super.uid,
    required super.email,
    required super.role,
    required super.storeId,
  });

  /// Convierte el modelo a Map para Firestore
  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'role': role,
      'storeId': storeId,
    };
  }

  /// Crea un modelo desde un documento de Firestore
  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      uid: doc.id,
      email: data['email'] ?? '',
      role: data['role'] ?? 'employee',
      storeId: data['storeId'] ?? 'sucursal_1',
    );
  }

  /// Crea un modelo desde un Map
  factory UserModel.fromMap(String uid, Map<String, dynamic> map) {
    return UserModel(
      uid: uid,
      email: map['email'] ?? '',
      role: map['role'] ?? 'employee',
      storeId: map['storeId'] ?? 'sucursal_1',
    );
  }

  /// Convierte la entidad de dominio a modelo
  factory UserModel.fromEntity(UserEntity entity) {
    return UserModel(
      uid: entity.uid,
      email: entity.email,
      role: entity.role,
      storeId: entity.storeId,
    );
  }
}

