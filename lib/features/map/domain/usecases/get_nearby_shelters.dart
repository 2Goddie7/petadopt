import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../entities/shelter.dart';
import '../repositories/map_repository.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';

class GetNearbyShelters extends UseCaseWithParams<List<Shelter>, GetNearbySheltersParams> {
  final MapRepository repository;

  GetNearbyShelters(this.repository);

  @override
  Future<Either<Failure, List<Shelter>>> call(GetNearbySheltersParams params) async {
    return await repository.getNearbyShelters(
      params.latitude,
      params.longitude,
      params.radiusKm,
    );
  }
}

class GetNearbySheltersParams extends Equatable {
  final double latitude;
  final double longitude;
  final double radiusKm;

  const GetNearbySheltersParams({
    required this.latitude,
    required this.longitude,
    this.radiusKm = 50.0, // Radio por defecto: 50km
  });

  @override
  List<Object> get props => [latitude, longitude, radiusKm];
}