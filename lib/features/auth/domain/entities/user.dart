import 'package:equatable/equatable.dart';

/// Entidad de Usuario en el dominio
/// Representa un usuario de la aplicación (adoptante o refugio)
class User extends Equatable {
  final String id;
  final String email;
  final String fullName;
  final String? phone;
  final UserType userType;
  final String? avatarUrl;
  final double? latitude;
  final double? longitude;
  final DateTime createdAt;
  final DateTime updatedAt;

  const User({
    required this.id,
    required this.email,
    required this.fullName,
    this.phone,
    required this.userType,
    this.avatarUrl,
    this.latitude,
    this.longitude,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Crea una copia del usuario con campos modificados
  User copyWith({
    String? id,
    String? email,
    String? fullName,
    String? phone,
    UserType? userType,
    String? avatarUrl,
    double? latitude,
    double? longitude,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
      userType: userType ?? this.userType,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Verifica si el usuario es adoptante
  bool get isAdopter => userType == UserType.adopter;

  /// Verifica si el usuario es refugio
  bool get isShelter => userType == UserType.shelter;

  /// Verifica si tiene avatar
  bool get hasAvatar => avatarUrl != null && avatarUrl!.isNotEmpty;

  /// Verifica si tiene teléfono
  bool get hasPhone => phone != null && phone!.isNotEmpty;

  @override
  List<Object?> get props => [
        id,
        email,
        fullName,
        phone,
        userType,
        avatarUrl,
        latitude,
        longitude,
        createdAt,
        updatedAt,
      ];

  @override
  bool get stringify => true;
}

/// Tipo de usuario
enum UserType {
  adopter,
  shelter;

  /// Convierte el enum a string para Supabase
  String toJson() {
    switch (this) {
      case UserType.adopter:
        return 'adopter';
      case UserType.shelter:
        return 'shelter';
    }
  }

  /// Crea el enum desde string de Supabase
  static UserType fromJson(String value) {
    switch (value.toLowerCase()) {
      case 'adopter':
        return UserType.adopter;
      case 'shelter':
        return UserType.shelter;
      default:
        throw ArgumentError('Invalid user type: $value');
    }
  }

  /// Obtiene el nombre legible del tipo
  String get displayName {
    switch (this) {
      case UserType.adopter:
        return 'Adoptante';
      case UserType.shelter:
        return 'Refugio';
    }
  }
}