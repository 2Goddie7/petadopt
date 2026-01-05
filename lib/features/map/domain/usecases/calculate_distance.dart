import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../domain/repositories/map_repository.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';

class CalculateDistance extends UseCaseWithParams<double, CalculateDistanceParams> {
  final MapRepository repository;

  CalculateDistance(this.repository);

  @override
  Future<Either<Failure, double>> call(CalculateDistanceParams params) async {
    return await repository.calculateDistance(
      params.fromLat,
      params.fromLon,
      params.toLat,
      params.toLon,
    );
  }
}

class CalculateDistanceParams extends Equatable {
  final double fromLat;
  final double fromLon;
  final double toLat;
  final double toLon;

  const CalculateDistanceParams({
    required this.fromLat,
    required this.fromLon,
    required this.toLat,
    required this.toLon,
  });

  @override
  List<Object> get props => [fromLat, fromLon, toLat, toLon];
}