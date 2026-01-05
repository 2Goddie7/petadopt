import 'package:equatable/equatable.dart';

/// Entidad de Perfil de Usuario en el dominio
class UserProfile extends Equatable {
  final String id;
  final String email;
  final String fullName;
  final UserType userType;
  final String? phone;
  final String? avatarUrl;
  final String? bio;
  final String? location;
  final DateTime createdAt;
  final DateTime updatedAt;

  const UserProfile({
    required this.id,
    required this.email,
    required this.fullName,
    required this.userType,
    this.phone,
    this.avatarUrl,
    this.bio,
    this.location,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Crea una copia con campos modificados
  UserProfile copyWith({
    String? id,
    String? email,
    String? fullName,
    UserType? userType,
    String? phone,
    String? avatarUrl,
    String? bio,
    String? location,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserProfile(
      id: id ?? this.id,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      userType: userType ?? this.userType,
      phone: phone ?? this.phone,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      bio: bio ?? this.bio,
      location: location ?? this.location,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Verifica si el perfil tiene avatar
  bool get hasAvatar => avatarUrl != null && avatarUrl!.isNotEmpty;

  /// Verifica si el perfil tiene biografía
  bool get hasBio => bio != null && bio!.isNotEmpty;

  /// Verifica si el perfil tiene teléfono
  bool get hasPhone => phone != null && phone!.isNotEmpty;

  /// Verifica si el perfil tiene ubicación
  bool get hasLocation => location != null && location!.isNotEmpty;

  /// Verifica si es un adoptante
  bool get isAdopter => userType == UserType.adopter;

  /// Verifica si es un refugio
  bool get isShelter => userType == UserType.shelter;

  /// Obtiene las iniciales del nombre
  String get initials {
    final names = fullName.trim().split(' ');
    if (names.isEmpty) return '??';
    if (names.length == 1) return names[0][0].toUpperCase();
    return '${names[0][0]}${names[names.length - 1][0]}'.toUpperCase();
  }

  /// Formatea el tipo de usuario
  String get userTypeFormatted {
    switch (userType) {
      case UserType.adopter:
        return 'Adoptante';
      case UserType.shelter:
        return 'Refugio';
    }
  }

  /// Verifica si el perfil está completo
  bool get isProfileComplete {
    return hasPhone && hasLocation && (isShelter ? hasBio : true);
  }

  @override
  List<Object?> get props => [
        id,
        email,
        fullName,
        userType,
        phone,
        avatarUrl,
        bio,
        location,
        createdAt,
        updatedAt,
      ];

  @override
  String toString() {
    return 'UserProfile(id: $id, fullName: $fullName, userType: $userType)';
  }
}

/// Enum del tipo de usuario
enum UserType {
  adopter,
  shelter;

  /// Convierte a String para JSON
  String toJson() {
    switch (this) {
      case UserType.adopter:
        return 'adopter';
      case UserType.shelter:
        return 'shelter';
    }
  }

  /// Crea desde String de JSON
  static UserType fromJson(String json) {
    switch (json.toLowerCase()) {
      case 'adopter':
        return UserType.adopter;
      case 'shelter':
        return UserType.shelter;
      default:
        throw ArgumentError('Invalid UserType: $json');
    }
  }
}