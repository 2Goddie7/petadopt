import 'package:dartz/dartz.dart';
import '../../domain/entities/pet.dart';
import '../../domain/repositories/pets_repository.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';

// ============================================
// GET ALL PETS
// ============================================

class GetAllPets extends UseCase<List<Pet>> {
  final PetsRepository repository;

  GetAllPets(this.repository);

  @override
  Future<Either<Failure, List<Pet>>> call() async {
    return await repository.getAllPets();
  }
}