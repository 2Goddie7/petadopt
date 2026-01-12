import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/adoption_request_model.dart';
import '../../../../core/error/exceptions.dart';
import '../../domain/entities/adoption_request.dart';

/// Contrato del Adoptions Remote Data Source
abstract class AdoptionsRemoteDataSource {
  /// Crea una nueva solicitud de adopción
  Future<AdoptionRequestModel> createAdoptionRequest(
    AdoptionRequestModel request,
  );

  /// Obtiene las solicitudes de un adoptante
  Future<List<AdoptionRequestModel>> getUserRequests(String userId);

  /// Obtiene las solicitudes de un refugio
  Future<List<AdoptionRequestModel>> getShelterRequests(String shelterId);

  /// Obtiene una solicitud por ID
  Future<AdoptionRequestModel> getRequestById(String requestId);

  /// Aprueba una solicitud de adopción
  Future<AdoptionRequestModel> approveRequest(String requestId);

  /// Rechaza una solicitud de adopción
  Future<AdoptionRequestModel> rejectRequest(
    String requestId,
    String reason,
  );

  /// Cancela una solicitud (por el adoptante)
  Future<void> cancelRequest(String requestId);

  /// Verifica si existe una solicitud pendiente para una mascota
  Future<bool> hasActivePetRequest(String userId, String petId);
}

/// Implementación del Adoptions Remote Data Source con Supabase
class AdoptionsRemoteDataSourceImpl implements AdoptionsRemoteDataSource {
  final SupabaseClient supabase;

  AdoptionsRemoteDataSourceImpl({required this.supabase});

  @override
  Future<AdoptionRequestModel> createAdoptionRequest(
    AdoptionRequestModel request,
  ) async {
    try {
      // Obtener adopter_id del usuario actual
      final currentUser = supabase.auth.currentUser;
      if (currentUser == null) {
        throw const UnauthorizedException('Usuario no autenticado');
      }

      // Obtener shelter_id desde la tabla pets
      final petResponse = await supabase
          .from('pets')
          .select('shelter_id')
          .eq('id', request.petId)
          .single();

      final shelterId = petResponse['shelter_id'] as String;

      // Verificar si ya existe una solicitud pendiente ACTIVA (no rechazada ni cancelada)
      final existingRequest = await supabase
          .from('adoption_requests')
          .select('id, status')
          .eq('pet_id', request.petId)
          .eq('adopter_id', currentUser.id)
          .inFilter('status', ['pending', 'approved']).maybeSingle();

      if (existingRequest != null) {
        throw const DuplicateException(
            'Ya tienes una solicitud activa para esta mascota');
      }

      // Crear datos correctos para insertar
      final requestData = {
        'pet_id': request.petId,
        'adopter_id': currentUser.id,
        'shelter_id': shelterId,
        'message': request.message,
        'status': 'pending',
      };

      print('📤 Creando solicitud con datos: $requestData');

      final response = await supabase
          .from('adoption_requests')
          .insert(requestData)
          .select()
          .single();

      print('✅ Solicitud creada exitosamente: ${response['id']}');

      // Actualizar estado de la mascota a pending
      await supabase
          .from('pets')
          .update({'adoption_status': 'pending'}).eq('id', request.petId);

      return AdoptionRequestModel.fromJson(response);
    } on PostgrestException catch (e) {
      print('❌ PostgrestException: ${e.code} - ${e.message}');
      if (e.code == '23503') {
        throw const InvalidDataException('Mascota o usuario no encontrado');
      } else if (e.code == '23505') {
        throw const DuplicateException(
            'Ya existe una solicitud para esta mascota');
      }
      throw ServerException(e.message, e.code);
    } catch (e) {
      print('❌ Error general: $e');
      if (e is DuplicateException || e is UnauthorizedException) rethrow;
      throw ServerException(e.toString());
    }
  }

