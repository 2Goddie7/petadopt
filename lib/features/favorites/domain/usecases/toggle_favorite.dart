import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/favorites_repository.dart';

class ToggleFavorite extends UseCaseWithParams<void, ToggleFavoriteParams> {
  final FavoritesRepository repository;

  ToggleFavorite(this.repository);

  @override
  Future<Either<Failure, void>> call(ToggleFavoriteParams params) async {
    final isFavResult = await repository.isFavorite(params.userId, params.petId);
    
    return isFavResult.fold(
      (failure) => Left(failure),
      (isFavorite) async {
        if (isFavorite) {
          return await repository.removeFavorite(params.userId, params.petId);
        } else {
          return await repository.addFavorite(params.userId, params.petId);
        }
      },
    );
  }
}

class ToggleFavoriteParams extends Equatable {
  final String userId;
  final String petId;

  const ToggleFavoriteParams({
    required this.userId,
    required this.petId,
  });

  @override
  List<Object> get props => [userId, petId];
}
