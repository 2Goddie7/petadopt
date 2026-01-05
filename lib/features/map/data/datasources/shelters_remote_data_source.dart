import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/shelter_model.dart';
import '../../../../core/error/exceptions.dart';

abstract class SheltersRemoteDataSource {
  Future<ShelterModel> createShelter(ShelterModel shelter);
  Future<ShelterModel> getShelterById(String shelterId);
  Future<ShelterModel> getShelterByProfileId(String profileId);
  Future<List<ShelterModel>> getAllShelters();
  Future<ShelterModel> updateShelter(ShelterModel shelter);
}

class SheltersRemoteDataSourceImpl implements SheltersRemoteDataSource {
  final SupabaseClient supabase;

  SheltersRemoteDataSourceImpl({required this.supabase});

  @override
  Future<ShelterModel> createShelter(ShelterModel shelter) async {
    try {
      final shelterData = shelter.toJsonForCreation();
      final response = await supabase
          .from('shelters')
          .insert(shelterData)
          .select()
          .single();
      return ShelterModel.fromJson(response);
    } on PostgrestException catch (e) {
      if (e.code == '23505') throw const DuplicateException('Ya existe un refugio para este usuario');
      throw ServerException(e.message, e.code);
    }
  }

  @override
  Future<ShelterModel> getShelterById(String shelterId) async {
    try {
      final response = await supabase
          .from('shelters')
          .select()
          .eq('id', shelterId)
          .single();
      return ShelterModel.fromJson(response);
    } on PostgrestException catch (e) {
      if (e.code == 'PGRST116') throw const NotFoundException('Refugio no encontrado');
      throw ServerException(e.message, e.code);
    }
  }

  @override
  Future<ShelterModel> getShelterByProfileId(String profileId) async {
    try {
      final response = await supabase
          .from('shelters')
          .select()
          .eq('profile_id', profileId)
          .single();
      return ShelterModel.fromJson(response);
    } on PostgrestException catch (e) {
      if (e.code == 'PGRST116') throw const NotFoundException('Refugio no encontrado');
      throw ServerException(e.message, e.code);
    }
  }

  @override
  Future<List<ShelterModel>> getAllShelters() async {
    try {
      final response = await supabase.from('shelters').select().order('shelter_name');
      return (response as List).map((json) => ShelterModel.fromJson(json)).toList();
    } on PostgrestException catch (e) {
      throw ServerException(e.message, e.code);
    }
  }

  @override
  Future<ShelterModel> updateShelter(ShelterModel shelter) async {
    try {
      final shelterData = shelter.toJsonForUpdate();
      final response = await supabase
          .from('shelters')
          .update(shelterData)
          .eq('id', shelter.id)
          .select()
          .single();
      return ShelterModel.fromJson(response);
    } on PostgrestException catch (e) {
      if (e.code == 'PGRST116') throw const NotFoundException('Refugio no encontrado');
      throw ServerException(e.message, e.code);
    }
  }
}