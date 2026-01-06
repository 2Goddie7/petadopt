import 'package:dartz/dartz.dart';
import '../entities/user.dart';
import '../../../../core/error/failures.dart';

/// Contrato del repositorio de autenticación
/// Define las operaciones disponibles en la capa de dominio
abstract class AuthRepository {
  /// Registra un nuevo usuario
  Future<Either<Failure, User>> signUp({
    required String email,
    required String password,
    required String fullName,
    required UserType userType,
    String? phone,
    double? latitude,
    double? longitude,
  });

  /// Inicia sesión con email y contraseña
  Future<Either<Failure, User>> signInWithEmail({
    required String email,
    required String password,
  });

  /// Inicia sesión con Google OAuth
  Future<Either<Failure, User>> signInWithGoogle();

  /// Cierra la sesión actual
  Future<Either<Failure, void>> signOut();

  /// Envía email para resetear contraseña
  Future<Either<Failure, void>> resetPassword(String email);

  /// Obtiene el usuario actual (si existe)
  Future<Either<Failure, User?>> getCurrentUser();

  /// Verifica si hay un usuario autenticado
  Future<Either<Failure, bool>> isSignedIn();

  /// Actualiza el perfil del usuario
  Future<Either<Failure, User>> updateProfile(User user);

  /// Sube una imagen de avatar y retorna la URL
  Future<Either<Failure, String>> uploadAvatar(String userId, String filePath);
}