  @override
  Future<List<AdoptionRequestModel>> getUserRequests(String userId) async {
    try {
      print('📋 Obteniendo solicitudes del usuario: $userId');

      final response = await supabase
          .from('adoption_requests_with_details')
          .select()
          .eq('adopter_id', userId)
          .order('created_at', ascending: false);

      print('✅ Solicitudes obtenidas: ${(response as List).length} registros');
      if ((response as List).isNotEmpty) {
        print('📝 Primera solicitud: ${response[0]}');
      }

      return (response as List)
          .map((json) => AdoptionRequestModel.fromJson(json))
          .toList();
    } on PostgrestException catch (e) {
      print('❌ PostgrestException: ${e.code} - ${e.message}');
      throw ServerException(e.message, e.code);
    } catch (e) {
      print('❌ Error general: $e');
      throw ServerException(e.toString());
    }
  }

  @override
  Future<List<AdoptionRequestModel>> getShelterRequests(
    String shelterId,
  ) async {
    try {
      print('🏥 Obteniendo solicitudes del refugio: $shelterId');

      // Obtener solicitudes de la tabla con RLS aplicado automáticamente
      final response = await supabase
          .from('adoption_requests')
          .select()
          .eq('shelter_id', shelterId)
          .order('created_at', ascending: false);

      print(
          '✅ Solicitudes del refugio obtenidas: ${(response as List).length} registros');
      if ((response as List).isNotEmpty) {
        print('📝 Primera solicitud: ${response[0]}');
      }

      // Enriquecer con datos de la mascota y adoptante
      final enrichedRequests = await Future.wait(
        (response as List).map((json) async {
          try {
            final petId = json['pet_id'] as String;
            final adopterId = json['adopter_id'] as String;

            // Obtener datos de la mascota
            final petResponse = await supabase
                .from('pets')
                .select(
                    'name, species, breed, pet_images, age_years, gender, size')
                .eq('id', petId)
                .single();

            // Obtener datos del adoptante
            final adopterResponse = await supabase
                .from('profiles')
                .select('full_name, email, phone')
                .eq('id', adopterId)
                .single();

            // Combinar datos
            final enrichedJson = <String, dynamic>{
              ...json,
              'pet_name': petResponse['name'],
              'pet_species': petResponse['species'],
              'pet_breed': petResponse['breed'],
              'pet_image_url': _extractFirstImageUrl(petResponse['pet_images']),
              'pet_age_years': petResponse['age_years'],
              'pet_gender': petResponse['gender'],
              'pet_size': petResponse['size'],
              'adopter_name': adopterResponse['full_name'],
              'adopter_email': adopterResponse['email'],
              'adopter_phone': adopterResponse['phone'],
            };

            return AdoptionRequestModel.fromJson(enrichedJson);
          } catch (e) {
            print('⚠️ Error enriqueciendo solicitud: $e');
            return AdoptionRequestModel.fromJson(json);
          }
        }),
      );

      return enrichedRequests;
    } on PostgrestException catch (e) {
      print('❌ PostgrestException: ${e.code} - ${e.message}');
      throw ServerException(e.message, e.code);
    } catch (e) {
      print('❌ Error general: $e');
      throw ServerException(e.toString());
    }
  }

