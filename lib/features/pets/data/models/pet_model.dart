import '../../domain/entities/pet.dart';

/// Modelo de Mascota para la capa de datos
/// Extiende la entidad Pet y agrega serialización JSON
class PetModel extends Pet {
  const PetModel({
    required super.id,
    required super.shelterId,
    required super.name,
    required super.species,
    required super.breed,
    required super.ageYears,
    required super.ageMonths,
    required super.gender,
    required super.size,
    required super.description,
    required super.personalityTraits,
    required super.mainImageUrl,
    required super.imagesUrls,
    super.isVaccinated,
    super.isDewormed,
    super.isSterilized,
    super.hasMicrochip,
    super.needsSpecialCare,
    super.healthNotes,
    super.adoptionStatus,
    super.viewsCount,
    required super.createdAt,
    required super.updatedAt,
    super.shelterName,
    super.shelterCity,
    super.shelterLatitude,
    super.shelterLongitude,
  });

  /// Crea un PetModel desde JSON (Supabase)
  factory PetModel.fromJson(Map<String, dynamic> json) {
    return PetModel(
      id: json['id'] as String,
      shelterId: json['shelter_id'] as String,
      name: json['name'] as String,
      species: PetSpecies.fromJson(json['species'] as String),
      breed: json['breed'] as String,
      ageYears: json['age_years'] as int,
      ageMonths: json['age_months'] as int? ?? 0,
      gender: PetGender.fromJson(json['gender'] as String),
      size: PetSize.fromJson(json['size'] as String),
      description: json['description'] as String,
      personalityTraits: (json['personality_traits'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      mainImageUrl: json['main_image_url'] as String,
      imagesUrls: (json['images_urls'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      isVaccinated: json['is_vaccinated'] as bool? ?? false,
      isDewormed: json['is_dewormed'] as bool? ?? false,
      isSterilized: json['is_sterilized'] as bool? ?? false,
      hasMicrochip: json['has_microchip'] as bool? ?? false,
      needsSpecialCare: json['needs_special_care'] as bool? ?? false,
      healthNotes: json['health_notes'] as String?,
      adoptionStatus: AdoptionStatus.fromJson(
          json['adoption_status'] as String? ?? 'available'),
      viewsCount: json['views_count'] as int? ?? 0,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      shelterName: json['shelter_name'] as String?,
      shelterCity: json['shelter_city'] as String?,
      shelterLatitude: json['shelter_latitude'] != null
          ? (json['shelter_latitude'] as num).toDouble()
          : null,
      shelterLongitude: json['shelter_longitude'] != null
          ? (json['shelter_longitude'] as num).toDouble()
          : null,
    );
  }

  /// Convierte el PetModel a JSON para Supabase
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'shelter_id': shelterId,
      'name': name,
      'species': species.toJson(),
      'breed': breed,
      'age_years': ageYears,
      'age_months': ageMonths,
      'gender': gender.toJson(),
      'size': size.toJson(),
      'description': description,
      'personality_traits': personalityTraits,
      'main_image_url': mainImageUrl,
      'images_urls': imagesUrls,
      'is_vaccinated': isVaccinated,
      'is_dewormed': isDewormed,
      'is_sterilized': isSterilized,
      'has_microchip': hasMicrochip,
      'needs_special_care': needsSpecialCare,
      'health_notes': healthNotes,
      'adoption_status': adoptionStatus.toJson(),
      'views_count': viewsCount,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Crea un PetModel desde una entidad Pet
  factory PetModel.fromEntity(Pet pet) {
    return PetModel(
      id: pet.id,
      shelterId: pet.shelterId,
      name: pet.name,
      species: pet.species,
      breed: pet.breed,
      ageYears: pet.ageYears,
      ageMonths: pet.ageMonths,
      gender: pet.gender,
      size: pet.size,
      description: pet.description,
      personalityTraits: pet.personalityTraits,
      mainImageUrl: pet.mainImageUrl,
      imagesUrls: pet.imagesUrls,
      isVaccinated: pet.isVaccinated,
      isDewormed: pet.isDewormed,
      isSterilized: pet.isSterilized,
      hasMicrochip: pet.hasMicrochip,
      needsSpecialCare: pet.needsSpecialCare,
      healthNotes: pet.healthNotes,
      adoptionStatus: pet.adoptionStatus,
      viewsCount: pet.viewsCount,
      createdAt: pet.createdAt,
      updatedAt: pet.updatedAt,
      shelterName: pet.shelterName,
      shelterLatitude: pet.shelterLatitude,
      shelterLongitude: pet.shelterLongitude,
    );
  }

  /// Convierte el PetModel a una entidad Pet
  Pet toEntity() {
    return Pet(
      id: id,
      shelterId: shelterId,
      name: name,
      species: species,
      breed: breed,
      ageYears: ageYears,
      ageMonths: ageMonths,
      gender: gender,
      size: size,
      description: description,
      personalityTraits: personalityTraits,
      mainImageUrl: mainImageUrl,
      imagesUrls: imagesUrls,
      isVaccinated: isVaccinated,
      isDewormed: isDewormed,
      isSterilized: isSterilized,
      hasMicrochip: hasMicrochip,
      needsSpecialCare: needsSpecialCare,
      healthNotes: healthNotes,
      adoptionStatus: adoptionStatus,
      viewsCount: viewsCount,
      createdAt: createdAt,
      updatedAt: updatedAt,
      shelterName: shelterName,
      shelterLatitude: shelterLatitude,
      shelterLongitude: shelterLongitude,
    );
  }

  /// Crea una copia del modelo con campos modificados
  @override
  PetModel copyWith({
    String? id,
    String? shelterId,
    String? name,
    PetSpecies? species,
    String? breed,
    int? ageYears,
    int? ageMonths,
    PetGender? gender,
    PetSize? size,
    String? description,
    List<String>? personalityTraits,
    String? mainImageUrl,
    List<String>? imagesUrls,
    bool? isVaccinated,
    bool? isDewormed,
    bool? isSterilized,
    bool? hasMicrochip,
    bool? needsSpecialCare,
    String? healthNotes,
    AdoptionStatus? adoptionStatus,
    int? viewsCount,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? shelterName,
    double? shelterLatitude,
    double? shelterLongitude,
  }) {
    return PetModel(
      id: id ?? this.id,
      shelterId: shelterId ?? this.shelterId,
      name: name ?? this.name,
      species: species ?? this.species,
      breed: breed ?? this.breed,
      ageYears: ageYears ?? this.ageYears,
      ageMonths: ageMonths ?? this.ageMonths,
      gender: gender ?? this.gender,
      size: size ?? this.size,
      description: description ?? this.description,
      personalityTraits: personalityTraits ?? this.personalityTraits,
      mainImageUrl: mainImageUrl ?? this.mainImageUrl,
      imagesUrls: imagesUrls ?? this.imagesUrls,
      isVaccinated: isVaccinated ?? this.isVaccinated,
      isDewormed: isDewormed ?? this.isDewormed,
      isSterilized: isSterilized ?? this.isSterilized,
      hasMicrochip: hasMicrochip ?? this.hasMicrochip,
      needsSpecialCare: needsSpecialCare ?? this.needsSpecialCare,
      healthNotes: healthNotes ?? this.healthNotes,
      adoptionStatus: adoptionStatus ?? this.adoptionStatus,
      viewsCount: viewsCount ?? this.viewsCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      shelterName: shelterName ?? this.shelterName,
      shelterLatitude: shelterLatitude ?? this.shelterLatitude,
      shelterLongitude: shelterLongitude ?? this.shelterLongitude,
    );
  }

  /// Crea un PetModel vacío/inicial
  factory PetModel.empty() {
    return PetModel(
      id: '',
      shelterId: '',
      name: '',
      species: PetSpecies.dog,
      breed: '',
      ageYears: 0,
      ageMonths: 0,
      gender: PetGender.male,
      size: PetSize.medium,
      description: '',
      personalityTraits: [],
      mainImageUrl: '',
      imagesUrls: [],
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  /// Crea un PetModel para creación (sin ID)
  Map<String, dynamic> toJsonForCreation() {
    return {
      'shelter_id': shelterId,
      'name': name,
      'species': species.toJson(),
      'breed': breed,
      'age_years': ageYears,
      'age_months': ageMonths,
      'gender': gender.toJson(),
      'size': size.toJson(),
      'description': description,
      'personality_traits': personalityTraits,
      'main_image_url': mainImageUrl,
      'images_urls': imagesUrls,
      'is_vaccinated': isVaccinated,
      'is_dewormed': isDewormed,
      'is_sterilized': isSterilized,
      'has_microchip': hasMicrochip,
      'needs_special_care': needsSpecialCare,
      'health_notes': healthNotes,
      'adoption_status': adoptionStatus.toJson(),
    };
  }

  /// Crea un PetModel para actualización
  Map<String, dynamic> toJsonForUpdate() {
    return {
      'name': name,
      'species': species.toJson(),
      'breed': breed,
      'age_years': ageYears,
      'age_months': ageMonths,
      'gender': gender.toJson(),
      'size': size.toJson(),
      'description': description,
      'personality_traits': personalityTraits,
      'main_image_url': mainImageUrl,
      'images_urls': imagesUrls,
      'is_vaccinated': isVaccinated,
      'is_dewormed': isDewormed,
      'is_sterilized': isSterilized,
      'has_microchip': hasMicrochip,
      'needs_special_care': needsSpecialCare,
      'health_notes': healthNotes,
      'adoption_status': adoptionStatus.toJson(),
      'updated_at': DateTime.now().toIso8601String(),
    };
  }
}