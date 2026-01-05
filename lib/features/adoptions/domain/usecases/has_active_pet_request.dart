import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/adoption_request.dart';
import '../repositories/adoptions_repository.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';

// ============================================
// HAS ACTIVE PET REQUEST
// ============================================

class HasActivePetRequest extends UseCaseWithParams<bool, HasActiveRequestParams> {
  final AdoptionsRepository repository;

  HasActivePetRequest(this.repository);

  @override
  Future<Either<Failure, bool>> call(HasActiveRequestParams params) async {
    return await repository.hasActivePetRequest(params.userId, params.petId);
  }
}

class HasActiveRequestParams extends Equatable {
  final String userId;
  final String petId;

  const HasActiveRequestParams({
    required this.userId,
    required this.petId,
  });

  @override
  List<Object> get props => [userId, petId];
}