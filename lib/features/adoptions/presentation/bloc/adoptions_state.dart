import 'package:equatable/equatable.dart';
import '../../domain/entities/adoption_request.dart';

abstract class AdoptionsState extends Equatable {
  const AdoptionsState();

  @override
  List<Object?> get props => [];
}

class AdoptionsInitial extends AdoptionsState {}

class AdoptionsLoading extends AdoptionsState {}

class AdoptionsLoaded extends AdoptionsState {
  final List<AdoptionRequest> requests;

  const AdoptionsLoaded({required this.requests});

  @override
  List<Object?> get props => [requests];
}

class AdoptionCreated extends AdoptionsState {
  final AdoptionRequest request;

  const AdoptionCreated({required this.request});

  @override
  List<Object?> get props => [request];
}

class AdoptionUpdated extends AdoptionsState {
  final AdoptionRequest? request;
  final String message;

  const AdoptionUpdated({
    this.request,
    required this.message,
  });

  @override
  List<Object?> get props => [request, message];
}

class AdoptionsError extends AdoptionsState {
  final String message;

  const AdoptionsError({required this.message});

  @override
  List<Object?> get props => [message];
}
