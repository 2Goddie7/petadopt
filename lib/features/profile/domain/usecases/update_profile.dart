

class UpdateProfile extends UseCaseWithParams<User, UpdateProfileParams> {
  final AuthRepository repository;

  UpdateProfile(this.repository);

  @override
  Future<Either<Failure, User>> call(UpdateProfileParams params) async {
    return await repository.updateProfile(params.user);
  }
}

class UpdateProfileParams extends Equatable {
  final User user;

  const UpdateProfileParams({required this.user});

  @override
  List<Object> get props => [user];
}