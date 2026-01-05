import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/pet.dart';
import '../../domain/repositories/pets_repository.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';

// ============================================
// SEARCH PETS
// ============================================

class SearchPets extends UseCaseWithParams<List<Pet>, SearchPetsParams> {
  final PetsRepository repository;

  SearchPets(this.repository);

  @override
  Future<Either<Failure, List<Pet>>> call(SearchPetsParams params) async {
    return await repository.searchPets(
      species: params.species,
      gender: params.gender,
      size: params.size,
      query: params.query,
    );
  }
}

class SearchPetsParams extends Equatable {
  final String? species;
  final String? gender;
  final String? size;
  final String? query;

  const SearchPetsParams({
    this.species,
    this.gender,
    this.size,
    this.query,
  });

  @override
  List<Object?> get props => [species, gender, size, query];
}