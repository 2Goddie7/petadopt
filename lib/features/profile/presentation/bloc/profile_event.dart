import 'package:equatable/equatable.dart';
import 'dart:io';

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

  const UpdateProfileEvent({
    required this.fullName,
    this.phone,
    this.bio,
    this.location,
  });

  @override
  List<Object?> get props => [fullName, phone, bio, location];
}

/// Subir imagen de perfil
class UploadProfileImageEvent extends ProfileEvent {
  final File imageFile;

  const UploadProfileImageEvent({required this.imageFile});

  @override
  List<Object?> get props => [imageFile];
}

/// Refrescar perfil
class RefreshProfileEvent extends ProfileEvent {
  const RefreshProfileEvent();
}
