import 'package:equatable/equatable.dart';

abstract class PetDetailEvent extends Equatable {
  const PetDetailEvent();

  @override
  List<Object?> get props => [];
}

/// Cargar detalles de una mascota
class LoadPetDetailEvent extends PetDetailEvent {
  final String petId;

  const LoadPetDetailEvent({required this.petId});

  @override
  List<Object?> get props => [petId];
}

/// Incrementar contador de vistas
class IncrementPetViewsEvent extends PetDetailEvent {
  final String petId;

  const IncrementPetViewsEvent({required this.petId});

  @override
  List<Object?> get props => [petId];
}

/// Refrescar detalles
class RefreshPetDetailEvent extends PetDetailEvent {
  const RefreshPetDetailEvent();
}

/// Eliminar mascota
class DeletePetEvent extends PetDetailEvent {
  final String petId;

  const DeletePetEvent({required this.petId});

  @override
  List<Object?> get props => [petId];
}
