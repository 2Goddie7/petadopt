import 'package:equatable/equatable.dart';

/// Entidad de Mascota en el dominio
/// Representa una mascota disponible para adopción
class Pet extends Equatable {
  final String id;
  final String shelterId;
  final String name;
  final PetSpecies species;
  final String breed;
  final int ageYears;
  final int ageMonths;
  final PetGender gender;
  final PetSize size;
  final String description;
  final List<String> personalityTraits;
  final String mainImageUrl;
  final List<String> imagesUrls;
  
  // Estado de salud
  final bool isVaccinated;
  final bool isDewormed;
  final bool isSterilized;
  final bool hasMicrochip;
  final bool needsSpecialCare;
  final String? healthNotes;
  
  // Estado de adopción
  final AdoptionStatus adoptionStatus;
  
  // Metadata
  final int viewsCount;
  final DateTime createdAt;
  final DateTime updatedAt;
  
  // Información del refugio (opcional, puede venir del join)
  final String? shelterName;
  final String? shelterCity;
  final double? shelterLatitude;
  final double? shelterLongitude;

  const Pet({
    required this.id,
    required this.shelterId,
    required this.name,
    required this.species,
    required this.breed,
    required this.ageYears,
    required this.ageMonths,
    required this.gender,
    required this.size,
    required this.description,
    required this.personalityTraits,
    required this.mainImageUrl,
    required this.imagesUrls,
    this.isVaccinated = false,
    this.isDewormed = false,
    this.isSterilized = false,
    this.hasMicrochip = false,
    this.needsSpecialCare = false,
    this.healthNotes,
    this.adoptionStatus = AdoptionStatus.available,
    this.viewsCount = 0,
    required this.createdAt,
    required this.updatedAt,
    this.shelterName,
    this.shelterCity,
    this.shelterLatitude,
    this.shelterLongitude,
  });

