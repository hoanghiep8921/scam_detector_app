import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/risk_level.dart';
import '../../data/models/scam_check_result.dart';
import '../../flutter_gen/gen_l10n/app_localizations.dart';
import '../../shared/widgets/risk_gauge.dart';
import '../../shared/widgets/scanning_overlay.dart';
import '../../shared/widgets/threat_radar_chart.dart';
import '../scam_check/scam_check_provider.dart';

/// Stateful so we can swap [_result] in-place after Gemini analysis without
/// popping back to the previous screen.
class ResultScreen extends StatefulWidget {
  const ResultScreen({super.key, required this.result});

  final ScamCheckResult result;

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  late ScamCheckResult _result = widget.result;

  bool get _hasPsy {
    final p = _result.psychological;
    return p.urgency + p.fear + p.authority + p.greed > 0;
  }

  bool get _isUnknown => _result.riskLevel == RiskLevel.unknown;

  String _shareText() {
    final l = AppLocalizations.of(context)!;
    return [
        '[Scam Detector] ${_result.riskLevel.localizedLabel(context)} (${_result.riskScore}/100)',
        '${_result.target.localizedLabel(context)}: ${_result.input}',
        _result.summary,
        if (_result.reasons.isNotEmpty) ...[
          '',
          l.resultShareReasons,
          ..._result.reasons.map((r) => '• $r'),
        ],
      ].join('\n');
  }

  Future<void> _copy() async {
    await Clipboard.setData(ClipboardData(text: _shareText()));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppLocalizations.of(context)!.resultCopied)),
    );
  }

  Future<void> _runAi() async {
    final updated =
        await context.read<ScamCheckProvider>().analyzeWithAi(_result, locale: Localizations.localeOf(context).languageCode);
    if (!mounted || updated == null) return;
    setState(() => _result = updated);
  }

  Future<void> _openUrl() async {
    final raw = _result.input.trim();
    final uri = Uri.tryParse(
      raw.startsWith('http') ? raw : 'https://$raw',
    );
    if (uri == null) return;
    if (_result.riskLevel == RiskLevel.scam ||
        _result.riskLevel == RiskLevel.suspicious) {
      final l = AppLocalizations.of(context)!;
      final ok = await showDialog<bool>(
        context: context,
        builder: (_) => AlertDialog(
          title: Text(l.resultWarnDialogTitle),
          content: Text(
            l.resultWarnDialogContent(_result.riskLevel.localizedLabel(context).toLowerCase()),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(l.resultWarnCancel),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(l.resultWarnOpen),
            ),
          ],
        ),
      );
      if (ok != true) return;
    }
    if (!mounted) return;
    final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!launched && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.resultOpenFail)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final aiLoading = context.watch<ScamCheckProvider>().isAiLoading;
    final isScam = _result.riskLevel == RiskLevel.scam;
    return Scaffold(
      appBar: AppBar(
        title: Text(l.resultTitle),
        actions: [
          IconButton(
            tooltip: l.tooltipCopy,
            icon: const Icon(Icons.copy_outlined),
            onPressed: _copy,
          ),
        ],
      ),
      body: SafeArea(
        child: Stack(
          children: [
            ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              children: [
                _RiskHeader(result: _result),
                const SizedBox(height: 16),
                if (_result.input.trim().isNotEmpty) ...[
                  _TargetCard(result: _result),
                  const SizedBox(height: 16),
                ],
                _AiAnalysisCard(
                  isUnknown: _isUnknown,
                  hasPsy: _hasPsy,
                  loading: aiLoading,
                  onTap: aiLoading ? null : _runAi,
                ),
                const SizedBox(height: 16),
                if (_result.reasons.isNotEmpty) ...[
                  _SectionHeader(
                    icon: Icons.fact_check_outlined,
                    title: l.resultWarningReasons,
                  ),
                  const SizedBox(height: 8),
                  _ReasonsCard(
                    reasons: _result.reasons,
                    accent: _result.riskLevel.color,
                  ),
                  const SizedBox(height: 16),
                ],
                if (_result.target == CheckTarget.url &&
                    _result.urlHighlights.isNotEmpty) ...[
                  _UrlHighlightCard(
                    url: _result.input,
                    highlights: _result.urlHighlights,
                  ),
                  const SizedBox(height: 16),
                ],
                if (_result.linguisticSignals.isNotEmpty ||
                    _result.cyberSignals.isNotEmpty ||
                    _result.socialTactics.isNotEmpty) ...[
                  _SectionHeader(
                    icon: Icons.hub_outlined,
                    title: l.resultMultiAxis,
                  ),
                  const SizedBox(height: 8),
                  if (_result.linguisticSignals.isNotEmpty)
                    _SignalCard(
                      icon: Icons.translate,
                      title: l.axisLinguistic,
                      subtitle: l.axisLinguisticSub,
                      signals: _result.linguisticSignals,
                      accent: const Color(0xFF7B1FA2),
                    ),
                  if (_result.cyberSignals.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    _SignalCard(
                      icon: Icons.shield_moon_outlined,
                      title: l.axisCyber,
                      subtitle: l.axisCyberSub,
                      signals: _result.cyberSignals,
                      accent: const Color(0xFF00838F),
                    ),
                  ],
                  if (_result.socialTactics.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    _SignalCard(
                      icon: Icons.psychology_alt_outlined,
                      title: l.axisSocial,
                      subtitle: l.axisSocialSub,
                      signals: _result.socialTactics,
                      accent: const Color(0xFFC2185B),
                    ),
                  ],
                  const SizedBox(height: 16),
                ],
                if (_hasPsy) ...[
                  _SectionHeader(
                    icon: Icons.radar,
                    title: l.resultPsyVector,
                  ),
                  const SizedBox(height: 8),
                  _RadarCard(result: _result),
                  const SizedBox(height: 16),
                ],
                if (isScam) ...[
                  const _SecurityProtocolCallout(),
                  const SizedBox(height: 16),
                ],
                if (_result.target == CheckTarget.url) ...[
                  OutlinedButton.icon(
                    onPressed: _openUrl,
                    icon: const Icon(Icons.open_in_new),
                    label: Text(l.resultOpenLink),
                  ),
                  const SizedBox(height: 12),
                ],
                OutlinedButton.icon(
                  onPressed: () =>
                      Navigator.of(context).popUntil((r) => r.isFirst),
                  icon: const Icon(Icons.home_outlined),
                  label: Text(l.resultGoHome),
                ),
              ],
            ),
            if (aiLoading)
              Positioned.fill(
                child: ScanningOverlay(message: l.aiOverlayMsg),
              ),
          ],
        ),
      ),
    );
  }
}

