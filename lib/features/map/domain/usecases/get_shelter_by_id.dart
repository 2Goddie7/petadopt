import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/shelter.dart';
import '../../domain/repositories/map_repository.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';

// ============================================
// GET SHELTER BY ID
// ============================================

class GetShelterById extends UseCaseWithParams<Shelter, GetShelterByIdParams> {
  final MapRepository repository;

  GetShelterById(this.repository);

  @override
  Future<Either<Failure, Shelter>> call(GetShelterByIdParams params) async {
    return await repository.getShelterById(params.shelterId);
  }
}

class GetShelterByIdParams extends Equatable {
  final String shelterId;

  const GetShelterByIdParams({required this.shelterId});

  @override
  List<Object> get props => [shelterId];
}