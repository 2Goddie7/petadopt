import 'package:dartz/dartz.dart';
import '../../domain/entities/adoption_request.dart';
import '../../domain/repositories/adoptions_repository.dart';
import '../datasources/adoptions_remote_data_source.dart';
import '../models/adoption_request_model.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/error/exceptions.dart';

class AdoptionsRepositoryImpl implements AdoptionsRepository {
  final AdoptionsRemoteDataSource remoteDataSource;

  AdoptionsRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, AdoptionRequest>> createAdoptionRequest(
    AdoptionRequest request,
  ) async {
    try {
      final requestModel = AdoptionRequestModel.fromEntity(request);
      final createdModel = await remoteDataSource.createAdoptionRequest(requestModel);
      return Right(createdModel.toEntity());
    } on DuplicateException catch (e) {
      return Left(DuplicateFailure(e.message, e.code));
    } on InvalidDataException catch (e) {
      return Left(InvalidDataFailure(e.message, e.code));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, e.code));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message, e.code));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<AdoptionRequest>>> getUserRequests(String userId) async {
    try {
      final requestModels = await remoteDataSource.getUserRequests(userId);
      final requests = requestModels.map((m) => m.toEntity()).toList();
      return Right(requests);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, e.code));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message, e.code));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<AdoptionRequest>>> getShelterRequests(
    String shelterId,
  ) async {
    try {
      final requestModels = await remoteDataSource.getShelterRequests(shelterId);
      final requests = requestModels.map((m) => m.toEntity()).toList();
      return Right(requests);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, e.code));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message, e.code));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, AdoptionRequest>> getRequestById(String requestId) async {
    try {
      final requestModel = await remoteDataSource.getRequestById(requestId);
      return Right(requestModel.toEntity());
    } on NotFoundException catch (e) {
      return Left(NotFoundFailure(e.message, e.code));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, e.code));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message, e.code));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, AdoptionRequest>> approveRequest(String requestId) async {
    try {
      final updatedModel = await remoteDataSource.approveRequest(requestId);
      return Right(updatedModel.toEntity());
    } on NotFoundException catch (e) {
      return Left(NotFoundFailure(e.message, e.code));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, e.code));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message, e.code));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, AdoptionRequest>> rejectRequest(
    String requestId,
    String reason,
  ) async {
    try {
      final updatedModel = await remoteDataSource.rejectRequest(requestId, reason);
      return Right(updatedModel.toEntity());
    } on NotFoundException catch (e) {
      return Left(NotFoundFailure(e.message, e.code));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, e.code));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message, e.code));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> cancelRequest(String requestId) async {
    try {
      await remoteDataSource.cancelRequest(requestId);
      return const Right(null);
    } on NotFoundException catch (e) {
      return Left(NotFoundFailure(e.message, e.code));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, e.code));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message, e.code));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> hasActivePetRequest(
    String userId,
    String petId,
  ) async {
    try {
      final hasRequest = await remoteDataSource.hasActivePetRequest(userId, petId);
      return Right(hasRequest);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, e.code));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message, e.code));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }
}