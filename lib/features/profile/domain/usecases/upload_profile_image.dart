import 'package:image_picker/image_picker.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../repositories/profile_repository.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';

/// Sube la imagen de perfil de un usuario
class UploadProfileImage
    extends UseCaseWithParams<String, UploadProfileImageParams> {
  final ProfileRepository repository;

  UploadProfileImage(this.repository);

  @override
  Future<Either<Failure, String>> call(UploadProfileImageParams params) async {
    return await repository.uploadProfileImage(
      params.userId,
      params.imageFile,
    );
  }
}

class UploadProfileImageParams extends Equatable {
  final String userId;
  final XFile imageFile;

  const UploadProfileImageParams({
    required this.userId,
    required this.imageFile,
  });

  @override
  List<Object> get props => [userId, imageFile];
}
