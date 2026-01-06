import 'package:dartz/dartz.dart';
import '../../domain/repositories/favorites_repository.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/error/exceptions.dart';
import '../datasources/favorites_remote_data_source.dart';
import '../../../pets/domain/entities/pet.dart';

class FavoritesRepositoryImpl implements FavoritesRepository {
  final FavoritesRemoteDataSource remoteDataSource;

  FavoritesRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<Pet>>> getFavoritePets(String userId) async {
    try {
      final pets = await remoteDataSource.getFavoritePets(userId);
      return Right(pets);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> isFavorite(String userId, String petId) async {
    try {
      final isFav = await remoteDataSource.isFavorite(userId, petId);
      return Right(isFav);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> addFavorite(String userId, String petId) async {
    try {
      await remoteDataSource.addFavorite(userId, petId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> removeFavorite(
      String userId, String petId) async {
    try {
      await remoteDataSource.removeFavorite(userId, petId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
