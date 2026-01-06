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
      final currentUser = supabase.auth.currentUser;
      
      if (currentUser == null) {
        return const Left(UnauthorizedFailure('Usuario no autenticado'));
      }

      // Verificar que el usuario sea de tipo shelter
      final userType = currentUser.userMetadata?['user_type'] as String?;
      if (userType != 'shelter') {
        return const Left(UnauthorizedFailure('El usuario no es un refugio'));
      }

      // Obtener el shelter_id desde Supabase
      final response = await supabase
          .from('shelters')
          .select('id')
          .eq('profile_id', currentUser.id)
          .maybeSingle();

      if (response == null) {
        return const Left(NotFoundFailure('No se encontró el refugio asociado. Por favor, crea tu refugio primero.'));
      }

      return Right(response['id'] as String);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
