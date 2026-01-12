import '../../domain/entities/user.dart';

/// Modelo de Usuario para la capa de datos
/// Extiende la entidad User y agrega serialización JSON
class UserModel extends User {
  const UserModel({
    required super.id,
    required super.email,
    required super.fullName,
    super.phone,
    required super.userType,
    super.avatarUrl,
    super.latitude,
    super.longitude,
    required super.createdAt,
    required super.updatedAt,
  });

  /// Crea un UserModel desde JSON (Supabase)
  factory UserModel.fromJson(Map<String, dynamic> json) {
    print('🔍 UserModel.fromJson - Raw JSON: $json');

    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      fullName: json['full_name'] as String? ?? json['name'] as String? ?? '',
      phone: json['phone'] as String?,
      // Fix: Permitir userType nulo para flujo de registro OAuth
      userType: (json['user_type'] != null || json['role'] != null)
          ? UserType.fromJson(
              json['user_type'] as String? ?? json['role'] as String? ?? 'adopter')
          : null,
      avatarUrl: json['avatar_url'] as String?,
      latitude: json['latitude'] != null
          ? (json['latitude'] as num).toDouble()
          : null,
      longitude: json['longitude'] != null
          ? (json['longitude'] as num).toDouble()
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  /// Convierte el UserModel a JSON para Supabase
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'full_name': fullName,
      'phone': phone,
      'user_type': userType?.toJson(),
      'avatar_url': avatarUrl,
      'latitude': latitude,
      'longitude': longitude,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Crea un UserModel desde una entidad User
  factory UserModel.fromEntity(User user) {
    return UserModel(
      id: user.id,
      email: user.email,
      fullName: user.fullName,
      phone: user.phone,
      userType: user.userType,
      avatarUrl: user.avatarUrl,
      latitude: user.latitude,
      longitude: user.longitude,
      createdAt: user.createdAt,
      updatedAt: user.updatedAt,
    );
  }

  /// Convierte el UserModel a una entidad User
  User toEntity() {
    return User(
      id: id,
      email: email,
      fullName: fullName,
      phone: phone,
      userType: userType,
      avatarUrl: avatarUrl,
      latitude: latitude,
      longitude: longitude,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  /// Crea una copia del modelo con campos modificados
  @override
  UserModel copyWith({
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
    return UserModel(
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

  /// Crea un UserModel vacío/inicial
  factory UserModel.empty() {
    return UserModel(
      id: '',
      email: '',
      fullName: '',
      userType: UserType.adopter,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  /// Crea un UserModel para registro (sin ID)
  Map<String, dynamic> toJsonForRegistration() {
    return {
      'email': email,
      'full_name': fullName,
      'phone': phone,
      'user_type': userType?.toJson(),
      'avatar_url': avatarUrl,
      'latitude': latitude?.toString(),
      'longitude': longitude?.toString(),
    };
  }

  /// Crea un UserModel para actualización de perfil
  Map<String, dynamic> toJsonForUpdate() {
    return {
      'full_name': fullName,
      'phone': phone,
      'avatar_url': avatarUrl,
      'latitude': latitude,
      'longitude': longitude,
      'updated_at': DateTime.now().toIso8601String(),
    };
  }
}
