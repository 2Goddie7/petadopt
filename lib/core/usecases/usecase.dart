import 'package:dartz/dartz.dart';
import '../error/failures.dart';

/// Clase base para Use Cases sin parámetros
abstract class UseCase<Type> {
  Future<Either<Failure, Type>> call();
}

/// Clase base para Use Cases con parámetros
abstract class UseCaseWithParams<Type, Params> {
  Future<Either<Failure, Type>> call(Params params);
}

/// Clase para representar ausencia de parámetros
class NoParams {
  const NoParams();
}