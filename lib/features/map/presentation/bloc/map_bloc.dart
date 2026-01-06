import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_all_shelters.dart';
import '../../domain/usecases/get_nearby_shelters.dart';
import '../../domain/usecases/get_user_location.dart';
import 'map_event.dart';
import 'map_state.dart';

class MapBloc extends Bloc<MapEvent, MapState> {
  final GetAllShelters getAllShelters;
  final GetNearbyShelters getNearbyShelters;
  final GetUserLocation getUserLocation;

  MapBloc({
    required this.getAllShelters,
    required this.getNearbyShelters,
    required this.getUserLocation,
  }) : super(MapInitial()) {
    on<LoadAllSheltersEvent>(_onLoadAllShelters);
    on<LoadNearbySheltersEvent>(_onLoadNearbyShelters);
    on<GetUserLocationEvent>(_onGetUserLocation);
    on<SelectShelterEvent>(_onSelectShelter);
    on<UpdateMapPositionEvent>(_onUpdateMapPosition);
  }

  Future<void> _onLoadAllShelters(
    LoadAllSheltersEvent event,
    Emitter<MapState> emit,
  ) async {
    emit(MapLoading());
    
    final result = await getAllShelters();
    
    result.fold(
      (failure) => emit(MapError(message: failure.message)),
      (shelters) {
        emit(MapLoaded(
          shelters: shelters,
          userLocation: state is MapLoaded
              ? (state as MapLoaded).userLocation
              : null,
        ));
      },
    );
  }

  Future<void> _onLoadNearbyShelters(
    LoadNearbySheltersEvent event,
    Emitter<MapState> emit,
  ) async {
    emit(MapLoading());
    
    final result = await getNearbyShelters(
      GetNearbySheltersParams(
        latitude: event.latitude,
        longitude: event.longitude,
        radiusKm: event.radiusKm,
      ),
    );
    
    result.fold(
      (failure) => emit(MapError(message: failure.message)),
      (shelters) {
        emit(MapLoaded(
          shelters: shelters,
          userLocation: state is MapLoaded
              ? (state as MapLoaded).userLocation
              : null,
        ));
      },
    );
  }

  Future<void> _onGetUserLocation(
    GetUserLocationEvent event,
    Emitter<MapState> emit,
  ) async {
    final currentState = state;
    
    final result = await getUserLocation();
    
    result.fold(
      (failure) {
        // Si hay error de ubicación, solo mostramos los refugios sin filtrar por cercanía
        if (currentState is! MapLoaded) {
          add(const LoadAllSheltersEvent());
        }
      },
      (location) {
        emit(LocationUpdated(location: location));
        
        // Cargar refugios cercanos a la ubicación del usuario
        add(LoadNearbySheltersEvent(
          latitude: location.latitude,
          longitude: location.longitude,
          radiusKm: 50.0, // 50km de radio por defecto
        ));
      },
    );
  }

  void _onSelectShelter(
    SelectShelterEvent event,
    Emitter<MapState> emit,
  ) {
    final currentState = state;
    
    if (currentState is MapLoaded) {
      emit(currentState.copyWith(
        selectedShelter: event.shelter,
        clearSelectedShelter: event.shelter == null,
      ));
    }
  }

  void _onUpdateMapPosition(
    UpdateMapPositionEvent event,
    Emitter<MapState> emit,
  ) {
    // Este evento puede ser útil para tracking pero no cambia el estado por ahora
    // Podría usarse para cargar shelters basados en la vista actual del mapa
  }
}
