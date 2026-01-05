import '../../domain/entities/adoption_request.dart';

/// Modelo de Solicitud de Adopción para la capa de datos
/// Extiende la entidad AdoptionRequest y agrega serialización JSON
class AdoptionRequestModel extends AdoptionRequest {
  const AdoptionRequestModel({
    required super.id,
    required super.petId,
    required super.adopterId,
    required super.shelterId,
    super.message,
    super.status,
    super.rejectionReason,
    required super.createdAt,
    required super.updatedAt,
    super.reviewedAt,
    super.petName,
    super.petSpecies,
    super.petBreed,
    super.petImageUrl,
    super.adopterName,
    super.adopterEmail,
    super.adopterPhone,
    super.shelterName,
  });

  /// Crea un AdoptionRequestModel desde JSON (Supabase)
  factory AdoptionRequestModel.fromJson(Map<String, dynamic> json) {
    return AdoptionRequestModel(
      id: json['id'] as String,
      petId: json['pet_id'] as String,
      adopterId: json['adopter_id'] as String,
      shelterId: json['shelter_id'] as String,
      message: json['message'] as String?,
      status: RequestStatus.fromJson(json['status'] as String? ?? 'pending'),
      rejectionReason: json['rejection_reason'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      reviewedAt: json['reviewed_at'] != null
          ? DateTime.parse(json['reviewed_at'] as String)
          : null,
      petName: json['pet_name'] as String?,
      petSpecies: json['pet_species'] as String?,
      petBreed: json['pet_breed'] as String?,
      petImageUrl: json['pet_image_url'] as String?,
      adopterName: json['adopter_name'] as String?,
      adopterEmail: json['adopter_email'] as String?,
      adopterPhone: json['adopter_phone'] as String?,
      shelterName: json['shelter_name'] as String?,
    );
  }

  /// Convierte el AdoptionRequestModel a JSON para Supabase
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'pet_id': petId,
      'adopter_id': adopterId,
      'shelter_id': shelterId,
      'message': message,
      'status': status.toJson(),
      'rejection_reason': rejectionReason,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'reviewed_at': reviewedAt?.toIso8601String(),
    };
  }

  /// Crea un AdoptionRequestModel desde una entidad AdoptionRequest
  factory AdoptionRequestModel.fromEntity(AdoptionRequest request) {
    return AdoptionRequestModel(
      id: request.id,
      petId: request.petId,
      adopterId: request.adopterId,
      shelterId: request.shelterId,
      message: request.message,
      status: request.status,
      rejectionReason: request.rejectionReason,
      createdAt: request.createdAt,
      updatedAt: request.updatedAt,
      reviewedAt: request.reviewedAt,
      petName: request.petName,
      petSpecies: request.petSpecies,
      petBreed: request.petBreed,
      petImageUrl: request.petImageUrl,
      adopterName: request.adopterName,
      adopterEmail: request.adopterEmail,
      adopterPhone: request.adopterPhone,
      shelterName: request.shelterName,
    );
  }

  /// Convierte el AdoptionRequestModel a una entidad AdoptionRequest
  AdoptionRequest toEntity() {
    return AdoptionRequest(
      id: id,
      petId: petId,
      adopterId: adopterId,
      shelterId: shelterId,
      message: message,
      status: status,
      rejectionReason: rejectionReason,
      createdAt: createdAt,
      updatedAt: updatedAt,
      reviewedAt: reviewedAt,
      petName: petName,
      petSpecies: petSpecies,
      petBreed: petBreed,
      petImageUrl: petImageUrl,
      adopterName: adopterName,
      adopterEmail: adopterEmail,
      adopterPhone: adopterPhone,
      shelterName: shelterName,
    );
  }

  /// Crea una copia del modelo con campos modificados
  @override
  AdoptionRequestModel copyWith({
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
    return AdoptionRequestModel(
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

  /// Crea un AdoptionRequestModel vacío/inicial
  factory AdoptionRequestModel.empty() {
    return AdoptionRequestModel(
      id: '',
      petId: '',
      adopterId: '',
      shelterId: '',
      status: RequestStatus.pending,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  /// Crea un AdoptionRequestModel para creación (sin ID)
  Map<String, dynamic> toJsonForCreation() {
    return {
      'pet_id': petId,
      'adopter_id': adopterId,
      'shelter_id': shelterId,
      'message': message,
      'status': status.toJson(),
    };
  }

  /// Crea un AdoptionRequestModel para actualización de estado
  Map<String, dynamic> toJsonForStatusUpdate() {
    return {
      'status': status.toJson(),
      'rejection_reason': rejectionReason,
      'reviewed_at': DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    };
  }

  /// Crea un AdoptionRequestModel para aprobación
  Map<String, dynamic> toJsonForApproval() {
    return {
      'status': RequestStatus.approved.toJson(),
      'reviewed_at': DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    };
  }

  /// Crea un AdoptionRequestModel para rechazo
  Map<String, dynamic> toJsonForRejection(String reason) {
    return {
      'status': RequestStatus.rejected.toJson(),
      'rejection_reason': reason,
      'reviewed_at': DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    };
  }
}