class _AiAnalysisCard extends StatelessWidget {
  const _AiAnalysisCard({
    required this.isUnknown,
    required this.hasPsy,
    required this.loading,
    required this.onTap,
  });

  final bool isUnknown;
  final bool hasPsy;
  final bool loading;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final ctaLabel = hasPsy
        ? l.aiCtaRedo
        : isUnknown
            ? l.aiCtaUnknown
            : l.aiCtaKnown;
    final subtitle = isUnknown ? l.aiCardSubUnknown : l.aiCardSubKnown;

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors = AppColors.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: (isDark || !isUnknown) ? null : LinearGradient(
          colors: [colors.primary, AppColors.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        color: isDark
            ? colors.surface
            : (!isUnknown ? colors.primaryContainer : null),
        border: isDark ? Border.all(color: colors.border) : null,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.auto_awesome,
                color: isDark ? colors.primary : (isUnknown ? Colors.white : colors.primary),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  l.aiCardTitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: isDark
                            ? colors.textPrimary
                            : (isUnknown ? Colors.white : colors.onPrimaryContainer),
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: isDark
                      ? colors.textSecondary
                      : (isUnknown ? Colors.white.withValues(alpha: 0.85) : colors.textSecondary),
                  height: 1.4,
                ),
          ),
          const SizedBox(height: 14),
          ElevatedButton.icon(
            onPressed: onTap,
            style: ElevatedButton.styleFrom(
              backgroundColor: isUnknown ? Colors.white : AppColors.of(context).primary,
              foregroundColor: isUnknown ? AppColors.of(context).primary : Colors.white,
              minimumSize: const Size.fromHeight(48),
              shape: const StadiumBorder(),
              textStyle: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
            icon: loading
                ? SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: isUnknown ? AppColors.of(context).primary : Colors.white,
                    ),
                  )
                : const Icon(Icons.psychology_outlined, size: 18),
            label: Text(loading ? l.aiAnalyzing : ctaLabel),
          ),
        ],
      ),
    );
  }
}

