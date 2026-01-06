import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_favorite_pets.dart';
import '../../domain/usecases/is_favorite.dart';
import '../../domain/usecases/toggle_favorite.dart';
import 'favorites_event.dart';
import 'favorites_state.dart';

class FavoritesBloc extends Bloc<FavoritesEvent, FavoritesState> {
  final GetFavoritePets getFavoritePets;
  final IsFavorite isFavorite;
  final ToggleFavorite toggleFavorite;

  String? _currentUserId;

  FavoritesBloc({
    required this.getFavoritePets,
    required this.isFavorite,
    required this.toggleFavorite,
  }) : super(const FavoritesInitial()) {
    on<LoadFavoritesEvent>(_onLoadFavorites);
    on<ToggleFavoriteEvent>(_onToggleFavorite);
    on<CheckIsFavoriteEvent>(_onCheckIsFavorite);
    on<RefreshFavoritesEvent>(_onRefreshFavorites);
  }

  Future<void> _onLoadFavorites(
    LoadFavoritesEvent event,
    Emitter<FavoritesState> emit,
  ) async {
    emit(const FavoritesLoading());
    _currentUserId = event.userId;

    final result = await getFavoritePets(
      GetFavoritePetsParams(userId: event.userId),
    );

    result.fold(
      (failure) => emit(FavoritesError(message: failure.message)),
      (pets) => emit(FavoritesLoaded(favoritePets: pets)),
    );
  }

  Future<void> _onToggleFavorite(
    ToggleFavoriteEvent event,
    Emitter<FavoritesState> emit,
  ) async {
    emit(FavoriteToggling(petId: event.petId));

    final result = await toggleFavorite(
      ToggleFavoriteParams(userId: event.userId, petId: event.petId),
    );

    result.fold(
      (failure) => emit(FavoritesError(message: failure.message)),
      (_) async {
        // Check new status
        final isFavResult = await isFavorite(
          IsFavoriteParams(userId: event.userId, petId: event.petId),
        );

        isFavResult.fold(
          (failure) => emit(FavoritesError(message: failure.message)),
          (isFav) {
            emit(FavoriteToggled(
              petId: event.petId,
              isFavorite: isFav,
              message: isFav
                  ? 'Agregado a favoritos'
                  : 'Eliminado de favoritos',
            ));

            // Reload favorites if we're on favorites page
            if (_currentUserId != null) {
              add(LoadFavoritesEvent(userId: _currentUserId!));
            }
          },
        );
      },
    );
  }

  Future<void> _onCheckIsFavorite(
    CheckIsFavoriteEvent event,
    Emitter<FavoritesState> emit,
  ) async {
    final result = await isFavorite(
      IsFavoriteParams(userId: event.userId, petId: event.petId),
    );

    result.fold(
      (failure) => emit(FavoritesError(message: failure.message)),
      (isFav) {
        if (state is FavoritesLoaded) {
          final currentState = state as FavoritesLoaded;
          final newStatus = Map<String, bool>.from(currentState.favoriteStatus);
          newStatus[event.petId] = isFav;

          emit(currentState.copyWith(favoriteStatus: newStatus));
        }
      },
    );
  }

  Future<void> _onRefreshFavorites(
    RefreshFavoritesEvent event,
    Emitter<FavoritesState> emit,
  ) async {
    if (_currentUserId != null) {
      add(LoadFavoritesEvent(userId: _currentUserId!));
    }
  }
}
