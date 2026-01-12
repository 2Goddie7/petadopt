import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

/// Parámetros para completar perfil OAuth
class CompleteOAuthProfileParams {
  final String userId;
  final String userType;
  final String? phone;

  CompleteOAuthProfileParams({
    required this.userId,
    required this.userType,
    this.phone,
  });
}

/// Use case: Completar perfil OAuth después de seleccionar rol
class CompleteOAuthProfile
    implements UseCaseWithParams<User, CompleteOAuthProfileParams> {
  final AuthRepository repository;

  CompleteOAuthProfile(this.repository);

  @override
  Future<Either<Failure, User>> call(CompleteOAuthProfileParams params) async {
    return await repository.completeOAuthProfile(
      userId: params.userId,
      userType: params.userType,
      phone: params.phone,
    );
  }
}
