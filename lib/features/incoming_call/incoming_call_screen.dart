import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/risk_level.dart';
import '../../data/models/scam_check_result.dart';
import '../../flutter_gen/gen_l10n/app_localizations.dart';
import '../../services/call_screening_service.dart';

/// Full-screen warning overlay shown when a scam call is detected.
///
/// Layout adapted from the Stitch "Incoming Call Overlay - Modern v2" design.
/// Triggered either:
///   - From CallScreening preview (demo button), or
///   - When the native CallScreeningService deep-links into the app via the
///     notification tap (future work).
class IncomingCallScreen extends StatelessWidget {
  const IncomingCallScreen({
    super.key,
    required this.phoneNumber,
    required this.result,
  });

  final String phoneNumber;
  final ScamCheckResult result;

  @override
  Widget build(BuildContext context) {
    final isScam = result.riskLevel == RiskLevel.scam;
    final accent =
        isScam ? AppColors.riskHigh : AppColors.riskMedium;
    return Scaffold(
      backgroundColor: accent,
      body: SafeArea(
        child: Column(
          children: [
            // Red header.
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
              child: Column(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.18),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.shield, color: Colors.white),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    AppLocalizations.of(context)!.incomingSecurityWarning,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isScam
                        ? AppLocalizations.of(context)!.incomingScamDetected
                        : AppLocalizations.of(context)!.incomingSuspiciousDetected,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Colors.white.withValues(alpha: 0.85),
                          letterSpacing: 1.5,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ],
              ),
            ),

            // White panel.
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.of(context).surface,
                  borderRadius:
                      BorderRadius.vertical(top: Radius.circular(28)),
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        AppLocalizations.of(context)!.incomingCallLabel,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: accent,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.2,
                            ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Text(
                              phoneNumber,
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.w700,
                                color: AppColors.of(context).textPrimary,
                              ),
                            ),
                          ),
                          IconButton.filledTonal(
                            tooltip: AppLocalizations.of(context)!.incomingCopyTooltip,
                            onPressed: () async {
                              await Clipboard.setData(
                                  ClipboardData(text: phoneNumber));
                              if (!context.mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(AppLocalizations.of(context)!.incomingCopied)),
                              );
                            },
                            icon: const Icon(Icons.copy_outlined),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      _ConfidenceCard(
                        score: result.riskScore,
                        accent: accent,
                      ),
                      const SizedBox(height: 22),
                      Text(
                        AppLocalizations.of(context)!.incomingRiskAnalysis,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: AppColors.of(context).textTertiary,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.2,
                            ),
                      ),
                      const SizedBox(height: 8),
                      ...result.reasons.take(3).map(
                            (r) => Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: accent.withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(Icons.report_gmailerrorred_outlined,
                                      color: accent, size: 18),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      r,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      const SizedBox(height: 24),
                      _PrimaryActionButton(
                        accent: accent,
                        label: isScam
                            ? AppLocalizations.of(context)!.incomingBlockBtn
                            : AppLocalizations.of(context)!.incomingWarnBtn,
                        icon: Icons.block,
                        onPressed: () async {
                          final l = AppLocalizations.of(context)!;
                          final messenger = ScaffoldMessenger.of(context);
                          final navigator = Navigator.of(context);
                          await CallScreeningService().addToBlocklist(
                            number: phoneNumber,
                            level: RiskLevel.scam,
                          );
                          navigator.pop(true);
                          messenger.showSnackBar(
                            SnackBar(
                              content: Text(l.incomingBlockedSnack(phoneNumber)),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 12),
                      TextButton(
                        onPressed: () async {
                          final l = AppLocalizations.of(context)!;
                          final messenger = ScaffoldMessenger.of(context);
                          final navigator = Navigator.of(context);
                          final removed = await CallScreeningService()
                              .removeFromBlocklist(phoneNumber);
                          navigator.pop(false);
                          messenger.showSnackBar(
                            SnackBar(
                              content: Text(
                                removed
                                    ? l.incomingRemovedSnack(phoneNumber)
                                    : l.incomingNotInListSnack(phoneNumber),
                              ),
                            ),
                          );
                        },
                        child: Text(AppLocalizations.of(context)!.incomingTrustBtn),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.shield_outlined,
                              size: 14, color: AppColors.of(context).textTertiary),
                          const SizedBox(width: 6),
                          Text(
                            AppLocalizations.of(context)!.incomingProtectedBy,
                            style: Theme.of(context)
                                .textTheme
                                .labelSmall
                                ?.copyWith(color: AppColors.of(context).textTertiary),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ConfidenceCard extends StatelessWidget {
  const _ConfidenceCard({required this.score, required this.accent});
  final int score;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final pct = (score.clamp(0, 100)) / 100.0;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.of(context).surfaceContainerLow,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.of(context).border),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.of(context).primaryContainer,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.auto_awesome,
                    color: AppColors.of(context).primary, size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Gemini Shield',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context)
                      .textTheme
                      .titleSmall
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
              const SizedBox(width: 8),
              Text('$score%',
                  style: TextStyle(
                    color: accent,
                    fontWeight: FontWeight.w800,
                    fontSize: 18,
                  )),
              const SizedBox(width: 4),
              Text(
                AppLocalizations.of(context)!.incomingConfidence,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: AppColors.of(context).textTertiary,
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: pct,
              minHeight: 6,
              backgroundColor: accent.withValues(alpha: 0.15),
              valueColor: AlwaysStoppedAnimation<Color>(accent),
            ),
          ),
        ],
      ),
    );
  }
}

class _PrimaryActionButton extends StatelessWidget {
  const _PrimaryActionButton({
    required this.accent,
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  final Color accent;
  final String label;
  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: accent,
        foregroundColor: Colors.white,
        minimumSize: const Size.fromHeight(56),
        shape: const StadiumBorder(),
        textStyle: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.8,
        ),
      ),
      onPressed: onPressed,
      icon: Icon(icon),
      label: Text(label),
    );
  }
}
