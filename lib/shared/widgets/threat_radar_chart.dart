import 'dart:math';
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/scam_check_result.dart';

/// 4-axis radar / spider chart showing the psychological factors.
///
/// Adapts the "Threat Vector Analysis" panel from the Stitch design.
class ThreatRadarChart extends StatelessWidget {
  const ThreatRadarChart({
    super.key,
    required this.factors,
    this.color = AppColors.riskHigh,
    this.size = 220,
  });

  final PsychologicalFactors factors;
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _RadarPainter(factors: factors, color: color),
      ),
    );
  }
}

class _RadarPainter extends CustomPainter {
  _RadarPainter({required this.factors, required this.color});

  final PsychologicalFactors factors;
  final Color color;

  static const _labels = ['Áp lực', 'Quyền lực', 'Lợi ích', 'Sợ hãi'];

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width, size.height) / 2 - 32;
    final values = [
      factors.urgency,
      factors.authority,
      factors.greed,
      factors.fear,
    ].map((v) => (v.clamp(0, 100)) / 100.0).toList();

    final axes = List.generate(4, (i) {
      final angle = -pi / 2 + (i * 2 * pi / 4);
      return Offset(cos(angle), sin(angle));
    });

    // Grid rings (4 levels).
    final gridPaint = Paint()
      ..color = AppColors.outlineVariant.withValues(alpha: 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    for (var lvl = 1; lvl <= 4; lvl++) {
      final r = radius * (lvl / 4);
      final path = Path();
      for (var i = 0; i < axes.length; i++) {
        final p = center + axes[i] * r;
        if (i == 0) {
          path.moveTo(p.dx, p.dy);
        } else {
          path.lineTo(p.dx, p.dy);
        }
      }
      path.close();
      canvas.drawPath(path, gridPaint);
    }
    // Axis spokes.
    for (final axis in axes) {
      canvas.drawLine(center, center + axis * radius, gridPaint);
    }

    // Data polygon.
    final dataPath = Path();
    for (var i = 0; i < axes.length; i++) {
      final p = center + axes[i] * (radius * values[i]);
      if (i == 0) {
        dataPath.moveTo(p.dx, p.dy);
      } else {
        dataPath.lineTo(p.dx, p.dy);
      }
    }
    dataPath.close();
    canvas.drawPath(
      dataPath,
      Paint()
        ..color = color.withValues(alpha: 0.18)
        ..style = PaintingStyle.fill,
    );
    canvas.drawPath(
      dataPath,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    // Vertex dots.
    for (var i = 0; i < axes.length; i++) {
      final p = center + axes[i] * (radius * values[i]);
      canvas.drawCircle(p, 3.5, Paint()..color = color);
    }

    // Labels.
    final tp = TextPainter(textDirection: TextDirection.ltr);
    for (var i = 0; i < axes.length; i++) {
      tp.text = TextSpan(
        text: _labels[i],
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: AppColors.textSecondary,
          letterSpacing: 0.5,
        ),
      );
      tp.layout();
      final lp = center + axes[i] * (radius + 18);
      tp.paint(
        canvas,
        Offset(lp.dx - tp.width / 2, lp.dy - tp.height / 2),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _RadarPainter old) =>
      old.factors != factors || old.color != color;
}
