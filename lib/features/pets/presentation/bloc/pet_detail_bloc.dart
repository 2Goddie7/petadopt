import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_pet_by_id.dart';
import '../../domain/usecases/increment_views.dart';
import 'pet_detail_event.dart';
import 'pet_detail_state.dart';

class PetDetailBloc extends Bloc<PetDetailEvent, PetDetailState> {
  final GetPetById getPetById;
  final IncrementPetViews incrementViews;

  String? _currentPetId;

  PetDetailBloc({
    required this.getPetById,
    required this.incrementViews,
  }) : super(PetDetailInitial()) {
    on<LoadPetDetailEvent>(_onLoadPetDetail);
    on<IncrementPetViewsEvent>(_onIncrementViews);
    on<RefreshPetDetailEvent>(_onRefreshPetDetail);
  }

  Future<void> _onLoadPetDetail(
    LoadPetDetailEvent event,
    Emitter<PetDetailState> emit,
  ) async {
    emit(PetDetailLoading());
    _currentPetId = event.petId;
    
    final result = await getPetById(GetPetByIdParams(petId: event.petId));
    
    result.fold(
      (failure) => emit(PetDetailError(message: failure.message)),
      (pet) {
        emit(PetDetailLoaded(pet: pet));
        // Incrementar vistas automáticamente al cargar
        add(IncrementPetViewsEvent(petId: event.petId));
      },
    );
  }

  Future<void> _onIncrementViews(
    IncrementPetViewsEvent event,
    Emitter<PetDetailState> emit,
  ) async {
    // Incrementar sin cambiar el estado actual
    await incrementViews(IncrementViewsParams(petId: event.petId));
  }

  Future<void> _onRefreshPetDetail(
    RefreshPetDetailEvent event,
    Emitter<PetDetailState> emit,
  ) async {
    if (_currentPetId != null) {
      // No incrementar vistas en refresh
      emit(PetDetailLoading());
      final result = await getPetById(GetPetByIdParams(petId: _currentPetId!));
      
      result.fold(
        (failure) => emit(PetDetailError(message: failure.message)),
        (pet) => emit(PetDetailLoaded(pet: pet)),
      );
    }
  }
}
