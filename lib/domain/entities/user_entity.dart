/// Entidad de Usuario del dominio
class UserEntity {
  final String uid;
  final String email;
  final String role; // 'admin' o 'employee'
  final String storeId; // 'sucursal_1' o 'sucursal_2'

  UserEntity({
    required this.uid,
    required this.email,
    required this.role,
    required this.storeId,
  });

  bool get isAdmin => role == 'admin';
  bool get isEmployee => role == 'employee';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserEntity &&
          runtimeType == other.runtimeType &&
          uid == other.uid;

  @override
  int get hashCode => uid.hashCode;
}

