import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/shelter.dart';
import '../../domain/repositories/map_repository.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';

// ============================================
// UPDATE SHELTER
// ============================================

class UpdateShelter extends UseCaseWithParams<Shelter, UpdateShelterParams> {
  final MapRepository repository;

  UpdateShelter(this.repository);

  @override
  Future<Either<Failure, Shelter>> call(UpdateShelterParams params) async {
    return await repository.updateShelter(params.shelter);
  }
}

class UpdateShelterParams extends Equatable {
  final Shelter shelter;

  const UpdateShelterParams({required this.shelter});

  @override
  List<Object> get props => [shelter];
}