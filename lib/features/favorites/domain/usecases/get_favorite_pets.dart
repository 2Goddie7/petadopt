import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/favorites_repository.dart';
import '../../../pets/domain/entities/pet.dart';

class GetFavoritePets extends UseCaseWithParams<List<Pet>, GetFavoritePetsParams> {
  final FavoritesRepository repository;

  GetFavoritePets(this.repository);

  @override
  Future<Either<Failure, List<Pet>>> call(GetFavoritePetsParams params) async {
    return await repository.getFavoritePets(params.userId);
  }
}

class GetFavoritePetsParams extends Equatable {
  final String userId;

  const GetFavoritePetsParams({required this.userId});

  @override
  List<Object> get props => [userId];
}
