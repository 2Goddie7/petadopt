import 'package:dartz/dartz.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';

class IsSignedIn extends UseCase<bool> {
  final AuthRepository repository;

  IsSignedIn(this.repository);

  @override
  Future<Either<Failure, bool>> call() async {
    return await repository.isSignedIn();
  }
}