import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/adoptions_bloc.dart';
import '../bloc/adoptions_event.dart';
import '../bloc/adoptions_state.dart';
import '../../domain/entities/adoption_request.dart';
import '../widgets/adoption_request_card.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';

class MyRequestsPage extends StatefulWidget {
  const MyRequestsPage({super.key});

  @override
  State<MyRequestsPage> createState() => _MyRequestsPageState();
}

class _MyRequestsPageState extends State<MyRequestsPage> {
  @override
  void initState() {
    super.initState();
    _loadRequests();
  }

  void _loadRequests() {
    final authState = context.read<AuthBloc>().state;
    if (authState is Authenticated) {
      context.read<AdoptionsBloc>().add(
            LoadMyRequestsEvent(userId: authState.user.id),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Solicitudes'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadRequests,
          ),
        ],
      ),
      body: BlocConsumer<AdoptionsBloc, AdoptionsState>(
        listener: (context, state) {
          if (state is AdoptionsError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
          
          if (state is AdoptionUpdated) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
            _loadRequests(); // Recargar después de actualización
          }
        },
        builder: (context, state) {
          if (state is AdoptionsLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is AdoptionsLoaded) {
            if (state.requests.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.inbox, size: 80, color: Colors.grey[300]),
                    const SizedBox(height: 16),
                    Text(
                      'No tienes solicitudes',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: Colors.grey[600],
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Explora las mascotas disponibles',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[500],
                          ),
                    ),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () async => _loadRequests(),
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: state.requests.length,
                itemBuilder: (context, index) {
                  final request = state.requests[index];
                  return AdoptionRequestCard(
                    request: request,
                    onTap: () => _showRequestDetails(context, request),
                    trailing: request.status == RequestStatus.pending
                        ? IconButton(
                            icon: const Icon(Icons.cancel_outlined),
                            onPressed: () => _showCancelDialog(context, request),
                            tooltip: 'Cancelar solicitud',
                          )
                        : null,
                  );
                },
              ),
            );
          }

          return const SizedBox();
        },
      ),
    );
  }

  void _showRequestDetails(BuildContext context, AdoptionRequest request) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        expand: false,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              
              Text(
                'Detalles de Solicitud',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 16),
              
              _DetailRow(
                label: 'Mascota:',
                value: request.petName ?? 'N/A',
              ),
              _DetailRow(
                label: 'Refugio:',
                value: request.shelterName ?? 'N/A',
              ),
              _DetailRow(
                label: 'Estado:',
                value: _getStatusText(request.status),
              ),
              _DetailRow(
                label: 'Fecha:',
                value: _formatFullDate(request.createdAt),
              ),
              
              if (request.message != null && request.message!.isNotEmpty) ...[
                const SizedBox(height: 16),
                Text(
                  'Tu mensaje:',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                Text(request.message!),
              ],
              
              if (request.rejectionReason != null && request.rejectionReason!.isNotEmpty) ...[
                const SizedBox(height: 16),
                Text(
                  'Motivo de rechazo:',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  request.rejectionReason!,
                  style: TextStyle(color: Colors.red[700]),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _showCancelDialog(BuildContext context, AdoptionRequest request) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Cancelar Solicitud'),
        content: Text(
          '¿Estás seguro de que deseas cancelar la solicitud de adopción de ${request.petName}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<AdoptionsBloc>().add(
                    CancelRequestEvent(requestId: request.id),
                  );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Sí, cancelar'),
          ),
        ],
      ),
    );
  }

  String _getStatusText(RequestStatus status) {
    switch (status) {
      case RequestStatus.pending:
        return 'Pendiente';
      case RequestStatus.approved:
        return 'Aprobada';
      case RequestStatus.rejected:
        return 'Rechazada';
    }
  }

  String _formatFullDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[700],
                  ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}
