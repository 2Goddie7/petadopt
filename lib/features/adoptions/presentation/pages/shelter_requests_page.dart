import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/adoptions_bloc.dart';
import '../bloc/adoptions_event.dart';
import '../bloc/adoptions_state.dart';
import '../../domain/entities/adoption_request.dart';
import '../widgets/adoption_request_card.dart';
import '../widgets/request_action_buttons.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';

class ShelterRequestsPage extends StatefulWidget {
  const ShelterRequestsPage({super.key});

  @override
  State<ShelterRequestsPage> createState() => _ShelterRequestsPageState();
}

class _ShelterRequestsPageState extends State<ShelterRequestsPage> {
  RequestStatus? _selectedFilter;

  @override
  void initState() {
    super.initState();
    _loadRequests();
  }

  void _loadRequests() {
    final authState = context.read<AuthBloc>().state;
    if (authState is Authenticated) {
      // Asumiendo que el shelterId está en user.id o user metadata
      context.read<AdoptionsBloc>().add(
            LoadShelterRequestsEvent(shelterId: authState.user.id),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Solicitudes Recibidas'),
        actions: [
          PopupMenuButton<RequestStatus?>(
            icon: const Icon(Icons.filter_list),
            onSelected: (value) {
              setState(() => _selectedFilter = value);
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: null,
                child: Text('Todas'),
              ),
              const PopupMenuItem(
                value: RequestStatus.pending,
                child: Text('Pendientes'),
              ),
              const PopupMenuItem(
                value: RequestStatus.approved,
                child: Text('Aprobadas'),
              ),
              const PopupMenuItem(
                value: RequestStatus.rejected,
                child: Text('Rechazadas'),
              ),
            ],
          ),
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
            final filteredRequests = _selectedFilter == null
                ? state.requests
                : state.requests.where((r) => r.status == _selectedFilter).toList();

            if (filteredRequests.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.inbox, size: 80, color: Colors.grey[300]),
                    const SizedBox(height: 16),
                    Text(
                      _selectedFilter == null
                          ? 'No hay solicitudes'
                          : 'No hay solicitudes con este filtro',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: Colors.grey[600],
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
                itemCount: filteredRequests.length,
                itemBuilder: (context, index) {
                  final request = filteredRequests[index];
                  return AdoptionRequestCard(
                    request: request,
                    onTap: () => _showRequestDetails(context, request),
                    trailing: RequestActionButtons(
                      request: request,
                      onApprove: () => _showApproveDialog(context, request),
                      onReject: () => _showRejectDialog(context, request),
                    ),
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
                label: 'Adoptante:',
                value: request.adopterName ?? 'N/A',
              ),
              _DetailRow(
                label: 'Email:',
                value: request.adopterEmail ?? 'N/A',
              ),
              if (request.adopterPhone != null)
                _DetailRow(
                  label: 'Teléfono:',
                  value: request.adopterPhone!,
                ),
              _DetailRow(
                label: 'Mascota:',
                value: request.petName ?? 'N/A',
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
                  'Mensaje del adoptante:',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue[100]!),
                  ),
                  child: Text(request.message!),
                ),
              ],

              if (request.status == RequestStatus.pending) ...[
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          _showApproveDialog(context, request);
                        },
                        icon: const Icon(Icons.check_circle),
                        label: const Text('Aprobar'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          _showRejectDialog(context, request);
                        },
                        icon: const Icon(Icons.cancel),
                        label: const Text('Rechazar'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _showApproveDialog(BuildContext context, AdoptionRequest request) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Aprobar Solicitud'),
        content: Text(
          '¿Confirmas que deseas aprobar la solicitud de ${request.adopterName} para adoptar a ${request.petName}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<AdoptionsBloc>().add(
                    ApproveRequestEvent(requestId: request.id),
                  );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.green),
            child: const Text('Aprobar'),
          ),
        ],
      ),
    );
  }

  void _showRejectDialog(BuildContext context, AdoptionRequest request) {
    final reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Rechazar Solicitud'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Solicitud de ${request.adopterName} para ${request.petName}',
            ),
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                labelText: 'Motivo (opcional)',
                hintText: 'Explica por qué se rechaza la solicitud...',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<AdoptionsBloc>().add(
                    RejectRequestEvent(
                      requestId: request.id,
                      reason: reasonController.text.trim(),
                    ),
                  );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Rechazar'),
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
