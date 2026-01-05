import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/adoption_request.dart';
import '../repositories/adoptions_repository.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';

// ============================================
// GET SHELTER REQUESTS
// ============================================

class GetShelterRequests extends UseCaseWithParams<List<AdoptionRequest>, GetShelterRequestsParams> {
  final AdoptionsRepository repository;

  GetShelterRequests(this.repository);

  @override
  Future<Either<Failure, List<AdoptionRequest>>> call(GetShelterRequestsParams params) async {
    return await repository.getShelterRequests(params.shelterId);
  }
}

class GetShelterRequestsParams extends Equatable {
  final String shelterId;

  const GetShelterRequestsParams({required this.shelterId});

  @override
  List<Object> get props => [shelterId];
}