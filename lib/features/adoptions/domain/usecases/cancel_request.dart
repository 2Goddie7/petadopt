import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../repositories/adoptions_repository.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';


// ============================================
// CANCEL REQUEST
// ============================================

class CancelRequest extends UseCaseWithParams<void, CancelRequestParams> {
  final AdoptionsRepository repository;

  CancelRequest(this.repository);

  @override
  Future<Either<Failure, void>> call(CancelRequestParams params) async {
    return await repository.cancelRequest(params.requestId);
  }
}

class CancelRequestParams extends Equatable {
  final String requestId;

  const CancelRequestParams({required this.requestId});

  @override
  List<Object> get props => [requestId];
}