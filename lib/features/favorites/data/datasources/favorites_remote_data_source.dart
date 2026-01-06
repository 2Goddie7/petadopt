import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/error/exceptions.dart';
import '../../../pets/data/models/pet_model.dart';

abstract class FavoritesRemoteDataSource {
  Future<List<PetModel>> getFavoritePets(String userId);
  Future<bool> isFavorite(String userId, String petId);
  Future<void> addFavorite(String userId, String petId);
  Future<void> removeFavorite(String userId, String petId);
}

class FavoritesRemoteDataSourceImpl implements FavoritesRemoteDataSource {
  final SupabaseClient supabaseClient;

  FavoritesRemoteDataSourceImpl({required this.supabaseClient});

  @override
  Future<List<PetModel>> getFavoritePets(String userId) async {
    try {
      final response = await supabaseClient
          .from('favorites')
          .select('pet_id, pets_with_shelter_info(*)')
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      final List<PetModel> pets = [];
      for (final item in response) {
        if (item['pets_with_shelter_info'] != null) {
          pets.add(PetModel.fromJson(item['pets_with_shelter_info']));
        }
      }

      return pets;
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<bool> isFavorite(String userId, String petId) async {
    try {
      final response = await supabaseClient
          .from('favorites')
          .select('user_id')
          .eq('user_id', userId)
          .eq('pet_id', petId)
          .maybeSingle();

      return response != null;
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> addFavorite(String userId, String petId) async {
    try {
      await supabaseClient.from('favorites').insert({
        'user_id': userId,
        'pet_id': petId,
        'created_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> removeFavorite(String userId, String petId) async {
    try {
      await supabaseClient
          .from('favorites')
          .delete()
          .eq('user_id', userId)
          .eq('pet_id', petId);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}
