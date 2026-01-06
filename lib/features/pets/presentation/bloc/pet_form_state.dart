import 'package:equatable/equatable.dart';
import '../../domain/entities/pet.dart';

abstract class PetFormState extends Equatable {
  const PetFormState();

  @override
  List<Object?> get props => [];
}

class PetFormInitial extends PetFormState {
  const PetFormInitial();
}

class PetFormLoading extends PetFormState {
  const PetFormLoading();
}

class PetFormUploading extends PetFormState {
  final double progress;
  final String message;

  const PetFormUploading({
    required this.progress,
    this.message = 'Subiendo imágenes...',
  });

  @override
  List<Object?> get props => [progress, message];
}

class PetFormSuccess extends PetFormState {
  final Pet pet;
  final String message;

  const PetFormSuccess({
    required this.pet,
    this.message = 'Operación exitosa',
  });

  @override
  List<Object?> get props => [pet, message];
}

class PetFormError extends PetFormState {
  final String message;

  const PetFormError({required this.message});

  @override
  List<Object?> get props => [message];
}
