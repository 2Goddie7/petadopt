import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';
import '../../../../core/constants/api_constants.dart';
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
    double? latitude,
    double? longitude,
  });

  /// Inicia sesión con email y contraseña
  Future<UserModel> signInWithEmail({
    required String email,
    required String password,
  });

  /// Inicia sesión con Google OAuth
  Future<UserModel> signInWithGoogle();

  /// Completa el perfil OAuth después de seleccionar rol
  Future<UserModel> completeOAuthProfile({
    required String userId,
    required String userType,
    String? phone,
  });

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
    double? latitude,
    double? longitude,
  }) async {
    try {
      print('📝 SignUp - Iniciando registro...');
      print('📝 Email: $email');
      print('📝 Full Name: $fullName');
      print('📝 User Type: $userType');
      print('📝 Phone: $phone');

      // Registrar usuario en Supabase Auth (CORREGIDO: user_type y full_name)
      final response = await supabase.auth.signUp(
        email: email,
        password: password,
        emailRedirectTo: 'https://auth-pet-three.vercel.app/verify',
        data: {
          'full_name': fullName,
          'user_type': userType, // IMPORTANTE: debe ser user_type, no role
          'phone': phone,
          if (latitude != null) 'latitude': latitude.toString(),
          if (longitude != null) 'longitude': longitude.toString(),
        },
      );

      print('✅ SignUp - Respuesta de Supabase recibida');

      if (response.user == null) {
        print('❌ SignUp - Usuario nulo en la respuesta');
        throw const ServerException('Error al crear la cuenta');
      }

      print('✅ SignUp - Usuario creado: ${response.user!.id}');
      print('✅ SignUp - Metadata: ${response.user!.userMetadata}');

      // IMPORTANTE: Verificar que la sesión esté activa
      final session = response.session;
      if (session == null) {
        print('⚠️ SignUp - No hay sesión activa, necesitas confirmar el email');
        throw const ServerException(
            'Por favor, confirma tu email antes de continuar');
      }

      print(
          '✅ SignUp - Sesión activa: ${session.accessToken.substring(0, 20)}...');

      // El trigger de Supabase crea automáticamente el perfil
      // Esperar un momento para que se cree
      await Future.delayed(const Duration(seconds: 2));

      // Obtener el perfil creado
      final profileResponse = await supabase
          .from('profiles')
          .select()
          .eq('id', response.user!.id)
          .maybeSingle();

      print('✅ SignUp - Perfil verificado: $profileResponse');

      if (profileResponse == null) {
        print(
            '⚠️ SignUp - Perfil no encontrado, intentando crear manualmente...');
        try {
          // Crear perfil manualmente si el trigger falló
          await supabase.from('profiles').insert({
            'id': response.user!.id,
            'email': email,
            'full_name': fullName,
            'user_type': userType,
            'phone': phone,
          });

          // Si es shelter, crear el registro de shelter también
          if (userType == 'shelter') {
            print('🏠 SignUp - Creando registro de shelter...');
            await supabase.from('shelters').insert({
              'profile_id': response.user!.id,
              'shelter_name': fullName,
              'address': 'Dirección no especificada',
              'city': 'Quito',
              'country': 'Ecuador',
              'latitude': latitude ?? -0.180653,
              'longitude': longitude ?? -78.467834,
              'phone': phone ?? '0000-0000',
            });
            print('✅ SignUp - Shelter creado correctamente');
          }

          // Obtener el perfil recién creado
          final newProfileResponse = await supabase
              .from('profiles')
              .select()
              .eq('id', response.user!.id)
              .single();

          return UserModel.fromJson(newProfileResponse);
        } on PostgrestException catch (e) {
          print('❌ SignUp - Error al crear perfil manualmente: ${e.message}');
          // RLS or permission errors
          if (e.message.contains('violates row level security') ||
              e.message.contains('permission denied')) {
            throw ServerException(
                'No tienes permisos para guardar el perfil. Por favor ejecuta el script fix_registration_error.sql en Supabase.',
                e.code);
          }

          if (e.code == '23505') {
            // Duplicate key - try reading existing
            try {
              final existing = await supabase
                  .from('profiles')
                  .select()
                  .eq('id', response.user!.id)
                  .single();
              return UserModel.fromJson(existing);
            } catch (_) {
              throw ServerException(
                  'El usuario ya existe pero no se pudo leer.', e.code);
            }
          }

          throw ServerException(
              'Error de Base de Datos al guardar usuario: ${e.message}',
              e.code);
        }
      }

      // Verificar que currentUser esté disponible
      final currentUser = supabase.auth.currentUser;
      print(
          '🔍 SignUp - Usuario actual después del registro: ${currentUser?.id}');

      if (currentUser == null) {
        print(
            '❌ SignUp - ADVERTENCIA: currentUser es null después del registro');
      }

      return UserModel.fromJson(profileResponse);
    } on AuthException catch (e) {
      print('❌ SignUp - AuthException: ${e.message}');
      if (e.message.contains('already registered')) {
        throw EmailAlreadyInUseException(e.message, e.statusCode);
      } else if (e.message.contains('Password should be')) {
        throw WeakPasswordException(e.message, e.statusCode);
      } else {
        throw ServerException(e.message, e.statusCode);
      }
    } on PostgrestException catch (e) {
      print('❌ SignUp - PostgrestException: ${e.message}');
      throw ServerException(e.message, e.code);
    } catch (e) {
      print('❌ SignUp - Error desconocido: $e');
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
      print('🔐 OAuth - Iniciando Google Sign In...');
      print('📱 Redirect URI: ${_buildOAuthRedirectUri()}');

      final Completer<UserModel> completer = Completer<UserModel>();
      late StreamSubscription<AuthState> subscription;

      // Escuchar cambios de autenticación
      subscription = supabase.auth.onAuthStateChange.listen(
        (AuthState data) async {
          print('🔔 OAuth - AuthState cambió: ${data.event}');

          if (data.event == AuthChangeEvent.signedIn ||
              data.event == AuthChangeEvent.userUpdated) {
            final user = data.session?.user ?? supabase.auth.currentUser;

            if (user != null && !completer.isCompleted) {
              try {
                print('✅ OAuth - Usuario autenticado: ${user.email}');
                final userModel = await _ensureUserProfileExists(user);
                completer.complete(userModel);
              } catch (e) {
                if (!completer.isCompleted) {
                  completer.completeError(e);
                }
              } finally {
                await subscription.cancel();
              }
            }
          }
        },
        onError: (error) {
          print('❌ OAuth - Error en onAuthStateChange: $error');
          if (!completer.isCompleted) {
            completer.completeError(error);
          }
        },
      );

      // Iniciar el flujo OAuth
      print('🔄 OAuth - Iniciando signInWithOAuth...');
      final bool started = await supabase.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: _buildOAuthRedirectUri(),
        scopes: 'email profile openid',
      );

      if (!started) {
        print('❌ OAuth - signInWithOAuth devolvió false');
        await subscription.cancel();
        throw const ServerException(
          'No se pudo abrir Google. Verifica la configuración en Supabase.',
        );
      }

      print('⏳ OAuth - Esperando respuesta del usuario...');

      // Esperar con timeout de 120 segundos
      return await completer.future.timeout(
        const Duration(seconds: 120),
        onTimeout: () {
          print('⏱️ OAuth - Timeout esperando respuesta');
          subscription.cancel();

          // Verificar si acaso la sesión se procesó pero no llegó el evento
          final currentUser = supabase.auth.currentUser;
          if (currentUser != null) {
            print('✅ OAuth - Usuario encontrado en timeout');
            return _ensureUserProfileExists(currentUser);
          }

          throw const ServerException(
            'La autenticación tardó demasiado. Intenta nuevamente.',
          );
        },
      );
    } on SocketException {
      print('❌ OAuth - Sin conexión a internet');
      throw const NetworkException('Sin conexión a internet');
    } on AuthException catch (e) {
      print('❌ OAuth - AuthException: ${e.message}');
      throw ServerException(e.message, e.statusCode);
    } catch (e) {
      print('❌ OAuth - Error: $e');
      if (e is AppException) rethrow;
      throw ServerException(e.toString());
    }
  }

  /// Método auxiliar privado para garantizar que el perfil exista en base de datos
  Future<UserModel> _ensureUserProfileExists(User user) async {
    print(
        '👤 OAuth - Esperando a que Supabase cree el perfil automáticamente...');

    // Estrategia optimizada:
    // 1. Intentar leer rápido (Polling corto de 200ms)
    // 2. Si tarda más de 2 segundos, intentar crearlo manualmente (Fallback)

    for (int i = 0; i < 15; i++) {
      // 15 intentos * 200ms = 3 segundos
      try {
        final profileData = await supabase
            .from('profiles')
            .select()
            .eq('id', user.id)
            .maybeSingle();

        if (profileData != null) {
          print('✅ OAuth - Perfil encontrado en la BD');
          return UserModel.fromJson(profileData);
        }

        // Si llevamos 10 intentos (2 segundos) y nada, intentar crear
        if (i == 10) {
          print(
              '⚠️ OAuth - Perfil tarda en aparecer. Intentando crear fallback...');
          try {
            await supabase.from('profiles').upsert({
              'id': user.id,
              'email': user.email,
              'full_name': user.userMetadata?['full_name'] ??
                  user.userMetadata?['name'] ??
                  user.email!.split('@')[0],
              'user_type': null, // Dejar null para que pida rol
              'phone': user.userMetadata?['phone'],
            });
            print('✅ OAuth - Fallback creado exitosamente');
          } catch (e) {
            print('⚠️ OAuth - Fallback falló (quizás ya se creó): $e');
          }
        }

        // Wait minimal time
        await Future.delayed(const Duration(milliseconds: 200));
      } catch (e) {
        print('⚠️ OAuth - Error al leer perfil (intento ${i + 1}): $e');
        await Future.delayed(const Duration(milliseconds: 500));
      }
    }

    // fallback si todo falla
    print(
        '❌ OAuth - Timeout esperando perfil, usando fallback final en memoria');
    return UserModel(
      id: user.id,
      email: user.email!,
      fullName: user.userMetadata?['full_name'] ??
          user.userMetadata?['name'] ??
          user.email!.split('@')[0],
      userType: null,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  String _buildOAuthRedirectUri() {
    if (kIsWeb) {
      return ApiConstants.googleRedirectUrl;
    }

    if (Platform.isAndroid || Platform.isIOS) {
      return 'petadopt://callback';
    }

    return ApiConstants.googleRedirectUrl;
  }

  @override
  Future<UserModel> completeOAuthProfile({
    required String userId,
    required String userType,
    String? phone,
  }) async {
    try {
      print('📝 OAuth - Completando perfil para $userId con rol $userType');

      // Llamar a la función SQL que completa el perfil y devuelve el JSON actualizado
      // Cambiamos a rpc que retorna datos para evitar el error "Cannot coerce..." del select posterior
      final data = await supabase.rpc('complete_oauth_profile', params: {
        'p_user_id': userId,
        'p_user_type': userType,
        if (phone != null) 'p_phone': phone,
      });

      print('✅ OAuth - Perfil actualizado recibido: $data');

      // Si data es null o vacío, intentar leerlo manualmente como fallback
      if (data == null) {
        print('⚠️ OAuth - RPC devolvió null, leyendo perfil manualmente...');
        final profile =
            await supabase.from('profiles').select().eq('id', userId).single();
        return UserModel.fromJson(profile);
      }

      // Convertir la respuesta del RPC a UserModel
      // RPC devuelve un Map<String, dynamic> o similar
      return UserModel.fromJson(Map<String, dynamic>.from(data));
    } on PostgrestException catch (e) {
      print('❌ OAuth - Error SQL: ${e.message}');
      throw ServerException('Error al guardar el rol: ${e.message}', e.code);
    } catch (e) {
      print('❌ OAuth - Error desconocido: $e');
      throw ServerException('Error al completar perfil: $e');
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
        redirectTo: 'https://auth-pet-three.vercel.app/reset-password',
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

      final profileResponse =
          await supabase.from('profiles').select().eq('id', user.id).single();

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

      await supabase.from('profiles').update(updateData).eq('id', user.id);

      final updatedProfile =
          await supabase.from('profiles').select().eq('id', user.id).single();

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

      await supabase.storage.from('profile-avatars').upload(path, imageFile);

      final publicUrl =
          supabase.storage.from('profile-avatars').getPublicUrl(path);

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
