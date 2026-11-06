import 'package:equatable/equatable.dart';

enum UserRole { customer, vendor, driver, admin }

class UserEntity extends Equatable {
  final String uid;
  final String? email;
  final String? phone;
  final UserRole role;
  final String displayName;
  final String? photoUrl;
  final bool isActive;
  final DateTime createdAt;

  const UserEntity({
    required this.uid,
    this.email,
    this.phone,
    required this.role,
    required this.displayName,
    this.photoUrl,
    this.isActive = true,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [uid, role];
}
