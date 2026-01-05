import 'package:dartz/dartz.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';

class SignOut extends UseCase<void> {
  final AuthRepository repository;

  SignOut(this.repository);

  @override
  Future<Either<Failure, void>> call() async {
    return await repository.signOut();
  }
}