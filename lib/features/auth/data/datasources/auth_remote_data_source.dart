import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';
import '../../../../core/error/exceptions.dart';

/// Contrato del Auth Remote Data Source
abstract class AuthRemoteDataSource {
  /// Registra un nuevo usuario con email y contraseña
  Future<UserModel> signUp({
    required String email,
    required String password,
    required String fullName,
    required String userType,
    String? phone,
  });

  /// Inicia sesión con email y contraseña
  Future<UserModel> signInWithEmail({
    required String email,
    required String password,
  });

  /// Inicia sesión con Google OAuth
  Future<UserModel> signInWithGoogle();

  /// Cierra la sesión actual
  Future<void> signOut();

  /// Envía email para resetear contraseña
  Future<void> resetPassword(String email);

  /// Obtiene el usuario actual
  Future<UserModel?> getCurrentUser();

  /// Verifica si hay un usuario autenticado
  Future<bool> isSignedIn();

  /// Actualiza el perfil del usuario
  Future<UserModel> updateProfile(UserModel user);

  /// Sube avatar del usuario
  Future<String> uploadAvatar(String userId, String filePath);
}

/// Implementación del Auth Remote Data Source con Supabase
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final SupabaseClient supabase;

  AuthRemoteDataSourceImpl({required this.supabase});

  @override
  Future<UserModel> signUp({
    required String email,
    required String password,
    required String fullName,
    required String userType,
    String? phone,
  }) async {
    try {
      // Registrar usuario en Supabase Auth
      final response = await supabase.auth.signUp(
        email: email,
        password: password,
        data: {
          'full_name': fullName,
          'user_type': userType,
          'phone': phone,
        },
      );

      if (response.user == null) {
        throw const ServerException('Error al crear la cuenta');
      }

      // El trigger de Supabase crea automáticamente el perfil
      // Esperar un momento para que se cree
      await Future.delayed(const Duration(milliseconds: 500));

      // Obtener el perfil creado
      final profileResponse = await supabase
          .from('profiles')
          .select()
          .eq('id', response.user!.id)
          .single();

      return UserModel.fromJson(profileResponse);
    } on AuthException catch (e) {
      if (e.message.contains('already registered')) {
        throw EmailAlreadyInUseException(e.message, e.statusCode);
      } else if (e.message.contains('Password should be')) {
        throw WeakPasswordException(e.message, e.statusCode);
      } else {
        throw ServerException(e.message, e.statusCode);
      }
    } on PostgrestException catch (e) {
      throw ServerException(e.message, e.code);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<UserModel> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final response = await supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user == null) {
        throw const InvalidCredentialsException();
      }

      // Obtener perfil del usuario
      final profileResponse = await supabase
          .from('profiles')
          .select()
          .eq('id', response.user!.id)
          .single();

      return UserModel.fromJson(profileResponse);
    } on AuthException catch (e) {
      if (e.message.contains('Invalid login credentials')) {
        throw InvalidCredentialsException(e.message, e.statusCode);
      } else if (e.message.contains('Email not confirmed')) {
        throw const UnauthorizedException('Confirma tu email primero');
      } else {
        throw ServerException(e.message, e.statusCode);
      }
    } on PostgrestException catch (e) {
      if (e.code == 'PGRST116') {
        throw const UserNotFoundException();
      }
      throw ServerException(e.message, e.code);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

@override
Future<UserModel> signInWithGoogle() async {
  try {
    final started = await supabase.auth.signInWithOAuth(
      OAuthProvider.google,
      redirectTo: 'petadopt://callback',
    );

    if (!started) {
      throw const ServerException('No se pudo iniciar Google OAuth');
    }

    // Esperar a que el SDK establezca la sesión
    for (int i = 0; i < 10; i++) {
      final user = supabase.auth.currentUser;
      if (user != null) {
        // Intentar obtener perfil creado por trigger
        final profile = await supabase
            .from('profiles')
            .select()
            .eq('id', user.id)
            .maybeSingle();

        if (profile != null) {
          return UserModel.fromJson(profile);
        }
      }

      await Future.delayed(const Duration(milliseconds: 300));
    }

    throw const ServerException(
      'No se pudo obtener el perfil del usuario',
    );
  } on AuthException catch (e) {
    throw ServerException(e.message, e.statusCode);
  } on PostgrestException catch (e) {
    throw ServerException(e.message, e.code);
  } catch (e) {
    throw ServerException(e.toString());
  }
}

   
//CERRAR SESION 
  @override
  Future<void> signOut() async {
    try {
      await supabase.auth.signOut();
    } on AuthException catch (e) {
      throw ServerException(e.message, e.statusCode);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> resetPassword(String email) async {
    try {
      await supabase.auth.resetPasswordForEmail(
        email,
        redirectTo: 'https://your-app.com/reset-password',
      );
    } on AuthException catch (e) {
      throw ServerException(e.message, e.statusCode);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    try {
      final user = supabase.auth.currentUser;
      if (user == null) return null;

      final profileResponse = await supabase
          .from('profiles')
          .select()
          .eq('id', user.id)
          .single();

      return UserModel.fromJson(profileResponse);
    } on PostgrestException catch (e) {
      if (e.code == 'PGRST116') {
        return null;
      }
      throw ServerException(e.message, e.code);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<bool> isSignedIn() async {
    try {
      final session = supabase.auth.currentSession;
      return session != null;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<UserModel> updateProfile(UserModel user) async {
    try {
      final updateData = user.toJsonForUpdate();

      await supabase
          .from('profiles')
          .update(updateData)
          .eq('id', user.id);

      final updatedProfile = await supabase
          .from('profiles')
          .select()
          .eq('id', user.id)
          .single();

      return UserModel.fromJson(updatedProfile);
    } on PostgrestException catch (e) {
      throw ServerException(e.message, e.code);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<String> uploadAvatar(String userId, String filePath) async {
    try {
      final fileName = 'avatar_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final path = '$userId/$fileName';

      final imageFile = File(filePath);

      await supabase.storage
          .from('profile-avatars')
          .upload(path, imageFile);

      final publicUrl = supabase.storage
          .from('profile-avatars')
          .getPublicUrl(path);

      return publicUrl;
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
}