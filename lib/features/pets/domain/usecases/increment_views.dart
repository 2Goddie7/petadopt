import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../domain/repositories/pets_repository.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';

// ============================================
// INCREMENT VIEWS
// ============================================

class IncrementPetViews extends UseCaseWithParams<void, IncrementViewsParams> {
  final PetsRepository repository;

  IncrementPetViews(this.repository);

  @override
  Future<Either<Failure, void>> call(IncrementViewsParams params) async {
    return await repository.incrementViews(params.petId);
  }
}

class IncrementViewsParams extends Equatable {
  final String petId;

  const IncrementViewsParams({required this.petId});

  @override
  List<Object> get props => [petId];
}