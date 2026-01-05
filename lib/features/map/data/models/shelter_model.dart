import '../../domain/entities/shelter.dart';

/// Modelo de Refugio para la capa de datos
/// Extiende la entidad Shelter y agrega serialización JSON
class ShelterModel extends Shelter {
  const ShelterModel({
    required super.id,
    required super.profileId,
    required super.shelterName,
    super.description,
    required super.address,
    required super.city,
    required super.country,
    required super.latitude,
    required super.longitude,
    super.phone,
    super.website,
    super.totalPets,
    super.totalAdoptions,
    required super.createdAt,
    required super.updatedAt,
  });

  /// Crea un ShelterModel desde JSON (Supabase)
  factory ShelterModel.fromJson(Map<String, dynamic> json) {
    return ShelterModel(
      id: json['id'] as String,
      profileId: json['profile_id'] as String,
      shelterName: json['shelter_name'] as String,
      description: json['description'] as String?,
      address: json['address'] as String,
      city: json['city'] as String,
      country: json['country'] as String? ?? 'Ecuador',
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      phone: json['phone'] as String?,
      website: json['website'] as String?,
      totalPets: json['total_pets'] as int? ?? 0,
      totalAdoptions: json['total_adoptions'] as int? ?? 0,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  /// Convierte el ShelterModel a JSON para Supabase
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'profile_id': profileId,
      'shelter_name': shelterName,
      'description': description,
      'address': address,
      'city': city,
      'country': country,
      'latitude': latitude,
      'longitude': longitude,
      'phone': phone,
      'website': website,
      'total_pets': totalPets,
      'total_adoptions': totalAdoptions,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Crea un ShelterModel desde una entidad Shelter
  factory ShelterModel.fromEntity(Shelter shelter) {
    return ShelterModel(
      id: shelter.id,
      profileId: shelter.profileId,
      shelterName: shelter.shelterName,
      description: shelter.description,
      address: shelter.address,
      city: shelter.city,
      country: shelter.country,
      latitude: shelter.latitude,
      longitude: shelter.longitude,
      phone: shelter.phone,
      website: shelter.website,
      totalPets: shelter.totalPets,
      totalAdoptions: shelter.totalAdoptions,
      createdAt: shelter.createdAt,
      updatedAt: shelter.updatedAt,
    );
  }

  /// Convierte el ShelterModel a una entidad Shelter
  Shelter toEntity() {
    return Shelter(
      id: id,
      profileId: profileId,
      shelterName: shelterName,
      description: description,
      address: address,
      city: city,
      country: country,
      latitude: latitude,
      longitude: longitude,
      phone: phone,
      website: website,
      totalPets: totalPets,
      totalAdoptions: totalAdoptions,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  /// Crea una copia del modelo con campos modificados
  @override
  ShelterModel copyWith({
    String? id,
    String? profileId,
    String? shelterName,
    String? description,
    String? address,
    String? city,
    String? country,
    double? latitude,
    double? longitude,
    String? phone,
    String? website,
    int? totalPets,
    int? totalAdoptions,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ShelterModel(
      id: id ?? this.id,
      profileId: profileId ?? this.profileId,
      shelterName: shelterName ?? this.shelterName,
      description: description ?? this.description,
      address: address ?? this.address,
      city: city ?? this.city,
      country: country ?? this.country,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      phone: phone ?? this.phone,
      website: website ?? this.website,
      totalPets: totalPets ?? this.totalPets,
      totalAdoptions: totalAdoptions ?? this.totalAdoptions,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Crea un ShelterModel vacío/inicial
  factory ShelterModel.empty() {
    return ShelterModel(
      id: '',
      profileId: '',
      shelterName: '',
      address: '',
      city: '',
      country: 'Ecuador',
      latitude: -0.1807,
      longitude: -78.4678,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  /// Crea un ShelterModel para creación (sin ID)
  Map<String, dynamic> toJsonForCreation() {
    return {
      'profile_id': profileId,
      'shelter_name': shelterName,
      'description': description,
      'address': address,
      'city': city,
      'country': country,
      'latitude': latitude,
      'longitude': longitude,
      'phone': phone,
      'website': website,
    };
  }

  /// Crea un ShelterModel para actualización
  Map<String, dynamic> toJsonForUpdate() {
    return {
      'shelter_name': shelterName,
      'description': description,
      'address': address,
      'city': city,
      'country': country,
      'latitude': latitude,
      'longitude': longitude,
      'phone': phone,
      'website': website,
      'updated_at': DateTime.now().toIso8601String(),
    };
  }

  /// Crea un ShelterModel con distancia calculada (para lista de refugios cercanos)
  ShelterModel withDistance(double distance) {
    // Nota: La distancia se puede agregar como metadata, no como campo del modelo
    // Esta implementación es solo ilustrativa
    return this;
  }
}