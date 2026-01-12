import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/usecases/get_profile.dart';
import '../../domain/usecases/update_profile.dart';
import '../../domain/usecases/upload_profile_image.dart';
import '../../../auth/domain/usecases/get_current_user.dart';
import 'profile_event.dart';
import 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final GetProfile getProfile;
  final UpdateProfile updateProfile;
  final UploadProfileImage uploadProfileImage;
  final GetCurrentUser getCurrentUser;

  String? _currentUserId;

  ProfileBloc({
    required this.getProfile,
    required this.updateProfile,
    required this.uploadProfileImage,
    required this.getCurrentUser,
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

    // Si es shelter y hay coordenadas, actualizar la tabla shelters
    if (currentProfile.isShelter &&
        (event.latitude != null || event.longitude != null)) {
      try {
        final updateData = <String, dynamic>{};
        if (event.latitude != null) updateData['latitude'] = event.latitude;
        if (event.longitude != null) updateData['longitude'] = event.longitude;
        updateData['updated_at'] = DateTime.now().toIso8601String();

        await Supabase.instance.client
            .from('shelters')
            .update(updateData)
            .eq('profile_id', currentProfile.id);
      } catch (e) {
        print('Error actualizando coordenadas del shelter: $e');
      }
    }

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
      // Intentar cargar el perfil del usuario autenticado
      final userResult = await getCurrentUser();

      await userResult.fold(
        (failure) async {
          emit(const ProfileError(
              message: 'No se pudo obtener el usuario autenticado'));
        },
        (user) async {
          if (user == null) {
            emit(const ProfileError(message: 'Usuario no autenticado'));
            return;
          }

          // Cargar el perfil
          add(LoadProfileEvent(userId: user.id));

          // Esperar un momento y reintentar el upload
          await Future.delayed(const Duration(milliseconds: 500));
          add(UploadProfileImageEvent(imageFile: event.imageFile));
        },
      );
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
