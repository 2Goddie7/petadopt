import 'package:dartz/dartz.dart';
import '../entities/pet.dart';
import '../../../../core/error/failures.dart';

/// Contrato del repositorio de mascotas
abstract class PetsRepository {
  /// Obtiene todas las mascotas disponibles
  Future<Either<Failure, List<Pet>>> getAllPets();

  /// Obtiene una mascota por ID
  Future<Either<Failure, Pet>> getPetById(String petId);

  /// Obtiene mascotas de un refugio específico
  Future<Either<Failure, List<Pet>>> getPetsByShelter(String shelterId);

  /// Busca mascotas con filtros opcionales
  Future<Either<Failure, List<Pet>>> searchPets({
    String? species,
    String? gender,
    String? size,
    String? query,
  });

  /// Crea una nueva mascota
  Future<Either<Failure, Pet>> createPet(Pet pet);

  /// Actualiza una mascota existente
  Future<Either<Failure, Pet>> updatePet(Pet pet);

  /// Elimina una mascota
  Future<Either<Failure, void>> deletePet(String petId);

  /// Sube imágenes de una mascota
  Future<Either<Failure, List<String>>> uploadPetImages(
    String shelterId,
    String petId,
    List<dynamic> imagePaths,
  );

  /// Incrementa el contador de vistas
  Future<Either<Failure, void>> incrementViews(String petId);

  /// Actualiza el estado de adopción
  Future<Either<Failure, void>> updateAdoptionStatus(
    String petId,
    AdoptionStatus status,
  );
}
