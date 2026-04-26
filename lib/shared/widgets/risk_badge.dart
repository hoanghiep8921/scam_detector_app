import 'package:flutter/material.dart';
import '../../data/models/risk_level.dart';

/// Pill-shaped badge showing the risk level with icon + label.
class RiskBadge extends StatelessWidget {
  const RiskBadge({super.key, required this.level, this.score});

  final RiskLevel level;
  final int? score;

  @override
  Widget build(BuildContext context) {
    final color = level.color;
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
            score != null ? '${level.label} • $score' : level.label,
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

/// Horizontal bar showing a 0-100 factor (urgency, fear, ...).
class FactorBar extends StatelessWidget {
  const FactorBar({
    super.key,
    required this.label,
    required this.value,
  });

  final String label;
  final int value; // 0-100

  @override
  Widget build(BuildContext context) {
    final pct = (value.clamp(0, 100)) / 100.0;
    final color = value >= 70
        ? Colors.red
        : value >= 40
            ? Colors.orange
            : Colors.green;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
              Text('$value%',
                  style: TextStyle(color: color, fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: pct,
              minHeight: 8,
              backgroundColor: color.withValues(alpha: 0.15),
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ],
      ),
    );
  }
}
