import 'package:geolocator/geolocator.dart';
import 'dart:math' as math;

/// Helper para manejo de ubicación geográfica
class LocationHelper {
  // Prevenir instanciación
  LocationHelper._();

  // ============================================
  // PERMISSIONS
  // ============================================
  
  /// Verifica y solicita permisos de ubicación
  static Future<bool> checkAndRequestPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Verificar si el servicio de ubicación está habilitado
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return false;
    }

    // Verificar permisos
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return false;
    }

    return true;
  }

  // ============================================
  // GET LOCATION
  // ============================================
  
  /// Obtiene la ubicación actual del usuario
  static Future<Position?> getCurrentLocation() async {
    try {
      final hasPermission = await checkAndRequestPermission();
      if (!hasPermission) return null;

      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
    } catch (e) {
      print('Error getting current location: $e');
      return null;
    }
  }

  // ============================================
  // DISTANCE CALCULATION
  // ============================================
  
  /// Calcula la distancia entre dos puntos geográficos en kilómetros
  /// Usa la fórmula de Haversine
  static double calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const earthRadius = 6371.0; // Radio de la Tierra en km
    
    final dLat = _toRadians(lat2 - lat1);
    final dLon = _toRadians(lon2 - lon1);
    
    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_toRadians(lat1)) *
            math.cos(_toRadians(lat2)) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);
    
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    
    return earthRadius * c;
  }
  
  /// Convierte grados a radianes
  static double _toRadians(double degrees) {
    return degrees * (math.pi / 180.0);
  }

  // ============================================
  // FORMATTING
  // ============================================
  
  /// Formatea la distancia de manera legible
  /// Ejemplos: "1.5 km", "500 m", "25 km"
  static String formatDistance(double distanceKm) {
    if (distanceKm < 1) {
      final meters = (distanceKm * 1000).round();
      return '$meters m';
    } else if (distanceKm < 10) {
      return '${distanceKm.toStringAsFixed(1)} km';
    } else {
      return '${distanceKm.round()} km';
    }
  }
  
  /// Formatea coordenadas
  /// Ejemplo: "-0.1807, -78.4678"
  static String formatCoordinates(double lat, double lon) {
    return '${lat.toStringAsFixed(4)}, ${lon.toStringAsFixed(4)}';
  }

  // ============================================
  // LOCATION STREAM
  // ============================================
  
  /// Obtiene un stream de ubicación en tiempo real
  static Stream<Position> getLocationStream() {
    return Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10, // Actualizar cada 10 metros
      ),
    );
  }

  // ============================================
  // BOUNDS
  // ============================================
  
  /// Calcula los límites geográficos para un punto y radio dado
  /// Útil para queries de "refugios cercanos"
  static Map<String, double> getBoundsForRadius(
    double centerLat,
    double centerLon,
    double radiusKm,
  ) {
    // Aproximación simple (suficiente para la mayoría de casos)
    final latDelta = radiusKm / 111.32; // 1 grado lat ≈ 111.32 km
    final lonDelta = radiusKm / (111.32 * math.cos(_toRadians(centerLat)));
    
    return {
      'minLat': centerLat - latDelta,
      'maxLat': centerLat + latDelta,
      'minLon': centerLon - lonDelta,
      'maxLon': centerLon + lonDelta,
    };
  }

  // ============================================
  // DEFAULT LOCATIONS
  // ============================================
  
  /// Ubicación por defecto (Quito, Ecuador)
  static const double defaultLatitude = -0.1807;
  static const double defaultLongitude = -78.4678;
  
  /// Obtiene la ubicación por defecto
  static Position getDefaultLocation() {
    return Position(
      latitude: defaultLatitude,
      longitude: defaultLongitude,
      timestamp: DateTime.now(),
      accuracy: 0,
      altitude: 0,
      heading: 0,
      speed: 0,
      speedAccuracy: 0,
      altitudeAccuracy: 0,
      headingAccuracy: 0,
    );
  }
}