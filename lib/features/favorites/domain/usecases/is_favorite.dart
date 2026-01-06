import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/favorites_repository.dart';

class IsFavorite extends UseCaseWithParams<bool, IsFavoriteParams> {
  final FavoritesRepository repository;

  IsFavorite(this.repository);

  @override
  Future<Either<Failure, bool>> call(IsFavoriteParams params) async {
    return await repository.isFavorite(params.userId, params.petId);
  }
}

class IsFavoriteParams extends Equatable {
  final String userId;
  final String petId;

  const IsFavoriteParams({
    required this.userId,
    required this.petId,
  });

  @override
  List<Object> get props => [userId, petId];
}
