import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/pet.dart';
import '../../domain/repositories/pets_repository.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';

// ============================================
// GET PETS BY SHELTER
// ============================================

class GetPetsByShelter extends UseCaseWithParams<List<Pet>, GetPetsByShelterParams> {
  final PetsRepository repository;

  GetPetsByShelter(this.repository);

  @override
  Future<Either<Failure, List<Pet>>> call(GetPetsByShelterParams params) async {
    return await repository.getPetsByShelter(params.shelterId);
  }
}

class GetPetsByShelterParams extends Equatable {
  final String shelterId;

  const GetPetsByShelterParams({required this.shelterId});

  @override
  List<Object> get props => [shelterId];
}