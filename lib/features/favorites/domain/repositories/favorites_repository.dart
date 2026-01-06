import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../pets/domain/entities/pet.dart';

abstract class FavoritesRepository {
  Future<Either<Failure, List<Pet>>> getFavoritePets(String userId);
  Future<Either<Failure, bool>> isFavorite(String userId, String petId);
  Future<Either<Failure, void>> addFavorite(String userId, String petId);
  Future<Either<Failure, void>> removeFavorite(String userId, String petId);
}
