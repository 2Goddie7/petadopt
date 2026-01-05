import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../domain/repositories/pets_repository.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';

// ============================================
// DELETE PET
// ============================================

class DeletePet extends UseCaseWithParams<void, DeletePetParams> {
  final PetsRepository repository;

  DeletePet(this.repository);

  @override
  Future<Either<Failure, void>> call(DeletePetParams params) async {
    return await repository.deletePet(params.petId);
  }
}

class DeletePetParams extends Equatable {
  final String petId;

  const DeletePetParams({required this.petId});

  @override
  List<Object> get props => [petId];
}