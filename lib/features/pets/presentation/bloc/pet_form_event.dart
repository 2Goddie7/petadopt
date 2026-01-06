import 'package:equatable/equatable.dart';
import 'package:image_picker/image_picker.dart';
import '../../domain/entities/pet.dart';

abstract class PetFormEvent extends Equatable {
  const PetFormEvent();

  @override
  List<Object?> get props => [];
}

class CreatePetEvent extends PetFormEvent {
  final Pet pet;
  final List<XFile> images;

  const CreatePetEvent({
    required this.pet,
    required this.images,
  });

  @override
  List<Object?> get props => [pet, images];
}

class UpdatePetEvent extends PetFormEvent {
  final Pet pet;
  final List<XFile>? newImages;
  final List<String>? deleteImageUrls;

  const UpdatePetEvent({
    required this.pet,
    this.newImages,
    this.deleteImageUrls,
  });

  @override
  List<Object?> get props => [pet, newImages, deleteImageUrls];
}

class UploadImagesEvent extends PetFormEvent {
  final List<XFile> images;

  const UploadImagesEvent({required this.images});

  @override
  List<Object?> get props => [images];
}

class ResetFormEvent extends PetFormEvent {
  const ResetFormEvent();
}
