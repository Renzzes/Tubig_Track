import 'package:flutter/material.dart';

import '../../../../core/services/backup_health_service.dart';

class BackupHealthBadge extends StatelessWidget {
  final BackupHealthInfo health;
  final bool compact;

  const BackupHealthBadge({
    super.key,
    required this.health,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final stars = '★' * health.stars + '☆' * (5 - health.stars);
    final color = switch (health.tier) {
      BackupHealthTier.excellent => Colors.green.shade700,
      BackupHealthTier.migratable => Colors.blue.shade700,
      BackupHealthTier.legacy => Colors.orange.shade800,
      BackupHealthTier.readOnlyOnly => Colors.amber.shade900,
      BackupHealthTier.damaged => Colors.red.shade700,
    };

    if (compact) {
      return Text(
        stars,
        style: TextStyle(fontSize: 11, color: color, letterSpacing: -1),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(stars, style: TextStyle(fontSize: 12, color: color)),
        Text(
          health.label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
        Text(
          health.subtitle,
          style: TextStyle(fontSize: 10, color: Colors.grey[600]),
          textAlign: TextAlign.right,
        ),
      ],
    );
  }
}
