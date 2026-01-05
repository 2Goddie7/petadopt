import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/shelter.dart';
import '../../domain/repositories/map_repository.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';

// ============================================
// CREATE SHELTER
// ============================================

class CreateShelter extends UseCaseWithParams<Shelter, CreateShelterParams> {
  final MapRepository repository;

  CreateShelter(this.repository);

  @override
  Future<Either<Failure, Shelter>> call(CreateShelterParams params) async {
    return await repository.createShelter(params.shelter);
  }
}

class CreateShelterParams extends Equatable {
  final Shelter shelter;

  const CreateShelterParams({required this.shelter});

  @override
  List<Object> get props => [shelter];
}