  @override
  Future<AdoptionRequestModel> getRequestById(String requestId) async {
    try {
      // Obtener solicitud básica de la tabla
      final response = await supabase
          .from('adoption_requests')
          .select()
          .eq('id', requestId)
          .single();

      final json = response;
      final petId = json['pet_id'] as String;
      final adopterId = json['adopter_id'] as String;

      // Enriquecer con datos de la mascota
      final petResponse = await supabase
          .from('pets')
          .select('name, species, breed, pet_images, age_years, gender, size')
          .eq('id', petId)
          .single();

      // Enriquecer con datos del adoptante
      final adopterResponse = await supabase
          .from('profiles')
          .select('full_name, email, phone')
          .eq('id', adopterId)
          .single();

      // Enriquecer con datos del refugio
      final shelterResponse = await supabase
          .from('shelters')
          .select('shelter_name, city')
          .eq('id', json['shelter_id'] as String)
          .single();

      // Combinar todos los datos
      final enrichedJson = <String, dynamic>{
        ...json,
        'pet_name': petResponse['name'],
        'pet_species': petResponse['species'],
        'pet_breed': petResponse['breed'],
        'pet_image_url': _extractFirstImageUrl(petResponse['pet_images']),
        'pet_age_years': petResponse['age_years'],
        'pet_gender': petResponse['gender'],
        'pet_size': petResponse['size'],
        'adopter_name': adopterResponse['full_name'],
        'adopter_email': adopterResponse['email'],
        'adopter_phone': adopterResponse['phone'],
        'shelter_name': shelterResponse['shelter_name'],
        'shelter_city': shelterResponse['city'],
      };

      return AdoptionRequestModel.fromJson(enrichedJson);
    } on PostgrestException catch (e) {
      if (e.code == 'PGRST116') {
        throw const NotFoundException('Solicitud no encontrada');
      }
      throw ServerException(e.message, e.code);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<AdoptionRequestModel> approveRequest(String requestId) async {
    try {
      final updateData = AdoptionRequestModel.empty()
          .copyWith(status: RequestStatus.approved)
          .toJsonForApproval();

      final response = await supabase
          .from('adoption_requests')
          .update(updateData)
          .eq('id', requestId)
          .select()
          .single();
      // Cuando se aprueba, la mascota pasa a adoptado
      // Primero obtenemos el pet_id de la solicitud
      final petId = response['pet_id'] as String;

      await supabase
          .from('pets')
          .update({'adoption_status': 'adopted'}).eq('id', petId);
      return AdoptionRequestModel.fromJson(response);
    } on PostgrestException catch (e) {
      if (e.code == 'PGRST116') {
        throw const NotFoundException('Solicitud no encontrada');
      }
      throw ServerException(e.message, e.code);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<AdoptionRequestModel> rejectRequest(
    String requestId,
    String reason,
  ) async {
    try {
      final updateData =
          AdoptionRequestModel.empty().toJsonForRejection(reason);

      final response = await supabase
          .from('adoption_requests')
          .update(updateData)
          .eq('id', requestId)
          .select()
          .single();

      // Cuando se rechaza, la mascota vuelve a estar disponible
      final petId = response['pet_id'] as String;

      await supabase
          .from('pets')
          .update({'adoption_status': 'available'}).eq('id', petId);

      return AdoptionRequestModel.fromJson(response);
    } on PostgrestException catch (e) {
      if (e.code == 'PGRST116') {
        throw const NotFoundException('Solicitud no encontrada');
      }
      throw ServerException(e.message, e.code);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> cancelRequest(String requestId) async {
    try {
      // Primero obtenemos el pet_id ANTES de eliminar
      final requestData = await supabase
          .from('adoption_requests')
          .select('pet_id')
          .eq('id', requestId)
          .eq('status', 'pending')
          .maybeSingle();

      if (requestData == null) {
        throw const NotFoundException('Solicitud no encontrada o ya procesada');
      }

      final petId = requestData['pet_id'] as String;

      // Eliminar la solicitud
      await supabase
          .from('adoption_requests')
          .delete()
          .eq('id', requestId)
          .eq('status', 'pending');

      // Volver la mascota a disponible
      await supabase
          .from('pets')
          .update({'adoption_status': 'available'}).eq('id', petId);
    } on PostgrestException catch (e) {
      if (e.code == 'PGRST116') {
        throw const NotFoundException('Solicitud no encontrada');
      }
      throw ServerException(e.message, e.code);
    } catch (e) {
      if (e is NotFoundException) rethrow;
      throw ServerException(e.toString());
    }
  }

  @override
  Future<bool> hasActivePetRequest(String userId, String petId) async {
    try {
      final response = await supabase
          .from('adoption_requests')
          .select('id')
          .eq('pet_id', petId)
          .eq('adopter_id', userId)
          .eq('status', 'pending')
          .maybeSingle();

      return response != null;
    } on PostgrestException catch (e) {
      throw ServerException(e.message, e.code);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  /// Helper para extraer la primera URL de imagen del JSON de pet_images
  String _extractFirstImageUrl(dynamic petImagesData) {
    if (petImagesData == null) return '';

    if (petImagesData is String) {
      petImagesData = petImagesData.isEmpty ? null : petImagesData;
    }

    if (petImagesData is List && petImagesData.isNotEmpty) {
      final firstImage = petImagesData.first;
      if (firstImage is Map && firstImage.containsKey('url')) {
        return firstImage['url'] as String? ?? '';
      }
    }

    return '';
  }
}
