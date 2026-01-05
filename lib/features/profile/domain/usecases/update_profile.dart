import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../entities/user_profile.dart';
import '../repositories/profile_repository.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';

/// Actualiza el perfil de un usuario
class UpdateProfile extends UseCaseWithParams<UserProfile, UpdateProfileParams> {
  final ProfileRepository repository;

  UpdateProfile(this.repository);

  @override
  Future<Either<Failure, UserProfile>> call(UpdateProfileParams params) async {
    return await repository.updateProfile(params.profile);
  }
}

class UpdateProfileParams extends Equatable {
  final UserProfile profile;

  const UpdateProfileParams({required this.profile});

  @override
  List<Object> get props => [profile];
}