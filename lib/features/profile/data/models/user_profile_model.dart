import '../../domain/entities/user_profile.dart';

/// Modelo de Perfil de Usuario para la capa de datos
class UserProfileModel extends UserProfile {
  const UserProfileModel({
    required super.id,
    required super.email,
    required super.fullName,
    required super.userType,
    super.phone,
    super.avatarUrl,
    super.bio,
    super.location,
    super.latitude,
    super.longitude,
    required super.createdAt,
    required super.updatedAt,
  });

  /// Crea un UserProfileModel desde JSON
  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    return UserProfileModel(
      id: json['id'] as String,
      email: json['email'] as String,
      fullName: json['full_name'] as String,
      userType: UserType.fromJson(json['user_type'] as String),
      phone: json['phone'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      bio: json['bio'] as String?,
      location: json['location'] as String?,
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

  /// Convierte el modelo a JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'full_name': fullName,
      'user_type': userType.toJson(),
      'phone': phone,
      'avatar_url': avatarUrl,
      'bio': bio,
      'location': location,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Convierte el modelo a entidad del dominio
  UserProfile toEntity() {
    return UserProfile(
      id: id,
      email: email,
      fullName: fullName,
      userType: userType,
      phone: phone,
      avatarUrl: avatarUrl,
      bio: bio,
      location: location,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  /// Crea un modelo desde una entidad del dominio
  factory UserProfileModel.fromEntity(UserProfile profile) {
    return UserProfileModel(
      id: profile.id,
      email: profile.email,
      fullName: profile.fullName,
      userType: profile.userType,
      phone: profile.phone,
      avatarUrl: profile.avatarUrl,
      bio: profile.bio,
      location: profile.location,
      createdAt: profile.createdAt,
      updatedAt: profile.updatedAt,
    );
  }

  /// Crea una copia con campos modificados
  @override
  UserProfileModel copyWith({
    String? id,
    String? email,
    String? fullName,
    UserType? userType,
    String? phone,
    String? avatarUrl,
    String? bio,
    String? location,
    double? latitude,
    double? longitude,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserProfileModel(
      id: id ?? this.id,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      userType: userType ?? this.userType,
      phone: phone ?? this.phone,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      bio: bio ?? this.bio,
      location: location ?? this.location,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
