import 'package:equatable/equatable.dart';
import '../../domain/entities/pet.dart';

abstract class PetDetailState extends Equatable {
  const PetDetailState();

  @override
  List<Object?> get props => [];
}

class PetDetailInitial extends PetDetailState {}

class PetDetailLoading extends PetDetailState {}

class PetDetailLoaded extends PetDetailState {
  final Pet pet;

  const PetDetailLoaded({required this.pet});

  @override
  List<Object?> get props => [pet];
}

class PetDetailError extends PetDetailState {
  final String message;

  const PetDetailError({required this.message});

  @override
  List<Object?> get props => [message];
}
