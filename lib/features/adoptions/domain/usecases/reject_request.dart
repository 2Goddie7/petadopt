import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/adoption_request.dart';
import '../repositories/adoptions_repository.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';

// ============================================
// REJECT REQUEST
// ============================================

class RejectRequest extends UseCaseWithParams<AdoptionRequest, RejectRequestParams> {
  final AdoptionsRepository repository;

  RejectRequest(this.repository);

  @override
  Future<Either<Failure, AdoptionRequest>> call(RejectRequestParams params) async {
    return await repository.rejectRequest(params.requestId, params.reason);
  }
}

class RejectRequestParams extends Equatable {
  final String requestId;
  final String reason;

  const RejectRequestParams({
    required this.requestId,
    required this.reason,
  });

  @override
  List<Object> get props => [requestId, reason];
}