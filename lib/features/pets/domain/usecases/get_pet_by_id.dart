import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/pet.dart';
import '../../domain/repositories/pets_repository.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';

class GetPetById extends UseCaseWithParams<Pet, GetPetByIdParams> {
  final PetsRepository repository;

  GetPetById(this.repository);

  @override
  Future<Either<Failure, Pet>> call(GetPetByIdParams params) async {
    return await repository.getPetById(params.petId);
  }
}

class GetPetByIdParams extends Equatable {
  final String petId;

  const GetPetByIdParams({required this.petId});

  @override
  List<Object> get props => [petId];
}