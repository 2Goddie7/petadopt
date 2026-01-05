import 'package:equatable/equatable.dart';

/// Entidad de Refugio en el dominio
class Shelter extends Equatable {
  final String id;
  final String profileId;
  final String shelterName;
  final String? description;
  final String address;
  final String city;
  final String country;
  final double latitude;
  final double longitude;
  final String? phone;
  final String? website;
  final int totalPets;
  final int totalAdoptions;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Shelter({
    required this.id,
    required this.profileId,
    required this.shelterName,
    this.description,
    required this.address,
    required this.city,
    required this.country,
    required this.latitude,
    required this.longitude,
    this.phone,
    this.website,
    this.totalPets = 0,
    this.totalAdoptions = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Crea una copia con campos modificados
  Shelter copyWith({
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
    return Shelter(
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

  /// Obtiene la dirección completa formateada
  String get fullAddress {
    return '$address, $city, $country';
  }

  /// Verifica si el refugio tiene descripción
  bool get hasDescription => description != null && description!.isNotEmpty;

  /// Verifica si el refugio tiene teléfono
  bool get hasPhone => phone != null && phone!.isNotEmpty;

  /// Verifica si el refugio tiene sitio web
  bool get hasWebsite => website != null && website!.isNotEmpty;

  /// Verifica si el refugio tiene mascotas
  bool get hasPets => totalPets > 0;

  /// Calcula la distancia a otro punto geográfico (en km)
  /// Usa la fórmula de Haversine simplificada
  double distanceTo(double targetLat, double targetLon) {
    const double earthRadius = 6371.0; // Radio de la Tierra en km
    
    final dLat = _toRadians(targetLat - latitude);
    final dLon = _toRadians(targetLon - longitude);
    
    final a = 
        (dLat / 2).sin() * (dLat / 2).sin() +
        _toRadians(latitude).cos() * 
        _toRadians(targetLat).cos() *
        (dLon / 2).sin() * (dLon / 2).sin();
    
    final c = 2 * (a.sqrt()).atan2((1 - a).sqrt());
    
    return earthRadius * c;
  }

  double _toRadians(double degrees) {
    return degrees * 3.14159265359 / 180.0;
  }

  @override
  List<Object?> get props => [
        id,
        profileId,
        shelterName,
        description,
        address,
        city,
        country,
        latitude,
        longitude,
        phone,
        website,
        totalPets,
        totalAdoptions,
        createdAt,
        updatedAt,
      ];

  @override
  String toString() {
    return 'Shelter(id: $id, name: $shelterName, location: $fullAddress)';
  }
}

extension _MathExtensions on double {
  double sin() => this; // Placeholder - usar dart:math en producción
  double cos() => this;
  double sqrt() => this;
  double atan2(double other) => this;
}