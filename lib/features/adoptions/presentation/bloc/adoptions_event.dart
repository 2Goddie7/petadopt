import 'package:equatable/equatable.dart';

abstract class AdoptionsEvent extends Equatable {
  const AdoptionsEvent();

  @override
  List<Object?> get props => [];
}

/// Cargar mis solicitudes como adoptante
class LoadMyRequestsEvent extends AdoptionsEvent {
  final String userId;

  const LoadMyRequestsEvent({required this.userId});

  @override
  List<Object?> get props => [userId];
}

/// Cargar solicitudes recibidas como refugio
class LoadShelterRequestsEvent extends AdoptionsEvent {
  final String shelterId;

  const LoadShelterRequestsEvent({required this.shelterId});

  @override
  List<Object?> get props => [shelterId];
}

/// Crear nueva solicitud de adopción
class CreateAdoptionRequestEvent extends AdoptionsEvent {
  final String petId;
  final String message;

  const CreateAdoptionRequestEvent({
    required this.petId,
    required this.message,
  });

  @override
  List<Object?> get props => [petId, message];
}

/// Aprobar solicitud (solo refugios)
class ApproveRequestEvent extends AdoptionsEvent {
  final String requestId;

  const ApproveRequestEvent({required this.requestId});

  @override
  List<Object?> get props => [requestId];
}

/// Rechazar solicitud (solo refugios)
class RejectRequestEvent extends AdoptionsEvent {
  final String requestId;
  final String reason;

  const RejectRequestEvent({
    required this.requestId,
    required this.reason,
  });

  @override
  List<Object?> get props => [requestId, reason];
}

/// Cancelar solicitud (adoptante)
class CancelRequestEvent extends AdoptionsEvent {
  final String requestId;

  const CancelRequestEvent({required this.requestId});

  @override
  List<Object?> get props => [requestId];
}

/// Refrescar lista
class RefreshAdoptionsEvent extends AdoptionsEvent {
  final String userId;
  final bool isShelter;

  const RefreshAdoptionsEvent({
    required this.userId,
    required this.isShelter,
  });

  @override
  List<Object?> get props => [userId, isShelter];
}
