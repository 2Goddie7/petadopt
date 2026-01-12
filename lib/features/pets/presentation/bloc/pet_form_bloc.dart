import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/create_pet.dart';
import '../../domain/usecases/update_pet.dart';
import '../../domain/usecases/upload_pet_images.dart';
import 'pet_form_event.dart';
import 'pet_form_state.dart';

class PetFormBloc extends Bloc<PetFormEvent, PetFormState> {
  final CreatePet createPet;
  final UpdatePet updatePet;
  final UploadPetImages uploadPetImages;

  PetFormBloc({
    required this.createPet,
    required this.updatePet,
    required this.uploadPetImages,
  }) : super(const PetFormInitial()) {
    on<CreatePetEvent>(_onCreatePet);
    on<UpdatePetEvent>(_onUpdatePet);
    on<UploadImagesEvent>(_onUploadImages);
    on<ResetFormEvent>(_onResetForm);
  }

  Future<void> _onCreatePet(
    CreatePetEvent event,
    Emitter<PetFormState> emit,
  ) async {
    emit(const PetFormLoading());

    try {
      emit(const PetFormUploading(
        progress: 0.2,
        message: 'Creando mascota...',
      ));

      final result = await createPet(CreatePetParams(pet: event.pet));

      await result.fold(
        (failure) async {
          emit(PetFormError(message: failure.message));
        },
        (createdPet) async {
          if (event.images.isNotEmpty) {
            emit(const PetFormUploading(
              progress: 0.4,
              message: 'Subiendo imagenes...',
            ));

            // Pasar los XFile directamente (compatible con web y mobile)
            final uploadResult = await uploadPetImages(
              UploadPetImagesParams(
                shelterId: createdPet.shelterId,
                petId: createdPet.id,
                imagePaths: event.images,
              ),
            );

            await uploadResult.fold(
              (uploadFailure) async {
                emit(PetFormError(
                  message:
                      'Mascota creada pero fallo la subida de imagenes: ${uploadFailure.message}',
                ));
              },
              (imageUrls) async {
                emit(const PetFormUploading(
                  progress: 0.8,
                  message: 'Actualizando imagenes...',
                ));

                final petWithImages = createdPet.copyWith(
                  petImages: imageUrls,
                );

                final updateResult = await updatePet(
                  UpdatePetParams(pet: petWithImages),
                );

                updateResult.fold(
                  (updateFailure) => emit(PetFormError(
                    message:
                        'Mascota creada pero fallo la actualizacion de imagenes: ${updateFailure.message}',
                  )),
                  (finalPet) => emit(PetFormSuccess(
                    pet: finalPet,
                    message:
                        'Mascota creada exitosamente con ${imageUrls.length} imagen(es)',
                  )),
                );
              },
            );
          } else {
            emit(PetFormSuccess(
              pet: createdPet,
              message: 'Mascota creada exitosamente',
            ));
          }
        },
      );
    } catch (e) {
      emit(PetFormError(message: 'Error inesperado: ${e.toString()}'));
    }
  }

  Future<void> _onUpdatePet(
    UpdatePetEvent event,
    Emitter<PetFormState> emit,
  ) async {
    emit(const PetFormLoading());

    try {
      List<String> allUrls = event.pet.petImages;

      if (event.deleteImageUrls != null && event.deleteImageUrls!.isNotEmpty) {
        final urlsToDelete = event.deleteImageUrls!;
        allUrls.removeWhere((url) => urlsToDelete.contains(url));

        emit(const PetFormUploading(
          progress: 0.2,
          message: 'Eliminando imagenes...',
        ));
      }

      if (event.newImages != null && event.newImages!.isNotEmpty) {
        emit(PetFormUploading(
          progress: 0.4,
          message: 'Subiendo ${event.newImages!.length} nueva(s) imagen(es)...',
        ));

        // Pasar los XFile directamente (compatible con web y mobile)
        final uploadResult = await uploadPetImages(
          UploadPetImagesParams(
            shelterId: event.pet.shelterId,
            petId: event.pet.id,
            imagePaths: event.newImages!,
          ),
        );

        await uploadResult.fold(
          (failure) async {
            emit(PetFormError(
                message: 'Error al subir imagenes: ${failure.message}'));
          },
          (urls) async {
            allUrls.addAll(urls);

            emit(const PetFormUploading(
              progress: 0.7,
              message: 'Actualizando mascota...',
            ));

            final updatedPet = event.pet.copyWith(
              petImages: allUrls,
            );

            final result = await updatePet(UpdatePetParams(pet: updatedPet));

            result.fold(
              (failure) => emit(PetFormError(message: failure.message)),
              (pet) => emit(PetFormSuccess(
                pet: pet,
                message: 'Mascota actualizada exitosamente',
              )),
            );
          },
        );
      } else {
        emit(const PetFormUploading(
          progress: 0.5,
          message: 'Actualizando mascota...',
        ));

        final updatedPet = event.pet.copyWith(
          petImages: allUrls,
        );

        final result = await updatePet(UpdatePetParams(pet: updatedPet));

        result.fold(
          (failure) => emit(PetFormError(message: failure.message)),
          (pet) => emit(PetFormSuccess(
            pet: pet,
            message: 'Mascota actualizada exitosamente',
          )),
        );
      }
    } catch (e) {
      emit(PetFormError(message: 'Error inesperado: ${e.toString()}'));
    }
  }

  Future<void> _onUploadImages(
    UploadImagesEvent event,
    Emitter<PetFormState> emit,
  ) async {
    emit(const PetFormError(
      message: 'Use CreatePetEvent o UpdatePetEvent para gestionar imagenes',
    ));
  }

  void _onResetForm(
    ResetFormEvent event,
    Emitter<PetFormState> emit,
  ) {
    emit(const PetFormInitial());
  }
}
