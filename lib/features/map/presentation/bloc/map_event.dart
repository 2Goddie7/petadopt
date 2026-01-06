import 'package:equatable/equatable.dart';
import '../../domain/entities/shelter.dart';

abstract class MapEvent extends Equatable {
  const MapEvent();

  @override
  List<Object?> get props => [];
}

/// Cargar todos los refugios
class LoadAllSheltersEvent extends MapEvent {
  const LoadAllSheltersEvent();
}

/// Cargar refugios cercanos a la ubicación del usuario
class LoadNearbySheltersEvent extends MapEvent {
  final double latitude;
  final double longitude;
  final double radiusKm;

  const LoadNearbySheltersEvent({
    required this.latitude,
    required this.longitude,
    this.radiusKm = 10.0,
  });

  @override
  List<Object?> get props => [latitude, longitude, radiusKm];
}

/// Obtener ubicación del usuario
class GetUserLocationEvent extends MapEvent {
  const GetUserLocationEvent();
}

/// Seleccionar un refugio en el mapa
class SelectShelterEvent extends MapEvent {
  final Shelter? shelter;

  const SelectShelterEvent({this.shelter});

  @override
  List<Object?> get props => [shelter];
}

/// Actualizar la posición del mapa
class UpdateMapPositionEvent extends MapEvent {
  final double latitude;
  final double longitude;
  final double zoom;

  const UpdateMapPositionEvent({
    required this.latitude,
    required this.longitude,
    required this.zoom,
  });

  @override
  List<Object?> get props => [latitude, longitude, zoom];
}
