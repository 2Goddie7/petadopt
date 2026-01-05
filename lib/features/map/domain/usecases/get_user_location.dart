import 'package:dartz/dartz.dart';
import '../entities/location.dart';
import '../repositories/map_repository.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';

/// Obtiene la ubicación actual del usuario
class GetUserLocation extends UseCase<Location> {
  final MapRepository repository;

  GetUserLocation(this.repository);

  @override
  Future<Either<Failure, Location>> call() async {
    return await repository.getUserLocation();
  }
}