import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/pet.dart';
import '../../domain/usecases/get_all_pets.dart';
import '../../domain/usecases/search_pets.dart';
import 'pets_event.dart';
import 'pets_state.dart';

class PetsBloc extends Bloc<PetsEvent, PetsState> {
  final GetAllPets getAllPets;
  final SearchPets searchPets;

  PetsBloc({
    required this.getAllPets,
    required this.searchPets,
  }) : super(PetsInitial()) {
    on<LoadPetsEvent>(_onLoadPets);
    on<SearchPetsEvent>(_onSearchPets);
    on<RefreshPetsEvent>(_onRefreshPets);
  }

  Future<void> _onLoadPets(
    LoadPetsEvent event,
    Emitter<PetsState> emit,
  ) async {
    emit(PetsLoading());

    final result = await getAllPets.call();

    result.fold(
      (failure) => emit(PetsError(failure.toString())),
      (pets) => emit(PetsLoaded(pets)),
    );
  }

  Future<void> _onSearchPets(
    SearchPetsEvent event,
    Emitter<PetsState> emit,
  ) async {
    emit(PetsLoading());

    // Convertir enums a strings para el repositorio
    String? speciesStr;
    if (event.species != null) {
      speciesStr = event.species == PetSpecies.dog
          ? 'dog'
          : event.species == PetSpecies.cat
              ? 'cat'
              : 'other';
    }

    String? sizeStr;
    if (event.size != null) {
      sizeStr = event.size == PetSize.small
          ? 'small'
          : event.size == PetSize.medium
              ? 'medium'
              : 'large';
    }

    final result = await searchPets.call(SearchPetsParams(
      species: speciesStr,
      size: sizeStr,
      query: event.city,
    ));

    result.fold(
      (failure) => emit(PetsError(failure.toString())),
      (pets) => emit(PetsLoaded(pets)),
    );
  }

  Future<void> _onRefreshPets(
    RefreshPetsEvent event,
    Emitter<PetsState> emit,
  ) async {
    // No mostramos loading en refresh
    final result = await getAllPets.call();

    result.fold(
      (failure) => emit(PetsError(failure.toString())),
      (pets) => emit(PetsLoaded(pets)),
    );
  }
}
