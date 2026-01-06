import 'package:flutter/material.dart';
import '../../domain/entities/adoption_request.dart';

class RequestActionButtons extends StatelessWidget {
  final AdoptionRequest request;
  final VoidCallback onApprove;
  final VoidCallback onReject;

  const RequestActionButtons({
    super.key,
    required this.request,
    required this.onApprove,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    if (request.status != RequestStatus.pending) {
      return const SizedBox();
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: const Icon(Icons.check_circle, color: Colors.green),
          onPressed: onApprove,
          tooltip: 'Aprobar',
        ),
        IconButton(
          icon: const Icon(Icons.cancel, color: Colors.red),
          onPressed: onReject,
          tooltip: 'Rechazar',
        ),
      ],
    );
  }
}
