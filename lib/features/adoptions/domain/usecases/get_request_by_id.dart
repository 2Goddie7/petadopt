import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/adoption_request.dart';
import '../repositories/adoptions_repository.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';

// ============================================
// GET REQUEST BY ID
// ============================================

class GetRequestById extends UseCaseWithParams<AdoptionRequest, GetRequestByIdParams> {
  final AdoptionsRepository repository;

  GetRequestById(this.repository);

  @override
  Future<Either<Failure, AdoptionRequest>> call(GetRequestByIdParams params) async {
    return await repository.getRequestById(params.requestId);
  }
}

class GetRequestByIdParams extends Equatable {
  final String requestId;

  const GetRequestByIdParams({required this.requestId});

  @override
  List<Object> get props => [requestId];
}