class _RiskHeader extends StatelessWidget {
  const _RiskHeader({required this.result});
  final ScamCheckResult result;

  @override
  Widget build(BuildContext context) {
    final color = result.riskLevel.color;
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
        child: Column(
          children: [
            RiskGauge(score: result.riskScore, level: result.riskLevel),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(result.riskLevel.icon, color: Colors.white, size: 16),
                  const SizedBox(width: 6),
                  Text(
                    result.riskLevel.localizedLabel(context).toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                      letterSpacing: 1.0,
                    ),
                  ),
                ],
              ),
            ),
            if (result.summary.trim().isNotEmpty) ...[
              const SizedBox(height: 14),
              Text(
                result.summary,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _TargetCard extends StatelessWidget {
  const _TargetCard({required this.result});
  final ScamCheckResult result;

  @override
  Widget build(BuildContext context) {
    final icon = switch (result.target) {
      CheckTarget.phone => Icons.phone_outlined,
      CheckTarget.bankAccount => Icons.account_balance_outlined,
      CheckTarget.url => Icons.link,
      CheckTarget.content => Icons.text_snippet_outlined,
    };
    return Container(
      decoration: BoxDecoration(
        color: AppColors.of(context).surface,
        borderRadius: BorderRadius.circular(16),
        border: Border(
          left: BorderSide(width: 4, color: AppColors.of(context).primary),
          top: BorderSide(color: AppColors.of(context).border),
          right: BorderSide(color: AppColors.of(context).border),
          bottom: BorderSide(color: AppColors.of(context).border),
        ),
      ),
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Icon(icon, color: AppColors.of(context).primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(result.target.localizedLabel(context).toUpperCase(),
                    style: Theme.of(context).textTheme.labelSmall),
                const SizedBox(height: 2),
                Text(
                  result.input,
                  maxLines: result.target == CheckTarget.content ? 4 : 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: result.target == CheckTarget.content ? 14 : 16,
                        height: result.target == CheckTarget.content ? 1.4 : null,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.icon, required this.title});
  final IconData icon;
  final String title;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.of(context).primary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
        ],
      ),
    );
  }
}

