import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/pet.dart';
import '../../domain/repositories/pet_repository.dart';
import '../models/pet_model.dart';

class PetRepositoryImpl implements PetRepository {
  final SupabaseClient supabaseClient;

  PetRepositoryImpl({required this.supabaseClient});

  @override
  Future<Either<Failure, List<Pet>>> getAllPets() async {
    try {
      final response = await supabaseClient
          .from('pets_with_shelter_info')
          .select()
          .eq('adoption_status', 'available')
          .order('created_at', ascending: false);

      final pets =
          (response as List).map((json) => PetModel.fromJson(json)).toList();

      return Right(pets);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Pet>> getPetById(String id) async {
    try {
      // Incrementar contador de vistas
      await supabaseClient.rpc('increment_pet_views', params: {'pet_uuid': id});

      final response = await supabaseClient
          .from('pets_with_shelter_info')
          .select()
          .eq('id', id)
          .single();

      final pet = PetModel.fromJson(response);
      return Right(pet);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Pet>>> searchPets({
    PetSpecies? species,
    PetSize? size,
    String? city,
  }) async {
    try {
      var query = supabaseClient
          .from('pets_with_shelter_info')
          .select()
          .eq('adoption_status', 'available');

      if (species != null) {
        final speciesStr = species == PetSpecies.dog
            ? 'dog'
            : species == PetSpecies.cat
                ? 'cat'
                : 'other';
        query = query.eq('species', speciesStr);
      }

      if (size != null) {
        final sizeStr = size == PetSize.small
            ? 'small'
            : size == PetSize.medium
                ? 'medium'
                : 'large';
        query = query.eq('size', sizeStr);
      }

      if (city != null && city.isNotEmpty) {
        query = query.ilike('shelter_city', '%$city%');
      }

      final response = await query.order('created_at', ascending: false);

      final pets =
          (response as List).map((json) => PetModel.fromJson(json)).toList();

      return Right(pets);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
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
  }) async {
    try {
      final petData = {
        'shelter_id': shelterId,
        'name': name,
        'species': species == PetSpecies.dog
            ? 'dog'
            : species == PetSpecies.cat
                ? 'cat'
                : 'other',
        'breed': breed,
        'age_years': ageYears,
        'age_months': ageMonths,
        'gender': gender == PetGender.male ? 'male' : 'female',
        'size': size == PetSize.small
            ? 'small'
            : size == PetSize.medium
                ? 'medium'
                : 'large',
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
      };

      final response =
          await supabaseClient.from('pets').insert(petData).select().single();

      final createdPet = PetModel.fromJson(response);
      return Right(createdPet);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Pet>>> getUserPets(String shelterId) async {
    try {
      final response = await supabaseClient
          .from('pets_with_shelter_info')
          .select()
          .eq('shelter_id', shelterId)
          .order('created_at', ascending: false);

      final pets =
          (response as List).map((json) => PetModel.fromJson(json)).toList();

      return Right(pets);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deletePet(String petId) async {
    try {
      await supabaseClient.from('pets').delete().eq('id', petId);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
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
  }) async {
    try {
      final updateData = <String, dynamic>{};

      if (name != null) updateData['name'] = name;
      if (breed != null) updateData['breed'] = breed;
      if (ageYears != null) updateData['age_years'] = ageYears;
      if (ageMonths != null) updateData['age_months'] = ageMonths;
      if (description != null) updateData['description'] = description;
      if (personalityTraits != null) {
        updateData['personality_traits'] = personalityTraits;
      }
      if (isVaccinated != null) updateData['is_vaccinated'] = isVaccinated;
      if (isDewormed != null) updateData['is_dewormed'] = isDewormed;
      if (isSterilized != null) updateData['is_sterilized'] = isSterilized;
      if (hasMicrochip != null) updateData['has_microchip'] = hasMicrochip;
      if (needsSpecialCare != null) {
        updateData['needs_special_care'] = needsSpecialCare;
      }
      if (healthNotes != null) updateData['health_notes'] = healthNotes;

      final response = await supabaseClient
          .from('pets')
          .update(updateData)
          .eq('id', petId)
          .select()
          .single();

      final updatedPet = PetModel.fromJson(response);
      return Right(updatedPet);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
