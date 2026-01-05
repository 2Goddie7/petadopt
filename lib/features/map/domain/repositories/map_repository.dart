import 'package:dartz/dartz.dart';
import '../entities/shelter.dart';
import '../entities/location.dart';
import '../../../../core/error/failures.dart';

/// Contrato del repositorio de mapa y ubicación
abstract class MapRepository {
  /// Obtiene todos los refugios
  Future<Either<Failure, List<Shelter>>> getAllShelters();

  /// Obtiene un refugio por ID
  Future<Either<Failure, Shelter>> getShelterById(String shelterId);

  /// Obtiene un refugio por profile ID
  Future<Either<Failure, Shelter>> getShelterByProfileId(String profileId);

  /// Obtiene refugios cercanos a una ubicación
  Future<Either<Failure, List<Shelter>>> getNearbyShelters(
    double latitude,
    double longitude,
    double radiusKm,
  );

  /// Calcula la distancia entre dos puntos geográficos (en km)
  Future<Either<Failure, double>> calculateDistance(
    double fromLat,
    double fromLon,
    double toLat,
    double toLon,
  );

  /// Obtiene la ubicación actual del usuario
  Future<Either<Failure, Location>> getUserLocation();

  /// Crea un nuevo refugio
  Future<Either<Failure, Shelter>> createShelter(Shelter shelter);

  /// Actualiza un refugio existente
  Future<Either<Failure, Shelter>> updateShelter(Shelter shelter);
}