import 'package:dartz/dartz.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:math' as math;
import '../../domain/entities/shelter.dart';
import '../../domain/entities/location.dart';
import '../../domain/repositories/map_repository.dart';
import '../datasources/shelters_remote_data_source.dart';
import '../models/shelter_model.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/error/exceptions.dart';

class MapRepositoryImpl implements MapRepository {
  final SheltersRemoteDataSource remoteDataSource;

  MapRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<Shelter>>> getAllShelters() async {
    try {
      final shelterModels = await remoteDataSource.getAllShelters();
      final shelters = shelterModels.map((m) => m.toEntity()).toList();
      return Right(shelters);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, e.code));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message, e.code));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Shelter>> getShelterById(String shelterId) async {
    try {
      final shelterModel = await remoteDataSource.getShelterById(shelterId);
      return Right(shelterModel.toEntity());
    } on NotFoundException catch (e) {
      return Left(NotFoundFailure(e.message, e.code));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, e.code));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message, e.code));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Shelter>> getShelterByProfileId(String profileId) async {
    try {
      final shelterModel = await remoteDataSource.getShelterByProfileId(profileId);
      return Right(shelterModel.toEntity());
    } on NotFoundException catch (e) {
      return Left(NotFoundFailure(e.message, e.code));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, e.code));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message, e.code));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Shelter>>> getNearbyShelters(
    double latitude,
    double longitude,
    double radiusKm,
  ) async {
    try {
      // Obtener todos los refugios
      final shelterModels = await remoteDataSource.getAllShelters();
      
      // Filtrar por distancia
      final nearbyShelters = shelterModels.where((model) {
        final shelter = model.toEntity();
        final distance = _calculateDistance(
          latitude,
          longitude,
          shelter.latitude,
          shelter.longitude,
        );
        return distance <= radiusKm;
      }).toList();

      // Ordenar por distancia (más cercanos primero)
      nearbyShelters.sort((a, b) {
        final distA = _calculateDistance(
          latitude,
          longitude,
          a.latitude,
          a.longitude,
        );
        final distB = _calculateDistance(
          latitude,
          longitude,
          b.latitude,
          b.longitude,
        );
        return distA.compareTo(distB);
      });

      final shelters = nearbyShelters.map((m) => m.toEntity()).toList();
      return Right(shelters);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, e.code));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message, e.code));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, double>> calculateDistance(
    double fromLat,
    double fromLon,
    double toLat,
    double toLon,
  ) async {
    try {
      final distance = _calculateDistance(fromLat, fromLon, toLat, toLon);
      return Right(distance);
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Location>> getUserLocation() async {
    try {
      // Verificar permisos
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return Left(LocationPermissionFailure(
          'El servicio de ubicación está deshabilitado',
        ));
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return Left(LocationPermissionFailure(
            'Permisos de ubicación denegados',
          ));
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return Left(LocationPermissionFailure(
          'Permisos de ubicación denegados permanentemente',
        ));
      }

      // Obtener ubicación
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      final location = Location(
        latitude: position.latitude,
        longitude: position.longitude,
        timestamp: position.timestamp ?? DateTime.now(),
      );

      return Right(location);
    } on LocationServiceDisabledException {
      return Left(LocationPermissionFailure(
        'Servicio de ubicación deshabilitado',
      ));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Shelter>> createShelter(Shelter shelter) async {
    try {
      final shelterModel = ShelterModel.fromEntity(shelter);
      final createdModel = await remoteDataSource.createShelter(shelterModel);
      return Right(createdModel.toEntity());
    } on DuplicateException catch (e) {
      return Left(DuplicateFailure(e.message, e.code));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, e.code));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message, e.code));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Shelter>> updateShelter(Shelter shelter) async {
    try {
      final shelterModel = ShelterModel.fromEntity(shelter);
      final updatedModel = await remoteDataSource.updateShelter(shelterModel);
      return Right(updatedModel.toEntity());
    } on NotFoundException catch (e) {
      return Left(NotFoundFailure(e.message, e.code));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, e.code));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message, e.code));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  /// Calcula la distancia usando la fórmula de Haversine
  double _calculateDistance(
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

  double _toRadians(double degrees) {
    return degrees * math.pi / 180.0;
  }
}