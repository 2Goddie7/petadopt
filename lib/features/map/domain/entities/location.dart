import 'package:equatable/equatable.dart';

/// Entidad de Ubicación Geográfica
class Location extends Equatable {
  final double latitude;
  final double longitude;
  final String? address;
  final String? city;
  final String? country;
  final DateTime timestamp;

  const Location({
    required this.latitude,
    required this.longitude,
    this.address,
    this.city,
    this.country,
    required this.timestamp,
  });

  /// Crea una copia con campos modificados
  Location copyWith({
    double? latitude,
    double? longitude,
    String? address,
    String? city,
    String? country,
    DateTime? timestamp,
  }) {
    return Location(
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      address: address ?? this.address,
      city: city ?? this.city,
      country: country ?? this.country,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  /// Formatea las coordenadas
  String get coordinatesString {
    return '${latitude.toStringAsFixed(6)}, ${longitude.toStringAsFixed(6)}';
  }

  /// Obtiene la dirección completa
  String get fullAddress {
    final parts = <String>[];
    if (address != null) parts.add(address!);
    if (city != null) parts.add(city!);
    if (country != null) parts.add(country!);
    return parts.isEmpty ? 'Ubicación desconocida' : parts.join(', ');
  }

  /// Verifica si tiene información de dirección
  bool get hasAddress => address != null && address!.isNotEmpty;

  @override
  List<Object?> get props => [
        latitude,
        longitude,
        address,
        city,
        country,
        timestamp,
      ];

  @override
  String toString() {
    return 'Location(lat: $latitude, lon: $longitude, address: ${fullAddress})';
  }
}