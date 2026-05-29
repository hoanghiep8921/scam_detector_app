import 'dart:math';
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/risk_level.dart';
import '../../flutter_gen/gen_l10n/app_localizations.dart';

/// Half-circle gauge showing risk score 0-100.
///
/// Adapts the "Risk Index" arc from the Stitch result design.
class RiskGauge extends StatelessWidget {
  const RiskGauge({super.key, required this.score, required this.level});

  final int score;
  final RiskLevel level;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return SizedBox(
      width: 220,
      height: 130,
      child: CustomPaint(
        painter: _GaugePainter(score: score, color: level.color, trackColor: colors.surfaceContainer),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.only(top: 30),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '$score',
                  style: TextStyle(
                    fontSize: 56,
                    fontWeight: FontWeight.w800,
                    color: colors.textPrimary,
                    height: 1,
                  ),
                ),
                Text(
                  AppLocalizations.of(context)!.riskScoreLabel,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.2,
                    color: colors.textSecondary,
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
  _GaugePainter({required this.score, required this.color, required this.trackColor});

  final int score;
  final Color color;
  final Color trackColor;

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
        ..color = trackColor
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
      old.score != score || old.color != color || old.trackColor != trackColor;
}
