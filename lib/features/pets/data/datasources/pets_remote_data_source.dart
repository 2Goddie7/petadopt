import 'dart:io';
import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';
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
    List<dynamic> images,
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

  /// Obtiene el tipo de usuario actual (adopter o shelter)
  Future<String?> _getCurrentUserType() async {
    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) return null;

      final response = await supabase
          .from('profiles')
          .select('user_type')
          .eq('id', userId)
          .maybeSingle();

      return response?['user_type'] as String?;
    } catch (e) {
      print('Error obteniendo user_type: $e');
      return null;
    }
  }

  @override
  Future<List<PetModel>> getAllPets() async {
    try {
      // IMPORTANTE: Diferenciar según el tipo de usuario
      final userType = await _getCurrentUserType();

      if (userType == 'shelter') {
        // Los shelters SOLO ven sus propias mascotas
        final userId = supabase.auth.currentUser?.id;
        if (userId == null) {
          throw const ServerException('Usuario no autenticado');
        }

        // Obtener shelter_id del usuario actual
        final shelterResponse = await supabase
            .from('shelters')
            .select('id')
            .eq('profile_id', userId)
            .maybeSingle();

        if (shelterResponse == null) {
          throw const ServerException('Refugio no encontrado');
        }

        final shelterId = shelterResponse['id'] as String;

        // Retornar SOLO mascotas del shelter (usando view para traer ubicación)
        final response = await supabase
            .from('pets_with_shelter_info')
            .select()
            .eq('shelter_id', shelterId)
            .order('created_at', ascending: false);

        return (response as List)
            .map((json) => PetModel.fromJson(json))
            .toList();
      } else {
        // Los adoptantes ven TODAS las mascotas disponibles
        final response = await supabase
            .from('pets_with_shelter_info')
            .select()
            .eq('adoption_status', 'available')
            .order('created_at', ascending: false);

        return (response as List)
            .map((json) => PetModel.fromJson(json))
            .toList();
      }
    } on PostgrestException catch (e) {
      throw ServerException(e.message, e.code);
    } catch (e) {
      if (e is ServerException) rethrow;
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
          .from('pets_with_shelter_info')
          .select()
          .eq('shelter_id', shelterId)
          .order('created_at', ascending: false);

      return (response as List).map((json) => PetModel.fromJson(json)).toList();
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

      return (response as List).map((json) => PetModel.fromJson(json)).toList();
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

      final response =
          await supabase.from('pets').insert(petData).select().single();

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
      // Verificar el estado de adopción antes de eliminar
      final petResponse = await supabase
          .from('pets')
          .select('adoption_status')
          .eq('id', petId)
          .maybeSingle();

      if (petResponse == null) {
        throw const NotFoundException('Mascota no encontrada');
      }

      final adoptionStatus = petResponse['adoption_status'] as String;

      // No permitir eliminar si está en proceso o adoptada
      if (adoptionStatus == 'pending' || adoptionStatus == 'adopted') {
        throw ValidationException(
          'No se puede eliminar una mascota con estado "$adoptionStatus". '
          'Solo se pueden eliminar mascotas disponibles.',
        );
      }

      await supabase.from('pets').delete().eq('id', petId);
    } on PostgrestException catch (e) {
      if (e.code == 'PGRST116') {
        throw const NotFoundException('Mascota no encontrada');
      }
      throw ServerException(e.message, e.code);
    } catch (e) {
      if (e is ValidationException || e is NotFoundException) rethrow;
      throw ServerException(e.toString());
    }
  }

  @override
  Future<List<String>> uploadPetImages(
    String shelterId,
    String petId,
    List<dynamic> images,
  ) async {
    try {
      final List<String> uploadedUrls = [];
      const maxFileSize = 5 * 1024 * 1024; // 5MB en bytes

      for (int i = 0; i < images.length; i++) {
        final image = images[i];
        Uint8List bytes;
        String mimeType = 'image/jpeg';
        String fileExtension = 'jpeg';

        // Detectar si es XFile o String (path)
        if (image is XFile) {
          // Es XFile (web o mobile con image_picker)
          bytes = await image.readAsBytes();
          mimeType = image.mimeType ?? 'image/jpeg';

          // Extraer extensión del mimeType (ej: image/png -> png)
          fileExtension = mimeType.split('/').last.toLowerCase();

          // Normalizar
          if (fileExtension == 'jpg') fileExtension = 'jpeg';
        } else if (image is String) {
          // Es un path de archivo (mobile)
          final imagePath = image;

          // Detectar extensión del archivo
          String ext = imagePath.split('.').last.toLowerCase();

          // Normalizar JPG a JPEG
          if (ext == 'jpg') ext = 'jpeg';

          fileExtension = ext;

          // Leer archivo como bytes
          final imageFile = File(imagePath);
          bytes = await imageFile.readAsBytes();

          // Determinar content type correcto
          mimeType = ext == 'jpeg' ? 'image/jpeg' : 'image/$ext';
        } else {
          throw InvalidFileTypeException('Tipo de archivo no válido');
        }

        // Validar formatos permitidos
        final allowedFormats = ['jpeg', 'png', 'webp', 'gif'];
        if (!allowedFormats.contains(fileExtension)) {
          throw InvalidFileTypeException(
              'Formato no soportado: .$fileExtension. Permitidos: ${allowedFormats.join(", ")}');
        }

        // Validar tamaño del archivo
        if (bytes.length > maxFileSize) {
          throw const FileTooLargeException(
              'Archivo muy grande. Máximo permitido: 5MB');
        }

        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final fileName = 'pet_${timestamp}_$i.$fileExtension';
        final path = '$shelterId/$petId/$fileName';

        // Subir usando uploadBinary con bytes
        await supabase.storage.from('pet-images').uploadBinary(
              path,
              bytes,
              fileOptions: FileOptions(
                contentType: mimeType,
                upsert: false,
              ),
            );

        final publicUrl =
            supabase.storage.from('pet-images').getPublicUrl(path);

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
      await supabase.from('pets').update({
        'adoption_status': status,
        'updated_at': DateTime.now().toIso8601String()
      }).eq('id', petId);
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
