import 'package:dartz/dartz.dart';
import '../../domain/entities/shelter.dart';
import '../../domain/repositories/map_repository.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';

// ============================================
// GET ALL SHELTERS
// ============================================

class GetAllShelters extends UseCase<List<Shelter>> {
  final MapRepository repository;

  GetAllShelters(this.repository);

  @override
  Future<Either<Failure, List<Shelter>>> call() async {
    return await repository.getAllShelters();
  }
}