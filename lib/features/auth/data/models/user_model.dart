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
    required super.createdAt,
    required super.updatedAt,
  });

  /// Crea un UserModel desde JSON (Supabase)
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      fullName: json['full_name'] as String,
      phone: json['phone'] as String?,
      userType: UserType.fromJson(json['user_type'] as String),
      avatarUrl: json['avatar_url'] as String?,
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
      'user_type': userType.toJson(),
      'avatar_url': avatarUrl,
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
      'user_type': userType.toJson(),
      'avatar_url': avatarUrl,
    };
  }

  /// Crea un UserModel para actualización de perfil
  Map<String, dynamic> toJsonForUpdate() {
    return {
      'full_name': fullName,
      'phone': phone,
      'avatar_url': avatarUrl,
      'updated_at': DateTime.now().toIso8601String(),
    };
  }
}