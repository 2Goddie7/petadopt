import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/pet.dart';
import '../../domain/repositories/pets_repository.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';

// ============================================
// UPDATE PET
// ============================================

class UpdatePet extends UseCaseWithParams<Pet, UpdatePetParams> {
  final PetsRepository repository;

  UpdatePet(this.repository);

  @override
  Future<Either<Failure, Pet>> call(UpdatePetParams params) async {
    return await repository.updatePet(params.pet);
  }
}

class UpdatePetParams extends Equatable {
  final Pet pet;

  const UpdatePetParams({required this.pet});

  @override
  List<Object> get props => [pet];
}