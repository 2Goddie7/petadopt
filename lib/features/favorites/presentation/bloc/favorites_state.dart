import 'package:equatable/equatable.dart';
import '../../../pets/domain/entities/pet.dart';

abstract class FavoritesState extends Equatable {
  const FavoritesState();

  @override
  List<Object?> get props => [];
}

class FavoritesInitial extends FavoritesState {
  const FavoritesInitial();
}

class FavoritesLoading extends FavoritesState {
  const FavoritesLoading();
}

class FavoritesLoaded extends FavoritesState {
  final List<Pet> favoritePets;
  final Map<String, bool> favoriteStatus;

  const FavoritesLoaded({
    required this.favoritePets,
    this.favoriteStatus = const {},
  });

  @override
  List<Object?> get props => [favoritePets, favoriteStatus];

  FavoritesLoaded copyWith({
    List<Pet>? favoritePets,
    Map<String, bool>? favoriteStatus,
  }) {
    return FavoritesLoaded(
      favoritePets: favoritePets ?? this.favoritePets,
      favoriteStatus: favoriteStatus ?? this.favoriteStatus,
    );
  }
}

class FavoriteToggling extends FavoritesState {
  final String petId;

  const FavoriteToggling({required this.petId});

  @override
  List<Object?> get props => [petId];
}

class FavoriteToggled extends FavoritesState {
  final String petId;
  final bool isFavorite;
  final String message;

  const FavoriteToggled({
    required this.petId,
    required this.isFavorite,
    required this.message,
  });

  @override
  List<Object?> get props => [petId, isFavorite, message];
}

class FavoritesError extends FavoritesState {
  final String message;

  const FavoritesError({required this.message});

  @override
  List<Object?> get props => [message];
}
