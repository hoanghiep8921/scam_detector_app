import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

/// Full-screen modal overlay shown while Gemini is analyzing.
///
/// Visual: a Gemini-themed loading badge with three orbiting sparkles + a
/// rotating sweep gradient ring around a shield icon, on top of a slowly
/// pulsing aura. Communicates "AI đang nghĩ" rather than "scanning".
class ScanningOverlay extends StatefulWidget {
  const ScanningOverlay({super.key, this.message = 'Đang phân tích bằng AI…'});

  final String message;

  @override
  State<ScanningOverlay> createState() => _ScanningOverlayState();
}

class _ScanningOverlayState extends State<ScanningOverlay>
    with TickerProviderStateMixin {
  // Continuous rotation for the sweep ring + orbiting sparkles.
  late final AnimationController _orbit = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2800),
  )..repeat();

  // Out-and-fade pulse for the outer aura + breathing scale on the shield.
  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1800),
  )..repeat();

  @override
  void dispose() {
    _orbit.dispose();
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.black.withValues(alpha: 0.45),
      child: Center(
        child: Container(
          width: 280,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 140,
                height: 140,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Outer pulse ring — expands and fades.
                    AnimatedBuilder(
                      animation: _pulse,
                      builder: (_, _) {
                        final t = _pulse.value;
                        return Container(
                          width: 90 + t * 50,
                          height: 90 + t * 50,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.primary
                                  .withValues(alpha: (1.0 - t) * 0.35),
                              width: 2,
                            ),
                          ),
                        );
                      },
                    ),
                    // Sweeping conic-gradient ring (rotates).
                    AnimatedBuilder(
                      animation: _orbit,
                      builder: (_, _) {
                        return Transform.rotate(
                          angle: _orbit.value * 2 * math.pi,
                          child: Container(
                            width: 96,
                            height: 96,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: SweepGradient(
                                colors: [
                                  AppColors.primary.withValues(alpha: 0.0),
                                  AppColors.primary.withValues(alpha: 0.55),
                                  AppColors.primary,
                                  AppColors.primary.withValues(alpha: 0.0),
                                ],
                                stops: const [0.0, 0.4, 0.55, 1.0],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    // Inner solid disc to mask the inside of the gradient ring.
                    Container(
                      width: 88,
                      height: 88,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.surface,
                      ),
                    ),
                    // Soft tinted disc behind the shield.
                    Container(
                      width: 76,
                      height: 76,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.primary.withValues(alpha: 0.10),
                      ),
                    ),
                    // Shield with gentle scale pulse.
                    AnimatedBuilder(
                      animation: _pulse,
                      builder: (_, child) {
                        final scale = 0.92 +
                            (math.sin(_pulse.value * math.pi * 2) + 1) /
                                2 *
                                0.08;
                        return Transform.scale(scale: scale, child: child);
                      },
                      child: const Icon(
                        Icons.shield_outlined,
                        size: 44,
                        color: AppColors.primary,
                      ),
                    ),
                    // Three sparkles orbiting around the shield.
                    AnimatedBuilder(
                      animation: _orbit,
                      builder: (_, _) {
                        return SizedBox(
                          width: 140,
                          height: 140,
                          child: Stack(
                            children: List.generate(3, (i) {
                              final angle = _orbit.value * 2 * math.pi +
                                  i * (2 * math.pi / 3);
                              const radius = 58.0;
                              final dx = math.cos(angle) * radius;
                              final dy = math.sin(angle) * radius;
                              final size =
                                  i == 0 ? 18.0 : (i == 1 ? 14.0 : 11.0);
                              return Positioned(
                                left: 70 + dx - size / 2,
                                top: 70 + dy - size / 2,
                                child: Icon(
                                  Icons.auto_awesome,
                                  size: size,
                                  color: i == 0
                                      ? AppColors.primary
                                      : AppColors.primary
                                          .withValues(alpha: 0.55),
                                ),
                              );
                            }),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              Text(
                widget.message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Gemini đang phân tích đa góc nhìn — 2–5 giây.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Lightweight skeleton placeholder block.
class SkeletonBlock extends StatefulWidget {
  const SkeletonBlock({
    super.key,
    this.height = 16,
    this.width = double.infinity,
    this.radius = 6,
  });

  final double height;
  final double width;
  final double radius;

  @override
  State<SkeletonBlock> createState() => _SkeletonBlockState();
}

class _SkeletonBlockState extends State<SkeletonBlock>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, _) {
        final t = _ctrl.value;
        return Container(
          height: widget.height,
          width: widget.width,
          decoration: BoxDecoration(
            color: Color.lerp(
              const Color(0xFFE8ECF2),
              const Color(0xFFF3F5F9),
              t,
            ),
            borderRadius: BorderRadius.circular(widget.radius),
          ),
        );
      },
    );
  }
}
