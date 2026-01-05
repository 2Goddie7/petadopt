import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/pet.dart';
import '../../domain/repositories/pets_repository.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';

// ============================================
// CREATE PET
// ============================================

class CreatePet extends UseCaseWithParams<Pet, CreatePetParams> {
  final PetsRepository repository;

  CreatePet(this.repository);

  @override
  Future<Either<Failure, Pet>> call(CreatePetParams params) async {
    return await repository.createPet(params.pet);
  }
}

class CreatePetParams extends Equatable {
  final Pet pet;

  const CreatePetParams({required this.pet});

  @override
  List<Object> get props => [pet];
}