  /// Crea una copia de la mascota con campos modificados
  Pet copyWith({
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
    return Pet(
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

  /// Obtiene la edad completa en formato legible
  String get ageDisplay {
    if (ageYears == 0) {
      return '$ageMonths ${ageMonths == 1 ? 'mes' : 'meses'}';
    } else if (ageMonths == 0) {
      return '$ageYears ${ageYears == 1 ? 'año' : 'años'}';
    } else {
      return '$ageYears ${ageYears == 1 ? 'año' : 'años'} y $ageMonths ${ageMonths == 1 ? 'mes' : 'meses'}';
    }
  }

  /// Alias para ageDisplay
  String get displayAge => ageDisplay;

  /// Verifica si está disponible para adopción
  bool get isAvailable => adoptionStatus == AdoptionStatus.available;

  /// Verifica si ya fue adoptada
  bool get isAdopted => adoptionStatus == AdoptionStatus.adopted;

  /// Verifica si tiene solicitudes pendientes
  bool get isPending => adoptionStatus == AdoptionStatus.pending;

  /// Verifica si tiene imágenes adicionales
  bool get hasAdditionalImages => imagesUrls.isNotEmpty;

  /// Obtiene el número total de imágenes
  int get totalImages => imagesUrls.length + 1; // +1 por la imagen principal

  /// Verifica si tiene todas las vacunas
  bool get isFullyHealthy => isVaccinated && isDewormed && isSterilized;

  /// Verifica si tiene notas de salud
  bool get hasHealthNotes => healthNotes != null && healthNotes!.isNotEmpty;

  /// Calcula distancia al refugio si tiene coordenadas
  double? distanceToShelter(double userLat, double userLon) {
    if (shelterLatitude == null || shelterLongitude == null) return null;
    
    const earthRadius = 6371.0;
    final dLat = _toRadians(userLat - shelterLatitude!);
    final dLon = _toRadians(userLon - shelterLongitude!);
    
    final a = _sin(dLat / 2) * _sin(dLat / 2) +
        _cos(_toRadians(shelterLatitude!)) *
            _cos(_toRadians(userLat)) *
            _sin(dLon / 2) *
            _sin(dLon / 2);
    
    final c = 2 * _atan2(_sqrt(a), _sqrt(1 - a));
    
    return earthRadius * c;
  }

  // Métodos helper matemáticos simplificados
  double _toRadians(double degrees) => degrees * (3.141592653589793 / 180.0);
  double _sin(double x) => x - (x * x * x) / 6;
  double _cos(double x) => 1 - (x * x) / 2;
  double _sqrt(double x) {
    if (x == 0) return 0;
    double guess = x / 2;
    for (int i = 0; i < 10; i++) {
      guess = (guess + x / guess) / 2;
    }
    return guess;
  }
  double _atan2(double y, double x) {
    if (x > 0) return y / x;
    return 0;
  }

  @override
  List<Object?> get props => [
        id,
        shelterId,
        name,
        species,
        breed,
        ageYears,
        ageMonths,
        gender,
        size,
        description,
        personalityTraits,
        mainImageUrl,
        imagesUrls,
        isVaccinated,
        isDewormed,
        isSterilized,
        hasMicrochip,
        needsSpecialCare,
        healthNotes,
        adoptionStatus,
        viewsCount,
        createdAt,
        updatedAt,
        shelterName,
        shelterLatitude,
        shelterLongitude,
      ];

  @override
  bool get stringify => true;
}

/// Especie de mascota
enum PetSpecies {
  dog,
  cat,
  other;

  String toJson() {
    switch (this) {
      case PetSpecies.dog:
        return 'dog';
      case PetSpecies.cat:
        return 'cat';
      case PetSpecies.other:
        return 'other';
    }
  }

  static PetSpecies fromJson(String value) {
    switch (value.toLowerCase()) {
      case 'dog':
        return PetSpecies.dog;
      case 'cat':
        return PetSpecies.cat;
      case 'other':
        return PetSpecies.other;
      default:
        throw ArgumentError('Invalid pet species: $value');
    }
  }

  String get displayName {
    switch (this) {
      case PetSpecies.dog:
        return 'Perro';
      case PetSpecies.cat:
        return 'Gato';
      case PetSpecies.other:
        return 'Otro';
    }
  }

  String get emoji {
    switch (this) {
      case PetSpecies.dog:
        return '🐕';
      case PetSpecies.cat:
        return '🐈';
      case PetSpecies.other:
        return '🐾';
    }
  }
}

/// Género de mascota
enum PetGender {
  male,
  female;

  String toJson() {
    switch (this) {
      case PetGender.male:
        return 'male';
      case PetGender.female:
        return 'female';
    }
  }

  static PetGender fromJson(String value) {
    switch (value.toLowerCase()) {
      case 'male':
      case 'macho':
        return PetGender.male;
      case 'female':
      case 'hembra':
        return PetGender.female;
      default:
        throw ArgumentError('Invalid pet gender: $value');
    }
  }

  String get displayName {
    switch (this) {
      case PetGender.male:
        return 'Macho';
      case PetGender.female:
        return 'Hembra';
    }
  }

  String get symbol {
    switch (this) {
      case PetGender.male:
        return '♂';
      case PetGender.female:
        return '♀';
    }
  }
}

/// Tamaño de mascota
enum PetSize {
  small,
  medium,
  large;

  String toJson() {
    switch (this) {
      case PetSize.small:
        return 'small';
      case PetSize.medium:
        return 'medium';
      case PetSize.large:
        return 'large';
    }
  }

  static PetSize fromJson(String value) {
    switch (value.toLowerCase()) {
      case 'small':
      case 'pequeño':
        return PetSize.small;
      case 'medium':
      case 'mediano':
        return PetSize.medium;
      case 'large':
      case 'grande':
        return PetSize.large;
      default:
        throw ArgumentError('Invalid pet size: $value');
    }
  }

  String get displayName {
    switch (this) {
      case PetSize.small:
        return 'Pequeño';
      case PetSize.medium:
        return 'Mediano';
      case PetSize.large:
        return 'Grande';
    }
  }
}

/// Estado de adopción
enum AdoptionStatus {
  available,
  pending,
  adopted;

  String toJson() {
    switch (this) {
      case AdoptionStatus.available:
        return 'available';
      case AdoptionStatus.pending:
        return 'pending';
      case AdoptionStatus.adopted:
        return 'adopted';
    }
  }

  static AdoptionStatus fromJson(String value) {
    switch (value.toLowerCase()) {
      case 'available':
      case 'disponible':
        return AdoptionStatus.available;
      case 'pending':
      case 'pendiente':
        return AdoptionStatus.pending;
      case 'adopted':
      case 'adoptado':
      case 'adoptada':
        return AdoptionStatus.adopted;
      default:
        throw ArgumentError('Invalid adoption status: $value');
    }
  }

  String get displayName {
    switch (this) {
      case AdoptionStatus.available:
        return 'Disponible';
      case AdoptionStatus.pending:
        return 'Pendiente';
      case AdoptionStatus.adopted:
        return 'Adoptado';
    }
  }
}