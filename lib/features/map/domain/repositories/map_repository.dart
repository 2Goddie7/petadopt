import 'package:dartz/dartz.dart';
import '../entities/shelter.dart';
import '../../../../core/error/failures.dart';

// ============================================
// CONTRATO (DOMAIN)
// ============================================

abstract class MapRepository {
  Future<Either<Failure, Shelter>> createShelter(Shelter shelter);
  Future<Either<Failure, Shelter>> getShelterById(String shelterId);
  Future<Either<Failure, Shelter>> getShelterByProfileId(String profileId);
  Future<Either<Failure, List<Shelter>>> getAllShelters();
  Future<Either<Failure, Shelter>> updateShelter(Shelter shelter);
}

