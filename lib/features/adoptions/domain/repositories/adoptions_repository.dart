import 'package:dartz/dartz.dart';
import '../entities/adoption_request.dart';
import '../../../../core/error/failures.dart';

abstract class AdoptionsRepository {
  Future<Either<Failure, AdoptionRequest>> createAdoptionRequest(AdoptionRequest request);
  Future<Either<Failure, List<AdoptionRequest>>> getUserRequests(String userId);
  Future<Either<Failure, List<AdoptionRequest>>> getShelterRequests(String shelterId);
  Future<Either<Failure, AdoptionRequest>> getRequestById(String requestId);
  Future<Either<Failure, AdoptionRequest>> approveRequest(String requestId);
  Future<Either<Failure, AdoptionRequest>> rejectRequest(String requestId, String reason);
  Future<Either<Failure, void>> cancelRequest(String requestId);
  Future<Either<Failure, bool>> hasActivePetRequest(String userId, String petId);
}