// ============================================
// IMPLEMENTACIÓN (DATA)
// ============================================

import '../../data/datasources/shelters_remote_data_source.dart';
import '../../data/models/shelter_model.dart';
import '../../../../core/error/exceptions.dart';

class MapRepositoryImpl implements MapRepository {
  final SheltersRemoteDataSource remoteDataSource;

  MapRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, Shelter>> createShelter(Shelter shelter) async {
    try {
      final shelterModel = ShelterModel.fromEntity(shelter);
      final createdModel = await remoteDataSource.createShelter(shelterModel);
      return Right(createdModel.toEntity());
    } on DuplicateException catch (e) {
      return Left(DuplicateFailure(e.message, e.code));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, e.code));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message, e.code));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Shelter>> getShelterById(String shelterId) async {
    try {
      final shelterModel = await remoteDataSource.getShelterById(shelterId);
      return Right(shelterModel.toEntity());
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
  Future<Either<Failure, Shelter>> getShelterByProfileId(String profileId) async {
    try {
      final shelterModel = await remoteDataSource.getShelterByProfileId(profileId);
      return Right(shelterModel.toEntity());
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
  Future<Either<Failure, List<Shelter>>> getAllShelters() async {
    try {
      final shelterModels = await remoteDataSource.getAllShelters();
      final shelters = shelterModels.map((m) => m.toEntity()).toList();
      return Right(shelters);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, e.code));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message, e.code));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Shelter>> updateShelter(Shelter shelter) async {
    try {
      final shelterModel = ShelterModel.fromEntity(shelter);
      final updatedModel = await remoteDataSource.updateShelter(shelterModel);
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
}