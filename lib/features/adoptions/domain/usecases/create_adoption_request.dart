import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/adoption_request.dart';
import '../repositories/adoptions_repository.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';

// ============================================
// CREATE ADOPTION REQUEST
// ============================================

class CreateAdoptionRequest extends UseCaseWithParams<AdoptionRequest, CreateRequestParams> {
  final AdoptionsRepository repository;

  CreateAdoptionRequest(this.repository);

  @override
  Future<Either<Failure, AdoptionRequest>> call(CreateRequestParams params) async {
    return await repository.createAdoptionRequest(params.request);
  }
}

class CreateRequestParams extends Equatable {
  final AdoptionRequest request;

  const CreateRequestParams({required this.request});

  @override
  List<Object> get props => [request];
}