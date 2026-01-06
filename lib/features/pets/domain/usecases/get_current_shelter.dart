import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';

/// Use case para obtener el shelter_id del usuario autenticado (si es refugio)
class GetCurrentShelter extends UseCase<String> {
  final SupabaseClient supabase;

  GetCurrentShelter(this.supabase);

  @override
  Future<Either<Failure, String>> call() async {
    try {
      // Verificar sesión primero
      final session = supabase.auth.currentSession;
      print('🔍 GetCurrentShelter - Sesión activa: ${session != null}');
      
      if (session == null) {
        print('❌ GetCurrentShelter - No hay sesión activa');
        return const Left(UnauthorizedFailure('No hay sesión activa. Por favor, inicia sesión nuevamente.'));
      }

      final currentUser = supabase.auth.currentUser;
      
      print('🔍 GetCurrentShelter - Usuario actual: ${currentUser?.id}');
      print('🔍 GetCurrentShelter - Email: ${currentUser?.email}');
      
      if (currentUser == null) {
        print('❌ GetCurrentShelter - Usuario no autenticado (pero sesión existe)');
        return const Left(UnauthorizedFailure('Usuario no autenticado'));
      }

      // Verificar que el usuario sea de tipo shelter
      final userMetadata = currentUser.userMetadata;
      print('🔍 GetCurrentShelter - Metadata completo: $userMetadata');
      
      final userType = userMetadata?['user_type'] as String?;
      print('🔍 GetCurrentShelter - Tipo de usuario: $userType');
      
      if (userType != 'shelter') {
        print('❌ GetCurrentShelter - El usuario no es un refugio');
        
        // Verificar en la base de datos también
        final profileCheck = await supabase
            .from('profiles')
            .select('user_type')
            .eq('id', currentUser.id)
            .maybeSingle();
        
        print('🔍 GetCurrentShelter - Tipo en BD: ${profileCheck?['user_type']}');
        
        if (profileCheck?['user_type'] == 'shelter') {
          print('⚠️ GetCurrentShelter - Metadata desactualizado, pero es shelter en BD');
          // Continuar con la búsqueda del shelter
        } else {
          return Left(UnauthorizedFailure('El usuario no es un refugio. Tipo actual: $userType'));
        }
      }

      // Obtener el shelter_id desde Supabase
      print('🔍 GetCurrentShelter - Buscando refugio para profile_id: ${currentUser.id}');
      final response = await supabase
          .from('shelters')
          .select('id, shelter_name')
          .eq('profile_id', currentUser.id)
          .maybeSingle();

      print('🔍 GetCurrentShelter - Respuesta de Supabase: $response');

      if (response == null) {
        print('❌ GetCurrentShelter - No se encontró el refugio en la BD');
        
        // Verificar si el perfil existe
        final profileExists = await supabase
            .from('profiles')
            .select('id, user_type')
            .eq('id', currentUser.id)
            .maybeSingle();
        
        print('🔍 GetCurrentShelter - Perfil existe: $profileExists');
        
        return const Left(NotFoundFailure('No se encontró el refugio asociado. El perfil existe pero no hay registro en shelters.'));
      }

      final shelterId = response['id'] as String;
      final shelterName = response['shelter_name'] as String;
      print('✅ GetCurrentShelter - Refugio encontrado: $shelterId ($shelterName)');
      return Right(shelterId);
    } catch (e) {
      print('❌ GetCurrentShelter - Error: $e');
      return Left(ServerFailure(e.toString()));
    }
  }
}
