import 'package:equatable/equatable.dart';

abstract class FavoritesEvent extends Equatable {
  const FavoritesEvent();

  @override
  List<Object?> get props => [];
}

class LoadFavoritesEvent extends FavoritesEvent {
  final String userId;

  const LoadFavoritesEvent({required this.userId});

  @override
  List<Object?> get props => [userId];
}

class ToggleFavoriteEvent extends FavoritesEvent {
  final String userId;
  final String petId;

  const ToggleFavoriteEvent({
    required this.userId,
    required this.petId,
  });

  @override
  List<Object?> get props => [userId, petId];
}

class CheckIsFavoriteEvent extends FavoritesEvent {
  final String userId;
  final String petId;

  const CheckIsFavoriteEvent({
    required this.userId,
    required this.petId,
  });

  @override
  List<Object?> get props => [userId, petId];
}

class RefreshFavoritesEvent extends FavoritesEvent {
  const RefreshFavoritesEvent();
}
