import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/shelter.dart';
import '../../domain/repositories/map_repository.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
// ============================================
// GET SHELTER BY PROFILE ID
// ============================================

class GetShelterByProfileId extends UseCaseWithParams<Shelter, GetShelterByProfileIdParams> {
  final MapRepository repository;

  GetShelterByProfileId(this.repository);

  @override
  Future<Either<Failure, Shelter>> call(GetShelterByProfileIdParams params) async {
    return await repository.getShelterByProfileId(params.profileId);
  }
}

class GetShelterByProfileIdParams extends Equatable {
  final String profileId;

  const GetShelterByProfileIdParams({required this.profileId});

  @override
  List<Object> get props => [profileId];
}