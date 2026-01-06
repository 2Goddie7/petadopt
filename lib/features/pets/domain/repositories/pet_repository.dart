import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/pet.dart';

abstract class PetRepository {
  Future<Either<Failure, List<Pet>>> getAllPets();
  
  Future<Either<Failure, Pet>> getPetById(String id);
  
  Future<Either<Failure, List<Pet>>> searchPets({
    PetSpecies? species,
    PetSize? size,
    String? city,
  });
  
  Future<Either<Failure, Pet>> createPet({
    required String shelterId,
    required String name,
    required PetSpecies species,
    required String breed,
    required int ageYears,
    required int ageMonths,
    required PetGender gender,
    required PetSize size,
    required String description,
    required List<String> personalityTraits,
    required String mainImageUrl,
    required List<String> imagesUrls,
    required bool isVaccinated,
    required bool isDewormed,
    required bool isSterilized,
    required bool hasMicrochip,
    required bool needsSpecialCare,
    String? healthNotes,
  });
  
  Future<Either<Failure, List<Pet>>> getUserPets(String shelterId);
  
  Future<Either<Failure, void>> deletePet(String petId);
  
  Future<Either<Failure, Pet>> updatePet({
    required String petId,
    String? name,
    String? breed,
    int? ageYears,
    int? ageMonths,
    String? description,
    List<String>? personalityTraits,
    bool? isVaccinated,
    bool? isDewormed,
    bool? isSterilized,
    bool? hasMicrochip,
    bool? needsSpecialCare,
    String? healthNotes,
  });
}
