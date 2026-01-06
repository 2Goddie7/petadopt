import 'package:flutter/material.dart';
import '../../domain/entities/adoption_request.dart';

class RequestStatusBadge extends StatelessWidget {
  final RequestStatus status;

  const RequestStatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final config = _getStatusConfig();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: config.color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: config.color, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(config.icon, size: 14, color: config.color),
          const SizedBox(width: 4),
          Text(
            config.label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: config.color,
            ),
          ),
        ],
      ),
    );
  }

  _StatusConfig _getStatusConfig() {
    switch (status) {
      case RequestStatus.pending:
        return _StatusConfig(
          label: 'Pendiente',
          color: Colors.orange,
          icon: Icons.hourglass_empty,
        );
      case RequestStatus.approved:
        return _StatusConfig(
          label: 'Aprobada',
          color: Colors.green,
          icon: Icons.check_circle,
        );
      case RequestStatus.rejected:
        return _StatusConfig(
          label: 'Rechazada',
          color: Colors.red,
          icon: Icons.cancel,
        );
    }
  }
}

class _StatusConfig {
  final String label;
  final Color color;
  final IconData icon;

  _StatusConfig({
    required this.label,
    required this.color,
    required this.icon,
  });
}
