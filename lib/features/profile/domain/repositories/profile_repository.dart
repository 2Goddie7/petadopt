import 'package:image_picker/image_picker.dart';
import 'package:dartz/dartz.dart';
import '../entities/user_profile.dart';
import '../../../../core/error/failures.dart';

/// Contrato del repositorio de perfil
abstract class ProfileRepository {
  /// Obtiene el perfil del usuario por ID
  Future<Either<Failure, UserProfile>> getProfile(String userId);

  /// Actualiza el perfil del usuario
  Future<Either<Failure, UserProfile>> updateProfile(UserProfile profile);

  /// Sube la imagen de perfil del usuario
  Future<Either<Failure, String>> uploadProfileImage(
    String userId,
    XFile imageFile,
  );
}
