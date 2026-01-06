import 'package:equatable/equatable.dart';
import '../../domain/entities/user_profile.dart';

abstract class ProfileState extends Equatable {
  const ProfileState();

  @override
  List<Object?> get props => [];
}

class ProfileInitial extends ProfileState {}

class ProfileLoading extends ProfileState {}

class ProfileLoaded extends ProfileState {
  final UserProfile profile;

  const ProfileLoaded({required this.profile});

  @override
  List<Object?> get props => [profile];
}

class ProfileUpdating extends ProfileState {
  final UserProfile currentProfile;

  const ProfileUpdating({required this.currentProfile});

  @override
  List<Object?> get props => [currentProfile];
}

class ProfileUpdated extends ProfileState {
  final UserProfile profile;
  final String message;

  const ProfileUpdated({
    required this.profile,
    required this.message,
  });

  @override
  List<Object?> get props => [profile, message];
}

class ProfileError extends ProfileState {
  final String message;
  final UserProfile? previousProfile;

  const ProfileError({
    required this.message,
    this.previousProfile,
  });

  @override
  List<Object?> get props => [message, previousProfile];
}
