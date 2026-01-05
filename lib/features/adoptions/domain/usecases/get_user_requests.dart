import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/adoption_request.dart';
import '../repositories/adoptions_repository.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';

// ============================================
// GET USER REQUESTS
// ============================================

class GetUserRequests extends UseCaseWithParams<List<AdoptionRequest>, GetUserRequestsParams> {
  final AdoptionsRepository repository;

  GetUserRequests(this.repository);

  @override
  Future<Either<Failure, List<AdoptionRequest>>> call(GetUserRequestsParams params) async {
    return await repository.getUserRequests(params.userId);
  }
}

class GetUserRequestsParams extends Equatable {
  final String userId;

  const GetUserRequestsParams({required this.userId});

  @override
  List<Object> get props => [userId];
}