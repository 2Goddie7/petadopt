import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/pet_model.dart';
import '../../../../core/error/exceptions.dart';

/// Contrato del Pets Remote Data Source
abstract class PetsRemoteDataSource {
  /// Obtiene todas las mascotas disponibles
  Future<List<PetModel>> getAllPets();

  /// Obtiene una mascota por ID
  Future<PetModel> getPetById(String petId);

  /// Obtiene mascotas de un refugio específico
  Future<List<PetModel>> getPetsByShelter(String shelterId);

  /// Busca mascotas por filtros
  Future<List<PetModel>> searchPets({
    String? species,
    String? gender,
    String? size,
    String? query,
  });

  /// Crea una nueva mascota
  Future<PetModel> createPet(PetModel pet);

  /// Actualiza una mascota existente
  Future<PetModel> updatePet(PetModel pet);

  /// Elimina una mascota
  Future<void> deletePet(String petId);

  /// Sube imágenes de mascota
  Future<List<String>> uploadPetImages(
    String shelterId,
    String petId,
    List<String> imagePaths,
  );

  /// Incrementa el contador de vistas de una mascota
  Future<void> incrementViews(String petId);

  /// Actualiza el estado de adopción de una mascota
  Future<void> updateAdoptionStatus(String petId, String status);
}

/// Implementación del Pets Remote Data Source con Supabase
class PetsRemoteDataSourceImpl implements PetsRemoteDataSource {
  final SupabaseClient supabase;

  PetsRemoteDataSourceImpl({required this.supabase});

  @override
  Future<List<PetModel>> getAllPets() async {
    try {
      final response = await supabase
          .from('pets_with_shelter_info')
          .select()
          .eq('adoption_status', 'available')
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => PetModel.fromJson(json))
          .toList();
    } on PostgrestException catch (e) {
      throw ServerException(e.message, e.code);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<PetModel> getPetById(String petId) async {
    try {
      final response = await supabase
          .from('pets_with_shelter_info')
          .select()
          .eq('id', petId)
          .single();

      return PetModel.fromJson(response);
    } on PostgrestException catch (e) {
      if (e.code == 'PGRST116') {
        throw const NotFoundException('Mascota no encontrada');
      }
      throw ServerException(e.message, e.code);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<List<PetModel>> getPetsByShelter(String shelterId) async {
    try {
      final response = await supabase
          .from('pets')
          .select()
          .eq('shelter_id', shelterId)
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => PetModel.fromJson(json))
          .toList();
    } on PostgrestException catch (e) {
      throw ServerException(e.message, e.code);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<List<PetModel>> searchPets({
    String? species,
    String? gender,
    String? size,
    String? query,
  }) async {
    try {
      var queryBuilder = supabase
          .from('pets_with_shelter_info')
          .select()
          .eq('adoption_status', 'available');

      // Aplicar filtros
      if (species != null && species != 'all') {
        queryBuilder = queryBuilder.eq('species', species);
      }

      if (gender != null) {
        queryBuilder = queryBuilder.eq('gender', gender);
      }

      if (size != null) {
        queryBuilder = queryBuilder.eq('size', size);
      }

      // Búsqueda por texto (nombre o raza)
      if (query != null && query.isNotEmpty) {
        queryBuilder = queryBuilder.or(
          'name.ilike.%$query%,breed.ilike.%$query%',
        );
      }

      final response = await queryBuilder.order('created_at', ascending: false);

      return (response as List)
          .map((json) => PetModel.fromJson(json))
          .toList();
    } on PostgrestException catch (e) {
      throw ServerException(e.message, e.code);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<PetModel> createPet(PetModel pet) async {
    try {
      final petData = pet.toJsonForCreation();

      final response = await supabase
          .from('pets')
          .insert(petData)
          .select()
          .single();

      return PetModel.fromJson(response);
    } on PostgrestException catch (e) {
      if (e.code == '23503') {
        throw const InvalidDataException('Refugio no encontrado');
      } else if (e.code == '23505') {
        throw const DuplicateException('La mascota ya existe');
      }
      throw ServerException(e.message, e.code);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<PetModel> updatePet(PetModel pet) async {
    try {
      final petData = pet.toJsonForUpdate();

      final response = await supabase
          .from('pets')
          .update(petData)
          .eq('id', pet.id)
          .select()
          .single();

      return PetModel.fromJson(response);
    } on PostgrestException catch (e) {
      if (e.code == 'PGRST116') {
        throw const NotFoundException('Mascota no encontrada');
      }
      throw ServerException(e.message, e.code);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> deletePet(String petId) async {
    try {
      await supabase
          .from('pets')
          .delete()
          .eq('id', petId);
    } on PostgrestException catch (e) {
      if (e.code == 'PGRST116') {
        throw const NotFoundException('Mascota no encontrada');
      }
      throw ServerException(e.message, e.code);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<List<String>> uploadPetImages(
    String shelterId,
    String petId,
    List<String> imagePaths,
  ) async {
    try {
      final List<String> uploadedUrls = [];

      for (int i = 0; i < imagePaths.length; i++) {
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final fileName = 'pet_${timestamp}_$i.jpg';
        final path = '$shelterId/$petId/$fileName';

        final imageFile = File(imagePaths[i]);

        await supabase.storage
            .from('pet-images')
            .upload(path, imageFile);

        final publicUrl = supabase.storage
            .from('pet-images')
            .getPublicUrl(path);

        uploadedUrls.add(publicUrl);
      }

      return uploadedUrls;
    } on StorageException catch (e) {
      if (e.message.contains('size')) {
        throw const FileTooLargeException();
      } else if (e.message.contains('type')) {
        throw const InvalidFileTypeException();
      }
      throw FileUploadException(e.message, e.statusCode);
    } catch (e) {
      throw FileUploadException(e.toString());
    }
  }

  @override
  Future<void> incrementViews(String petId) async {
    try {
      // Llamar a la función RPC de Supabase
      await supabase.rpc('increment_pet_views', params: {'pet_uuid': petId});
    } on PostgrestException catch (e) {
      // No lanzar error si falla, es solo un contador
      print('Error incrementing views: ${e.message}');
    } catch (e) {
      print('Error incrementing views: $e');
    }
  }

  @override
  Future<void> updateAdoptionStatus(String petId, String status) async {
    try {
      await supabase
          .from('pets')
          .update({'adoption_status': status, 'updated_at': DateTime.now().toIso8601String()})
          .eq('id', petId);
    } on PostgrestException catch (e) {
      if (e.code == 'PGRST116') {
        throw const NotFoundException('Mascota no encontrada');
      }
      throw ServerException(e.message, e.code);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}