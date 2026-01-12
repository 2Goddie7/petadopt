import 'package:image_picker/image_picker.dart';
import 'package:dartz/dartz.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/profile_repository.dart';
import '../datasources/profile_remote_data_source.dart';
import '../models/user_profile_model.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/error/exceptions.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDataSource remoteDataSource;

  ProfileRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, UserProfile>> getProfile(String userId) async {
    try {
      final profileModel = await remoteDataSource.getProfile(userId);
      return Right(profileModel.toEntity());
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
  Future<Either<Failure, UserProfile>> updateProfile(
      UserProfile profile) async {
    try {
      final profileModel = UserProfileModel.fromEntity(profile);
      final updatedModel = await remoteDataSource.updateProfile(profileModel);
      return Right(updatedModel.toEntity());
    } on NotFoundException catch (e) {
      return Left(NotFoundFailure(e.message, e.code));
    } on ValidationException catch (e) {
      return Left(ValidationFailure(e.message, e.code));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, e.code));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message, e.code));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> uploadProfileImage(
    String userId,
    XFile imageFile,
  ) async {
    try {
      final imageUrl = await remoteDataSource.uploadProfileImage(
        userId,
        imageFile,
      );
      return Right(imageUrl);
    } on ValidationException catch (e) {
      return Left(ValidationFailure(e.message, e.code));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, e.code));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message, e.code));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }
}
