import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/adoption_request.dart';
import '../../domain/usecases/approve_request.dart';
import '../../domain/usecases/cancel_request.dart';
import '../../domain/usecases/create_adoption_request.dart';
import '../../domain/usecases/get_shelter_requests.dart';
import '../../domain/usecases/get_user_requests.dart';
import '../../domain/usecases/reject_request.dart';
import 'adoptions_event.dart';
import 'adoptions_state.dart';

class AdoptionsBloc extends Bloc<AdoptionsEvent, AdoptionsState> {
  final GetUserRequests getUserRequests;
  final GetShelterRequests getShelterRequests;
  final CreateAdoptionRequest createAdoptionRequest;
  final ApproveRequest approveRequest;
  final RejectRequest rejectRequest;
  final CancelRequest cancelRequest;

  AdoptionsBloc({
    required this.getUserRequests,
    required this.getShelterRequests,
    required this.createAdoptionRequest,
    required this.approveRequest,
    required this.rejectRequest,
    required this.cancelRequest,
  }) : super(AdoptionsInitial()) {
    on<LoadMyRequestsEvent>(_onLoadMyRequests);
    on<LoadShelterRequestsEvent>(_onLoadShelterRequests);
    on<CreateAdoptionRequestEvent>(_onCreateRequest);
    on<ApproveRequestEvent>(_onApproveRequest);
    on<RejectRequestEvent>(_onRejectRequest);
    on<CancelRequestEvent>(_onCancelRequest);
    on<RefreshAdoptionsEvent>(_onRefreshAdoptions);
  }

  Future<void> _onLoadMyRequests(
    LoadMyRequestsEvent event,
    Emitter<AdoptionsState> emit,
  ) async {
    emit(AdoptionsLoading());
    
    final result = await getUserRequests(
      GetUserRequestsParams(userId: event.userId),
    );
    
    result.fold(
      (failure) => emit(AdoptionsError(message: failure.message)),
      (requests) => emit(AdoptionsLoaded(requests: requests)),
    );
  }

  Future<void> _onLoadShelterRequests(
    LoadShelterRequestsEvent event,
    Emitter<AdoptionsState> emit,
  ) async {
    emit(AdoptionsLoading());
    
    final result = await getShelterRequests(
      GetShelterRequestsParams(shelterId: event.shelterId),
    );
    
    result.fold(
      (failure) => emit(AdoptionsError(message: failure.message)),
      (requests) => emit(AdoptionsLoaded(requests: requests)),
    );
  }

  Future<void> _onCreateRequest(
    CreateAdoptionRequestEvent event,
    Emitter<AdoptionsState> emit,
  ) async {
    emit(AdoptionsLoading());
    
    // Crear request mínimo (el repository completará los datos)
    final request = AdoptionRequest(
      id: '',  // Se generará en el servidor
      petId: event.petId,
      adopterId: '', // El repository lo obtendrá del usuario actual
      shelterId: '', // El repository lo obtendrá del pet
      message: event.message,
      status: RequestStatus.pending,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    
    final result = await createAdoptionRequest(
      CreateRequestParams(request: request),
    );
    
    result.fold(
      (failure) => emit(AdoptionsError(message: failure.message)),
      (request) => emit(AdoptionCreated(request: request)),
    );
  }

  Future<void> _onApproveRequest(
    ApproveRequestEvent event,
    Emitter<AdoptionsState> emit,
  ) async {
    emit(AdoptionsLoading());
    
    final result = await approveRequest(
      ApproveRequestParams(requestId: event.requestId),
    );
    
    result.fold(
      (failure) => emit(AdoptionsError(message: failure.message)),
      (request) => emit(AdoptionUpdated(
        request: request,
        message: 'Solicitud aprobada exitosamente',
      )),
    );
  }

  Future<void> _onRejectRequest(
    RejectRequestEvent event,
    Emitter<AdoptionsState> emit,
  ) async {
    emit(AdoptionsLoading());
    
    final result = await rejectRequest(
      RejectRequestParams(
        requestId: event.requestId,
        reason: event.reason,
      ),
    );
    
    result.fold(
      (failure) => emit(AdoptionsError(message: failure.message)),
      (request) => emit(AdoptionUpdated(
        request: request,
        message: 'Solicitud rechazada',
      )),
    );
  }

  Future<void> _onCancelRequest(
    CancelRequestEvent event,
    Emitter<AdoptionsState> emit,
  ) async {
    emit(AdoptionsLoading());
    
    final result = await cancelRequest(
      CancelRequestParams(requestId: event.requestId),
    );
    
    result.fold(
      (failure) => emit(AdoptionsError(message: failure.message)),
      (_) {
        // Recargar solicitudes después de cancelar
        emit(const AdoptionUpdated(
          request: null, // No tenemos el request actualizado
          message: 'Solicitud cancelada',
        ));
      },
    );
  }

  Future<void> _onRefreshAdoptions(
    RefreshAdoptionsEvent event,
    Emitter<AdoptionsState> emit,
  ) async {
    if (event.isShelter) {
      add(LoadShelterRequestsEvent(shelterId: event.userId));
    } else {
      add(LoadMyRequestsEvent(userId: event.userId));
    }
  }
}
