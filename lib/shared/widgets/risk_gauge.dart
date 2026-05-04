import 'dart:math';
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/risk_level.dart';

/// Half-circle gauge showing risk score 0-100.
///
/// Adapts the "Risk Index" arc from the Stitch result design.
class RiskGauge extends StatelessWidget {
  const RiskGauge({super.key, required this.score, required this.level});

  final int score;
  final RiskLevel level;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 220,
      height: 130,
      child: CustomPaint(
        painter: _GaugePainter(score: score, color: level.color),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.only(top: 30),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '$score',
                  style: const TextStyle(
                    fontSize: 56,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                    height: 1,
                  ),
                ),
                const Text(
                  'ĐIỂM RỦI RO',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.2,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _GaugePainter extends CustomPainter {
  _GaugePainter({required this.score, required this.color});

  final int score;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(10, 10, size.width - 20, size.width - 20);
    const start = pi; // 180°
    const sweep = pi; // 180°
    final progress = (score.clamp(0, 100)) / 100.0;

    // Track.
    canvas.drawArc(
      rect,
      start,
      sweep,
      false,
      Paint()
        ..color = AppColors.surfaceContainer
        ..style = PaintingStyle.stroke
        ..strokeWidth = 14
        ..strokeCap = StrokeCap.round,
    );

    // Progress arc.
    canvas.drawArc(
      rect,
      start,
      sweep * progress,
      false,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 14
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(covariant _GaugePainter old) =>
      old.score != score || old.color != color;
}
