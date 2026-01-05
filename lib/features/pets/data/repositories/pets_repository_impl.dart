import 'package:dartz/dartz.dart';
import '../../domain/entities/pet.dart';
import '../../domain/repositories/pets_repository.dart';
import '../datasources/pets_remote_data_source.dart';
import '../models/pet_model.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/error/exceptions.dart';

class PetsRepositoryImpl implements PetsRepository {
  final PetsRemoteDataSource remoteDataSource;

  PetsRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<Pet>>> getAllPets() async {
    try {
      final petModels = await remoteDataSource.getAllPets();
      final pets = petModels.map((model) => model.toEntity()).toList();
      return Right(pets);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, e.code));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message, e.code));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Pet>> getPetById(String petId) async {
    try {
      final petModel = await remoteDataSource.getPetById(petId);
      return Right(petModel.toEntity());
    } on NotFoundException catch (e) {
      return Left(NotFoundFailure(e.message, e.code));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, e.code));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message, e.code));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Pet>>> getPetsByShelter(String shelterId) async {
    try {
      final petModels = await remoteDataSource.getPetsByShelter(shelterId);
      final pets = petModels.map((model) => model.toEntity()).toList();
      return Right(pets);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, e.code));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message, e.code));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Pet>>> searchPets({
    String? species,
    String? gender,
    String? size,
    String? query,
  }) async {
    try {
      final petModels = await remoteDataSource.searchPets(
        species: species,
        gender: gender,
        size: size,
        query: query,
      );
      final pets = petModels.map((model) => model.toEntity()).toList();
      return Right(pets);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, e.code));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message, e.code));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Pet>> createPet(Pet pet) async {
    try {
      final petModel = PetModel.fromEntity(pet);
      final createdModel = await remoteDataSource.createPet(petModel);
      return Right(createdModel.toEntity());
    } on InvalidDataException catch (e) {
      return Left(InvalidDataFailure(e.message, e.code));
    } on DuplicateException catch (e) {
      return Left(DuplicateFailure(e.message, e.code));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, e.code));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message, e.code));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Pet>> updatePet(Pet pet) async {
    try {
      final petModel = PetModel.fromEntity(pet);
      final updatedModel = await remoteDataSource.updatePet(petModel);
      return Right(updatedModel.toEntity());
    } on NotFoundException catch (e) {
      return Left(NotFoundFailure(e.message, e.code));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, e.code));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message, e.code));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deletePet(String petId) async {
    try {
      await remoteDataSource.deletePet(petId);
      return const Right(null);
    } on NotFoundException catch (e) {
      return Left(NotFoundFailure(e.message, e.code));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, e.code));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message, e.code));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<String>>> uploadPetImages(
    String shelterId,
    String petId,
    List<String> imagePaths,
  ) async {
    try {
      final imageUrls = await remoteDataSource.uploadPetImages(
        shelterId,
        petId,
        imagePaths,
      );
      return Right(imageUrls);
    } on FileTooLargeException catch (e) {
      return Left(FileTooLargeFailure(e.message, e.code));
    } on InvalidFileTypeException catch (e) {
      return Left(InvalidFileTypeFailure(e.message, e.code));
    } on FileUploadException catch (e) {
      return Left(FileUploadFailure(e.message, e.code));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message, e.code));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> incrementViews(String petId) async {
    try {
      await remoteDataSource.incrementViews(petId);
      return const Right(null);
    } catch (e) {
      // No retornar error para esta operación no crítica
      return const Right(null);
    }
  }

  @override
  Future<Either<Failure, void>> updateAdoptionStatus(
    String petId,
    AdoptionStatus status,
  ) async {
    try {
      await remoteDataSource.updateAdoptionStatus(petId, status.toJson());
      return const Right(null);
    } on NotFoundException catch (e) {
      return Left(NotFoundFailure(e.message, e.code));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, e.code));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message, e.code));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }
}