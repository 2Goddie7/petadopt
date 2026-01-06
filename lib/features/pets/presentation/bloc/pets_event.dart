import 'package:equatable/equatable.dart';
import '../../domain/entities/pet.dart';

abstract class PetsEvent extends Equatable {
  const PetsEvent();

  @override
  List<Object?> get props => [];
}

class LoadPetsEvent extends PetsEvent {}

class SearchPetsEvent extends PetsEvent {
  final PetSpecies? species;
  final PetSize? size;
  final String? city;

  const SearchPetsEvent({
    this.species,
    this.size,
    this.city,
  });

  @override
  List<Object?> get props => [species, size, city];
}

class RefreshPetsEvent extends PetsEvent {}
