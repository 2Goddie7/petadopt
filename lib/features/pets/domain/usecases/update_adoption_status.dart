import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/pet.dart';
import '../../domain/repositories/pets_repository.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';

// ============================================
// UPDATE ADOPTION STATUS
// ============================================

class UpdateAdoptionStatus extends UseCaseWithParams<void, UpdateAdoptionStatusParams> {
  final PetsRepository repository;

  UpdateAdoptionStatus(this.repository);

  @override
  Future<Either<Failure, void>> call(UpdateAdoptionStatusParams params) async {
    return await repository.updateAdoptionStatus(params.petId, params.status);
  }
}

class UpdateAdoptionStatusParams extends Equatable {
  final String petId;
  final AdoptionStatus status;

  const UpdateAdoptionStatusParams({
    required this.petId,
    required this.status,
  });

  @override
  List<Object> get props => [petId, status];
}