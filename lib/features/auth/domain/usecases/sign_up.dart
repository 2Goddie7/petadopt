import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';

class SignUp extends UseCaseWithParams<User, SignUpParams> {
  final AuthRepository repository;

  SignUp(this.repository);

  @override
  Future<Either<Failure, User>> call(SignUpParams params) async {
    return await repository.signUp(
      email: params.email,
      password: params.password,
      fullName: params.fullName,
      userType: params.userType,
      phone: params.phone,
      latitude: params.latitude,
      longitude: params.longitude,
    );
  }
}

class SignUpParams extends Equatable {
  final String email;
  final String password;
  final String fullName;
  final UserType userType;
  final String? phone;
  final double? latitude;
  final double? longitude;

  const SignUpParams({
    required this.email,
    required this.password,
    required this.fullName,
    required this.userType,
    this.phone,
    this.latitude,
    this.longitude,
  });

  @override
  List<Object?> get props => [email, password, fullName, userType, phone, latitude, longitude];
}