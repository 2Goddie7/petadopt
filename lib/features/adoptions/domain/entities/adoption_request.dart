import 'package:equatable/equatable.dart';

/// Entidad de Solicitud de Adopción en el dominio
/// Representa una solicitud de un adoptante para adoptar una mascota
class AdoptionRequest extends Equatable {
  final String id;
  final String petId;
  final String adopterId;
  final String shelterId;
  final String? message;
  final RequestStatus status;
  final String? rejectionReason;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? reviewedAt;
  
  // Información adicional (opcional, puede venir del join)
  final String? petName;
  final String? petSpecies;
  final String? petBreed;
  final String? petImageUrl;
  final String? adopterName;
  final String? adopterEmail;
  final String? adopterPhone;
  final String? shelterName;

  const AdoptionRequest({
    required this.id,
    required this.petId,
    required this.adopterId,
    required this.shelterId,
    this.message,
    this.status = RequestStatus.pending,
    this.rejectionReason,
    required this.createdAt,
    required this.updatedAt,
    this.reviewedAt,
    this.petName,
    this.petSpecies,
    this.petBreed,
    this.petImageUrl,
    this.adopterName,
    this.adopterEmail,
    this.adopterPhone,
    this.shelterName,
  });

  /// Crea una copia de la solicitud con campos modificados
  AdoptionRequest copyWith({
    String? id,
    String? petId,
    String? adopterId,
    String? shelterId,
    String? message,
    RequestStatus? status,
    String? rejectionReason,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? reviewedAt,
    String? petName,
    String? petSpecies,
    String? petBreed,
    String? petImageUrl,
    String? adopterName,
    String? adopterEmail,
    String? adopterPhone,
    String? shelterName,
  }) {
    return AdoptionRequest(
      id: id ?? this.id,
      petId: petId ?? this.petId,
      adopterId: adopterId ?? this.adopterId,
      shelterId: shelterId ?? this.shelterId,
      message: message ?? this.message,
      status: status ?? this.status,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      reviewedAt: reviewedAt ?? this.reviewedAt,
      petName: petName ?? this.petName,
      petSpecies: petSpecies ?? this.petSpecies,
      petBreed: petBreed ?? this.petBreed,
      petImageUrl: petImageUrl ?? this.petImageUrl,
      adopterName: adopterName ?? this.adopterName,
      adopterEmail: adopterEmail ?? this.adopterEmail,
      adopterPhone: adopterPhone ?? this.adopterPhone,
      shelterName: shelterName ?? this.shelterName,
    );
  }

  /// Verifica si la solicitud está pendiente
  bool get isPending => status == RequestStatus.pending;

  /// Verifica si la solicitud fue aprobada
  bool get isApproved => status == RequestStatus.approved;

  /// Verifica si la solicitud fue rechazada
  bool get isRejected => status == RequestStatus.rejected;

  /// Verifica si la solicitud fue revisada
  bool get isReviewed => reviewedAt != null;

  /// Verifica si tiene mensaje del adoptante
  bool get hasMessage => message != null && message!.isNotEmpty;

  /// Verifica si tiene razón de rechazo
  bool get hasRejectionReason => rejectionReason != null && rejectionReason!.isNotEmpty;

  /// Calcula días desde que se creó la solicitud
  int get daysSinceCreation {
    final now = DateTime.now();
    return now.difference(createdAt).inDays;
  }

  /// Calcula días desde que fue revisada (si fue revisada)
  int? get daysSinceReview {
    if (reviewedAt == null) return null;
    final now = DateTime.now();
    return now.difference(reviewedAt!).inDays;
  }

  /// Obtiene el nombre de la mascota o "Mascota" por defecto
  String get displayPetName => petName ?? 'Mascota';

  /// Obtiene información de la mascota en formato legible
  String get petInfo {
    if (petBreed != null && petSpecies != null) {
      return '$petBreed - $petSpecies';
    } else if (petBreed != null) {
      return petBreed!;
    } else if (petSpecies != null) {
      return petSpecies!;
    }
    return 'Información no disponible';
  }

  /// Verifica si tiene información completa de la mascota
  bool get hasPetInfo => petName != null && petBreed != null && petSpecies != null;

  /// Verifica si tiene información completa del adoptante
  bool get hasAdopterInfo => adopterName != null && adopterEmail != null;

  @override
  List<Object?> get props => [
        id,
        petId,
        adopterId,
        shelterId,
        message,
        status,
        rejectionReason,
        createdAt,
        updatedAt,
        reviewedAt,
        petName,
        petSpecies,
        petBreed,
        petImageUrl,
        adopterName,
        adopterEmail,
        adopterPhone,
        shelterName,
      ];

  @override
  bool get stringify => true;
}

/// Estado de la solicitud de adopción
enum RequestStatus {
  pending,
  approved,
  rejected;

  String toJson() {
    switch (this) {
      case RequestStatus.pending:
        return 'pending';
      case RequestStatus.approved:
        return 'approved';
      case RequestStatus.rejected:
        return 'rejected';
    }
  }

  static RequestStatus fromJson(String value) {
    switch (value.toLowerCase()) {
      case 'pending':
      case 'pendiente':
        return RequestStatus.pending;
      case 'approved':
      case 'aprobada':
      case 'aprobado':
        return RequestStatus.approved;
      case 'rejected':
      case 'rechazada':
      case 'rechazado':
        return RequestStatus.rejected;
      default:
        throw ArgumentError('Invalid request status: $value');
    }
  }

  String get displayName {
    switch (this) {
      case RequestStatus.pending:
        return 'Pendiente';
      case RequestStatus.approved:
        return 'Aprobada';
      case RequestStatus.rejected:
        return 'Rechazada';
    }
  }

  String get emoji {
    switch (this) {
      case RequestStatus.pending:
        return '⏳';
      case RequestStatus.approved:
        return '✅';
      case RequestStatus.rejected:
        return '❌';
    }
  }

  /// Indica si es un estado final (no se puede cambiar)
  bool get isFinal {
    return this == RequestStatus.approved || this == RequestStatus.rejected;
  }

  /// Indica si se puede cancelar
  bool get canBeCancelled {
    return this == RequestStatus.pending;
  }
}