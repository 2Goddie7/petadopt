import 'package:equatable/equatable.dart';
import 'package:image_picker/image_picker.dart';

abstract class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object?> get props => [];
}

/// Cargar perfil del usuario
class LoadProfileEvent extends ProfileEvent {
  final String userId;

  const LoadProfileEvent({required this.userId});

  @override
  List<Object?> get props => [userId];
}

/// Actualizar perfil
class UpdateProfileEvent extends ProfileEvent {
  final String fullName;
  final String? phone;
  final String? bio;
  final String? location;
  final double? latitude;
  final double? longitude;

  const UpdateProfileEvent({
    required this.fullName,
    this.phone,
    this.bio,
    this.location,
    this.latitude,
    this.longitude,
  });

  @override
  List<Object?> get props =>
      [fullName, phone, bio, location, latitude, longitude];
}

/// Subir imagen de perfil
class UploadProfileImageEvent extends ProfileEvent {
  final XFile imageFile;

  const UploadProfileImageEvent({required this.imageFile});

  @override
  List<Object?> get props => [imageFile];
}

/// Refrescar perfil
class RefreshProfileEvent extends ProfileEvent {
  const RefreshProfileEvent();
}
