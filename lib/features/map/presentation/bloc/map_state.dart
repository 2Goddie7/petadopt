import 'package:equatable/equatable.dart';
import '../../domain/entities/shelter.dart';
import '../../domain/entities/location.dart';

abstract class MapState extends Equatable {
  const MapState();

  @override
  List<Object?> get props => [];
}

class MapInitial extends MapState {}

class MapLoading extends MapState {}

class MapLoaded extends MapState {
  final List<Shelter> shelters;
  final Location? userLocation;
  final Shelter? selectedShelter;

  const MapLoaded({
    required this.shelters,
    this.userLocation,
    this.selectedShelter,
  });

  MapLoaded copyWith({
    List<Shelter>? shelters,
    Location? userLocation,
    Shelter? selectedShelter,
    bool clearSelectedShelter = false,
  }) {
    return MapLoaded(
      shelters: shelters ?? this.shelters,
      userLocation: userLocation ?? this.userLocation,
      selectedShelter: clearSelectedShelter ? null : (selectedShelter ?? this.selectedShelter),
    );
  }

  @override
  List<Object?> get props => [shelters, userLocation, selectedShelter];
}

class LocationUpdated extends MapState {
  final Location location;

  const LocationUpdated({required this.location});

  @override
  List<Object?> get props => [location];
}

class ShelterSelected extends MapState {
  final Shelter shelter;

  const ShelterSelected({required this.shelter});

  @override
  List<Object?> get props => [shelter];
}

class MapError extends MapState {
  final String message;

  const MapError({required this.message});

  @override
  List<Object?> get props => [message];
}
