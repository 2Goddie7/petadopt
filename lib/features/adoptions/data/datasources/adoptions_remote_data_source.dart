import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/adoption_request_model.dart';
import '../../../../core/error/exceptions.dart';

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
      // Verificar si ya existe una solicitud activa
      final existingRequest = await supabase
          .from('adoption_requests')
          .select()
          .eq('pet_id', request.petId)
          .eq('adopter_id', request.adopterId)
          .eq('status', 'pending')
          .maybeSingle();

      if (existingRequest != null) {
        throw const DuplicateException('Ya tienes una solicitud pendiente para esta mascota');
      }

      final requestData = request.toJsonForCreation();

      final response = await supabase
          .from('adoption_requests')
          .insert(requestData)
          .select()
          .single();

      return AdoptionRequestModel.fromJson(response);
    } on PostgrestException catch (e) {
      if (e.code == '23503') {
        throw const InvalidDataException('Mascota o usuario no encontrado');
      } else if (e.code == '23505') {
        throw const DuplicateException('Ya existe una solicitud para esta mascota');
      }
      throw ServerException(e.message, e.code);
    } catch (e) {
      if (e is DuplicateException) rethrow;
      throw ServerException(e.toString());
    }
  }

  @override
  Future<List<AdoptionRequestModel>> getUserRequests(String userId) async {
    try {
      final response = await supabase
          .from('adoption_requests_with_details')
          .select()
          .eq('adopter_id', userId)
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => AdoptionRequestModel.fromJson(json))
          .toList();
    } on PostgrestException catch (e) {
      throw ServerException(e.message, e.code);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<List<AdoptionRequestModel>> getShelterRequests(
    String shelterId,
  ) async {
    try {
      final response = await supabase
          .from('adoption_requests_with_details')
          .select()
          .eq('shelter_id', shelterId)
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => AdoptionRequestModel.fromJson(json))
          .toList();
    } on PostgrestException catch (e) {
      throw ServerException(e.message, e.code);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<AdoptionRequestModel> getRequestById(String requestId) async {
    try {
      final response = await supabase
          .from('adoption_requests_with_details')
          .select()
          .eq('id', requestId)
          .single();

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
      final updateData = AdoptionRequestModel.empty()
          .toJsonForRejection(reason);

      final response = await supabase
          .from('adoption_requests')
          .update(updateData)
          .eq('id', requestId)
          .select()
          .single();

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
      await supabase
          .from('adoption_requests')
          .delete()
          .eq('id', requestId)
          .eq('status', 'pending'); // Solo cancelar si está pendiente
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
}