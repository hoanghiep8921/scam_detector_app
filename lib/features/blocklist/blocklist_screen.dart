import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/risk_level.dart';
import '../../flutter_gen/gen_l10n/app_localizations.dart';
import '../../services/call_screening_service.dart';
import '../../services/local_risk_service.dart';

/// Read-only browser of the phone numbers currently synced into the native
/// CallScreeningService blocklist (lives in SharedPreferences keyed by
/// `scam_detector_prefs.scam_numbers` / `suspicious_numbers`). Mirrors what
/// the OS will actually match against incoming calls right now.
class BlocklistScreen extends StatefulWidget {
  const BlocklistScreen({super.key});

  @override
  State<BlocklistScreen> createState() => _BlocklistScreenState();
}

class _BlocklistScreenState extends State<BlocklistScreen> {
  final _service = CallScreeningService();
  final _localRisk = LocalRiskService();

  bool _loading = true;
  Set<String> _scam = {};
  Set<String> _suspicious = {};

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    // Single source of truth: the native CallScreening blocklist
    // (SharedPreferences `scam_detector_prefs.scam_numbers` /
    // `suspicious_numbers`). Read via MethodChannel so Reset and Đồng bộ
    // changes are reflected immediately.
    final native = await _service.getNativeBlocklist();
    if (!mounted) return;
    setState(() {
      _scam = native.scam;
      _suspicious = native.suspicious;
      _loading = false;
    });
  }

  Future<void> _resync() async {
    setState(() => _loading = true);
    await _localRisk.refresh();
    final scam = await _localRisk.phoneNumbersAt(RiskLevel.scam);
    final suspicious = await _localRisk.phoneNumbersAt(RiskLevel.suspicious);
    await _service.syncBlocklist(scam: scam, suspicious: suspicious);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          AppLocalizations.of(context)!.blocklistResyncSnack(scam.length, suspicious.length),
        ),
      ),
    );
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.blocklistTitle),
        actions: [
          IconButton(
            tooltip: AppLocalizations.of(context)!.tooltipResync,
            icon: const Icon(Icons.refresh),
            onPressed: _loading ? null : _resync,
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _SummaryCard(
                  scam: _scam.length,
                  suspicious: _suspicious.length,
                ),
                const SizedBox(height: 16),
                if (_scam.isEmpty && _suspicious.isEmpty)
                  const _EmptyState()
                else ...[
                  _Section(
                    title: AppLocalizations.of(context)!.blocklistSectionScam,
                    icon: Icons.dangerous_outlined,
                    color: AppColors.riskHigh,
                    numbers: _scam.toList()..sort(),
                  ),
                  const SizedBox(height: 16),
                  _Section(
                    title: AppLocalizations.of(context)!.blocklistSectionSuspicious,
                    icon: Icons.warning_amber_rounded,
                    color: AppColors.riskMedium,
                    numbers: _suspicious.toList()..sort(),
                  ),
                ],
                const SizedBox(height: 24),
                const _Notes(),
              ],
            ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.scam, required this.suspicious});
  final int scam;
  final int suspicious;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors = AppColors.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: isDark ? null : LinearGradient(
          colors: [colors.primary, AppColors.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        color: isDark ? colors.surface : null,
        border: isDark ? Border.all(color: colors.border) : null,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: isDark ? colors.primary.withValues(alpha: 0.15) : Colors.white.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.shield, color: isDark ? colors.primary : Colors.white),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.of(context)!.blocklistSummary(scam + suspicious),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: isDark ? colors.textPrimary : Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  AppLocalizations.of(context)!.blocklistSummarySub(scam, suspicious),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: isDark ? colors.textSecondary : Colors.white70,
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

class _Section extends StatelessWidget {
  const _Section({
    required this.title,
    required this.icon,
    required this.color,
    required this.numbers,
  });

  final String title;
  final IconData icon;
  final Color color;
  final List<String> numbers;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    '${numbers.length}',
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (numbers.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text(
                  AppLocalizations.of(context)!.blocklistSectionEmpty,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              )
            else
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  for (final n in numbers)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: color.withValues(alpha: 0.25),
                        ),
                      ),
                      child: Text(
                        n,
                        style: TextStyle(
                          color: color,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.of(context).surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.of(context).border),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: AppColors.of(context).textTertiary),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              AppLocalizations.of(context)!.blocklistEmpty,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }
}

class _Notes extends StatelessWidget {
  const _Notes();
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.amber.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.amber.withValues(alpha: 0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline, color: Colors.orange, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              AppLocalizations.of(context)!.blocklistNote,
              style: const TextStyle(fontSize: 13, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}
