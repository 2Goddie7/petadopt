import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../entities/user_profile.dart';
import '../repositories/profile_repository.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';

/// Obtiene el perfil de un usuario
class GetProfile extends UseCaseWithParams<UserProfile, GetProfileParams> {
  final ProfileRepository repository;

  GetProfile(this.repository);

  @override
  Future<Either<Failure, UserProfile>> call(GetProfileParams params) async {
    return await repository.getProfile(params.userId);
  }
}

class GetProfileParams extends Equatable {
  final String userId;

  const GetProfileParams({required this.userId});

  @override
  List<Object> get props => [userId];
}