/// Card grouping a list of textual signals from one analytical axis
/// (linguistics / cybersecurity / social psychology).
class _SignalCard extends StatelessWidget {
  const _SignalCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.signals,
    required this.accent,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final List<String> signals;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.of(context).surface,
        borderRadius: BorderRadius.circular(16),
        border: Border(
          top: BorderSide(color: AppColors.of(context).border),
          right: BorderSide(color: AppColors.of(context).border),
          bottom: BorderSide(color: AppColors.of(context).border),
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border(left: BorderSide(width: 4, color: accent)),
        ),
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: accent, size: 18),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: Theme.of(context)
                            .textTheme
                            .titleSmall
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      Text(
                        subtitle,
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ...signals.map(
              (s) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 7),
                      child: Container(
                        width: 6,
                        height: 6,
                        decoration:
                            BoxDecoration(color: accent, shape: BoxShape.circle),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        s,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReasonsCard extends StatelessWidget {
  const _ReasonsCard({required this.reasons, required this.accent});
  final List<String> reasons;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
        child: Column(
          children: reasons
              .map(
                (r) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: accent.withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.warning_amber_rounded,
                            size: 14, color: accent),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          r,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}

/// Highlights suspicious URL fragments inline with color-coded severity.
class _UrlHighlightCard extends StatelessWidget {
  const _UrlHighlightCard({
    required this.url,
    required this.highlights,
  });

  final String url;
  final Map<String, int> highlights; // fragment → severity

  @override
  Widget build(BuildContext context) {
    final spans = _buildSpans(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.warning_amber_rounded,
                    color: AppColors.riskHigh, size: 20),
                const SizedBox(width: 8),
                Text(
                  AppLocalizations.of(context)!.resultUrlWarning,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.of(context).surfaceContainerLow,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.of(context).border),
              ),
              child: Wrap(
                children: spans,
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildSpans(BuildContext context) {
    return _buildOrderedSpans(context);
  }

  List<Widget> _buildOrderedSpans(BuildContext context) {
    final lowerUrl = url.toLowerCase();
    var cursor = 0;

    // Find all highlight matches with their positions.
    final matches = <_Segment>[];
    for (final entry in highlights.entries) {
      final fragment = entry.key.toLowerCase();
      var start = 0;
      while (true) {
        final idx = lowerUrl.indexOf(fragment, start);
        if (idx == -1) break;
        matches.add(_Segment(
          start: idx,
          end: idx + fragment.length,
          text: url.substring(idx, idx + fragment.length),
          severity: entry.value,
        ));
        start = idx + fragment.length;
      }
    }

    // Merge overlapping — keep highest severity.
    final merged = _mergeOverlapping(matches);

    // Sort by position.
    merged.sort((a, b) => a.start.compareTo(b.start));

    final widgets = <Widget>[];
    for (final seg in merged) {
      // Add plain text before this segment.
      if (seg.start > cursor) {
        widgets.add(Text(
          url.substring(cursor, seg.start),
          style: TextStyle(
            fontFamily: 'monospace',
            fontSize: 14,
            color: AppColors.of(context).textPrimary,
          ),
        ));
      }
      widgets.add(_HighlightChip(
        text: seg.text,
        severity: seg.severity,
      ));
      cursor = seg.end;
    }

    // Remaining text.
    if (cursor < url.length) {
      widgets.add(Text(
        url.substring(cursor),
        style: TextStyle(
          fontFamily: 'monospace',
          fontSize: 14,
          color: AppColors.of(context).textPrimary,
        ),
      ));
    }

    return widgets;
  }

  List<_Segment> _mergeOverlapping(List<_Segment> matches) {
    if (matches.isEmpty) return [];
    final sorted = List.of(matches)..sort((a, b) => a.start.compareTo(b.start));
    final result = <_Segment>[sorted.first];
    for (var i = 1; i < sorted.length; i++) {
      final prev = result.last;
      final curr = sorted[i];
      if (curr.start < prev.end) {
        // Overlapping — merge, keep higher severity.
        result[result.length - 1] = _Segment(
          start: prev.start,
          end: curr.end > prev.end ? curr.end : prev.end,
          text: url.substring(prev.start, curr.end > prev.end ? curr.end : prev.end),
          severity: curr.severity > prev.severity ? curr.severity : prev.severity,
        );
      } else {
        result.add(curr);
      }
    }
    return result;
  }
}

class _Segment {
  const _Segment({
    required this.start,
    required this.end,
    required this.text,
    required this.severity,
  });
  final int start;
  final int end;
  final String text;
  final int severity;
}

class _HighlightChip extends StatelessWidget {
  const _HighlightChip({required this.text, required this.severity});
  final String text;
  final int severity;

  Color get _color {
    if (severity >= 70) return AppColors.riskHigh;
    if (severity >= 40) return AppColors.riskMedium;
    return AppColors.riskUnknown;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: _color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: _color.withValues(alpha: 0.5)),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontFamily: 'monospace',
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: _color,
        ),
      ),
    );
  }
}

class _RadarCard extends StatelessWidget {
  const _RadarCard({required this.result});
  final ScamCheckResult result;
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
        child: Column(
          children: [
            ThreatRadarChart(
              factors: result.psychological,
              color: result.riskLevel.color,
            ),
            const SizedBox(height: 8),
            Text(
              AppLocalizations.of(context)!.resultRadarDesc,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

class _SecurityProtocolCallout extends StatelessWidget {
  const _SecurityProtocolCallout();
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors = AppColors.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? colors.surface : AppColors.primaryDark,
        border: isDark ? Border.all(color: colors.border) : null,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(Icons.shield, color: isDark ? colors.primary : Colors.white, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.of(context)!.securityProtocolTitle,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: isDark ? colors.textPrimary : Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  AppLocalizations.of(context)!.securityProtocolBody,
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: isDark ? colors.textSecondary : Colors.white70),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
