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
  final SupabaseClient supabase;

  FavoritesRemoteDataSourceImpl({required this.supabase});

  @override
  Future<List<PetModel>> getFavoritePets(String userId) async {
    try {
      // Usar la vista favorites_with_pet_info que ya incluye toda la info de la mascota
      final response = await supabase
          .from('favorites_with_pet_info')
          .select('*')
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      return (response as List).map((json) => PetModel.fromJson(json)).toList();
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<bool> isFavorite(String userId, String petId) async {
    try {
      final response = await supabase
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
      await supabase.from('favorites').insert({
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
      await supabase
          .from('favorites')
          .delete()
          .eq('user_id', userId)
          .eq('pet_id', petId);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}
