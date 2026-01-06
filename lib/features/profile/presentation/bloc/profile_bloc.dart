import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_profile.dart';
import '../../domain/usecases/update_profile.dart';
import '../../domain/usecases/upload_profile_image.dart';
import 'profile_event.dart';
import 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final GetProfile getProfile;
  final UpdateProfile updateProfile;
  final UploadProfileImage uploadProfileImage;

  String? _currentUserId;

  ProfileBloc({
    required this.getProfile,
    required this.updateProfile,
    required this.uploadProfileImage,
  }) : super(ProfileInitial()) {
    on<LoadProfileEvent>(_onLoadProfile);
    on<UpdateProfileEvent>(_onUpdateProfile);
    on<UploadProfileImageEvent>(_onUploadProfileImage);
    on<RefreshProfileEvent>(_onRefreshProfile);
  }

  Future<void> _onLoadProfile(
    LoadProfileEvent event,
    Emitter<ProfileState> emit,
  ) async {
    emit(ProfileLoading());
    _currentUserId = event.userId;
    
    final result = await getProfile(
      GetProfileParams(userId: event.userId),
    );
    
    result.fold(
      (failure) => emit(ProfileError(message: failure.message)),
      (profile) => emit(ProfileLoaded(profile: profile)),
    );
  }

  Future<void> _onUpdateProfile(
    UpdateProfileEvent event,
    Emitter<ProfileState> emit,
  ) async {
    final currentState = state;
    final currentProfile = currentState is ProfileLoaded
        ? currentState.profile
        : currentState is ProfileUpdating
            ? currentState.currentProfile
            : null;

    if (currentProfile == null) {
      emit(const ProfileError(message: 'No hay perfil cargado'));
      return;
    }

    emit(ProfileUpdating(currentProfile: currentProfile));
    
    final updatedProfile = currentProfile.copyWith(
      fullName: event.fullName,
      phone: event.phone,
      bio: event.bio,
      location: event.location,
    );
    
    final result = await updateProfile(
      UpdateProfileParams(profile: updatedProfile),
    );
    
    result.fold(
      (failure) => emit(ProfileError(
        message: failure.message,
        previousProfile: currentProfile,
      )),
      (updatedProfile) => emit(ProfileUpdated(
        profile: updatedProfile,
        message: 'Perfil actualizado exitosamente',
      )),
    );
  }

  Future<void> _onUploadProfileImage(
    UploadProfileImageEvent event,
    Emitter<ProfileState> emit,
  ) async {
    final currentState = state;
    final currentProfile = currentState is ProfileLoaded
        ? currentState.profile
        : currentState is ProfileUpdating
            ? currentState.currentProfile
            : null;

    if (currentProfile == null) {
      emit(const ProfileError(message: 'No hay perfil cargado'));
      return;
    }

    emit(ProfileUpdating(currentProfile: currentProfile));
    
    final result = await uploadProfileImage(
      UploadProfileImageParams(
        userId: currentProfile.id,
        imageFile: event.imageFile,
      ),
    );
    
    result.fold(
      (failure) => emit(ProfileError(
        message: failure.message,
        previousProfile: currentProfile,
      )),
      (avatarUrl) {
        // Recargar perfil para obtener la URL actualizada
        if (_currentUserId != null) {
          add(LoadProfileEvent(userId: _currentUserId!));
        }
      },
    );
  }

  Future<void> _onRefreshProfile(
    RefreshProfileEvent event,
    Emitter<ProfileState> emit,
  ) async {
    if (_currentUserId != null) {
      add(LoadProfileEvent(userId: _currentUserId!));
    } else {
      emit(const ProfileError(message: 'Usuario no identificado'));
    }
  }
}
