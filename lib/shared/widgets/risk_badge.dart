import 'package:flutter/material.dart';
import '../../data/models/risk_level.dart';

export 'factor_bar.dart';

/// Pill-shaped badge showing the risk level with icon + label.
class RiskBadge extends StatelessWidget {
  const RiskBadge({super.key, required this.level, this.score});

  final RiskLevel level;
  final int? score;

  @override
  Widget build(BuildContext context) {
    final color = level.color;
    final label = level.localizedLabel(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(level.icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            score != null ? '$label • $score' : label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

