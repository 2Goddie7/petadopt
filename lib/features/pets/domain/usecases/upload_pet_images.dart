import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../domain/repositories/pets_repository.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';

// ============================================
// UPLOAD PET IMAGES
// ============================================

class UploadPetImages extends UseCaseWithParams<List<String>, UploadPetImagesParams> {
  final PetsRepository repository;

  UploadPetImages(this.repository);

  @override
  Future<Either<Failure, List<String>>> call(UploadPetImagesParams params) async {
    return await repository.uploadPetImages(
      params.shelterId,
      params.petId,
      params.imagePaths,
    );
  }
}

class UploadPetImagesParams extends Equatable {
  final String shelterId;
  final String petId;
  final List<String> imagePaths;

  const UploadPetImagesParams({
    required this.shelterId,
    required this.petId,
    required this.imagePaths,
  });

  @override
  List<Object> get props => [shelterId, petId, imagePaths];
}