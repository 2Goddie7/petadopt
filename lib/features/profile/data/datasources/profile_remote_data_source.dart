import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_profile_model.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/error/exceptions.dart';

/// Contrato del Profile Remote Data Source
abstract class ProfileRemoteDataSource {
  /// Obtiene el perfil del usuario por ID
  Future<UserProfileModel> getProfile(String userId);

  /// Actualiza el perfil del usuario
  Future<UserProfileModel> updateProfile(UserProfileModel profile);

  /// Sube la imagen de perfil del usuario
  Future<String> uploadProfileImage(String userId, XFile imageFile);
}

/// Implementación del Profile Remote Data Source con Supabase
class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  final SupabaseClient supabase;

  ProfileRemoteDataSourceImpl({required this.supabase});

  @override
  Future<UserProfileModel> getProfile(String userId) async {
    try {
      final response = await supabase
          .from(ApiConstants.profilesTable)
          .select()
          .eq('id', userId)
          .single();

      return UserProfileModel.fromJson(response);
    } on PostgrestException catch (e) {
      if (e.code == 'PGRST116') {
        throw NotFoundException('Perfil no encontrado', e.code);
      }
      throw ServerException(e.message, e.code);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<UserProfileModel> updateProfile(UserProfileModel profile) async {
    try {
      // Datos a actualizar (sin id, email, created_at)
      final updateData = {
        'full_name': profile.fullName,
        'phone': profile.phone,
        'bio': profile.bio,
        'location': profile.location,
        'updated_at': DateTime.now().toIso8601String(),
      };

      final response = await supabase
          .from(ApiConstants.profilesTable)
          .update(updateData)
          .eq('id', profile.id)
          .select()
          .single();

      return UserProfileModel.fromJson(response);
    } on PostgrestException catch (e) {
      if (e.code == 'PGRST116') {
        throw NotFoundException('Perfil no encontrado', e.code);
      }
      throw ServerException(e.message, e.code);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<String> uploadProfileImage(String userId, XFile imageFile) async {
    try {
      // Validar que el archivo sea una imagen - extraer extensión de XFile.name (no de path que es blob URL en web)
      final extension = imageFile.name.split('.').last.toLowerCase();
      if (!ApiConstants.allowedImageFormats.contains(extension)) {
        throw ValidationException(
          'Formato de imagen no permitido. Usa: ${ApiConstants.allowedImageFormats.join(", ")}',
        );
      }

      // Validar tamaño
      final fileSize = await imageFile.length();
      if (fileSize > ApiConstants.maxAvatarSizeBytes) {
        throw ValidationException(
          'La imagen es muy grande. Máximo ${ApiConstants.maxAvatarSizeBytes ~/ (1024 * 1024)}MB',
        );
      }

      // Nombre único para el archivo
      final fileName =
          '${userId}_${DateTime.now().millisecondsSinceEpoch}.$extension';
      final filePath = '$userId/$fileName';

      // Subir archivo a Supabase Storage
      final bytes = await imageFile.readAsBytes();
      await supabase.storage
          .from(ApiConstants.profileAvatarsBucket)
          .uploadBinary(
            filePath,
            bytes,
          );

      // Obtener URL pública
      final publicUrl = supabase.storage
          .from(ApiConstants.profileAvatarsBucket)
          .getPublicUrl(filePath);

      // Actualizar avatar_url en la tabla profiles
      await supabase.from(ApiConstants.profilesTable).update({
        'avatar_url': publicUrl,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', userId);

      return publicUrl;
    } on StorageException catch (e) {
      throw ServerException(
          'Error al subir imagen: ${e.message}', e.statusCode);
    } on PostgrestException catch (e) {
      throw ServerException(e.message, e.code);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}
