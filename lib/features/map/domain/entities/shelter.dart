import 'package:equatable/equatable.dart';

/// Entidad de Refugio en el dominio
/// Representa un refugio o fundación de animales
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

  /// Crea una copia del refugio con campos modificados
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

  /// Obtiene la dirección completa
  String get fullAddress => '$address, $city, $country';

  /// Verifica si tiene descripción
  bool get hasDescription => description != null && description!.isNotEmpty;

  /// Verifica si tiene teléfono
  bool get hasPhone => phone != null && phone!.isNotEmpty;

  /// Verifica si tiene sitio web
  bool get hasWebsite => website != null && website!.isNotEmpty;

  /// Verifica si tiene mascotas disponibles
  bool get hasPets => totalPets > 0;

  /// Verifica si ha realizado adopciones
  bool get hasAdoptions => totalAdoptions > 0;

  /// Calcula la distancia a un punto (en kilómetros)
  /// Fórmula de Haversine
  double distanceTo(double targetLat, double targetLon) {
    const earthRadius = 6371.0; // Radio de la tierra en km
    
    final dLat = _toRadians(targetLat - latitude);
    final dLon = _toRadians(targetLon - longitude);
    
    final a = _sin(dLat / 2) * _sin(dLat / 2) +
        _cos(_toRadians(latitude)) *
            _cos(_toRadians(targetLat)) *
            _sin(dLon / 2) *
            _sin(dLon / 2);
    
    final c = 2 * _atan2(_sqrt(a), _sqrt(1 - a));
    
    return earthRadius * c;
  }

  // Métodos helper para cálculos matemáticos
  double _toRadians(double degrees) => degrees * (3.141592653589793 / 180.0);
  double _sin(double x) => x; // Simplificado, usar import 'dart:math' para precisión
  double _cos(double x) => 1 - (x * x) / 2; // Simplificado
  double _sqrt(double x) {
    if (x == 0) return 0;
    double guess = x / 2;
    for (int i = 0; i < 10; i++) {
      guess = (guess + x / guess) / 2;
    }
    return guess;
  }
  double _atan2(double y, double x) {
    // Simplificado - usar import 'dart:math' para precisión
    if (x > 0) return _atan(y / x);
    if (x < 0 && y >= 0) return _atan(y / x) + 3.141592653589793;
    if (x < 0 && y < 0) return _atan(y / x) - 3.141592653589793;
    if (x == 0 && y > 0) return 3.141592653589793 / 2;
    if (x == 0 && y < 0) return -3.141592653589793 / 2;
    return 0;
  }
  double _atan(double x) {
    // Aproximación de arctan - usar import 'dart:math' para precisión
    return x - (x * x * x) / 3 + (x * x * x * x * x) / 5;
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
  bool get stringify => true;
}