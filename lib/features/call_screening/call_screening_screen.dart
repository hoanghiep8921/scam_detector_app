import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/risk_level.dart';
import 'package:provider/provider.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import '../../core/constants/api_config.dart';
import '../../flutter_gen/gen_l10n/app_localizations.dart';
import '../../services/call_screening_service.dart';
import '../../services/data_reset_service.dart';
import '../../services/local_risk_service.dart';
import '../blocklist/blocklist_screen.dart';
import '../known_risks/known_risks_screen.dart';
import '../scam_check/scam_check_provider.dart';
import 'call_screening_role_provider.dart';

class CallScreeningScreen extends StatefulWidget {
  const CallScreeningScreen({super.key});

  @override
  State<CallScreeningScreen> createState() => _CallScreeningScreenState();
}

class _CallScreeningScreenState extends State<CallScreeningScreen>
    with WidgetsBindingObserver {
  final _service = CallScreeningService();
  final _localRisk = LocalRiskService();

  bool _loading = true;
  int _scamCount = 0;
  int _suspiciousCount = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _refresh();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // User may have toggled the role from system settings — re-sync.
      context.read<CallScreeningRoleProvider>().refresh();
      _refresh();
    }
  }

  Future<void> _refresh() async {
    setState(() => _loading = true);
    // Sync the shared role provider so the home hero stays consistent.
    await context.read<CallScreeningRoleProvider>().refresh();
    // Read counters straight from the native blocklist so the displayed
    // numbers reflect what CallScreening actually matches against — not what
    // the Supabase cache might re-fetch on demand.
    final native = await _service.getNativeBlocklist();
    if (!mounted) return;
    setState(() {
      _loading = false;
      _scamCount = native.scam.length;
      _suspiciousCount = native.suspicious.length;
    });
  }

  Future<void> _enable() async {
    setState(() => _loading = true);
    final roleProvider = context.read<CallScreeningRoleProvider>();
    final scam = await _localRisk.phoneNumbersAt(RiskLevel.scam);
    final suspicious = await _localRisk.phoneNumbersAt(RiskLevel.suspicious);
    await _service.syncBlocklist(scam: scam, suspicious: suspicious);
    final granted = await _service.requestRole();
    if (!mounted) return;
    roleProvider.setRoleHeld(granted);
    if (granted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.callScreenEnabledSnack)),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.callScreenPermissionSnack)),
      );
    }
    await _refresh();
  }

  Future<void> _testSentry() async {
    final messenger = ScaffoldMessenger.of(context);
    final snackText = AppLocalizations.of(context)!.sentrySnack;
    await Sentry.captureMessage(
      'Manual test from Bảo Vệ tab',
      level: SentryLevel.info,
    );
    try {
      throw StateError('ScamGuard test exception ${DateTime.now()}');
    } catch (e, stack) {
      await Sentry.captureException(e, stackTrace: stack);
    }
    messenger.showSnackBar(
      SnackBar(content: Text(snackText)),
    );
  }

  Future<void> _confirmReset() async {
    var alsoRemote = true;
    final l = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setLocal) => AlertDialog(
          title: Text(l.resetDialogTitle),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l.resetDialogBody),
              const SizedBox(height: 12),
              CheckboxListTile(
                value: alsoRemote,
                onChanged: (v) => setLocal(() => alsoRemote = v ?? true),
                contentPadding: EdgeInsets.zero,
                controlAffinity: ListTileControlAffinity.leading,
                title: Text(l.resetDialogRemoteCheck),
                subtitle: Text(l.resetDialogRemoteCheckSub),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(l.cancel),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(l.resetBtn, style: const TextStyle(color: Colors.red)),
            ),
          ],
        ),
      ),
    );
    if (confirmed != true || !mounted) return;
    setState(() => _loading = true);
    await DataResetService().resetAll(includeRemote: alsoRemote);
    if (!mounted) return;
    await context.read<ScamCheckProvider>().loadHistory();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppLocalizations.of(context)!.resetDoneSnack)),
    );
    await _refresh();
  }

  Future<void> _resync() async {
    setState(() => _loading = true);
    final fetched = await _localRisk.refresh();
    final scam = await _localRisk.phoneNumbersAt(RiskLevel.scam);
    final suspicious = await _localRisk.phoneNumbersAt(RiskLevel.suspicious);
    await _service.syncBlocklist(scam: scam, suspicious: suspicious);
    if (!mounted) return;
    final l = AppLocalizations.of(context)!;
    final msg = fetched == null
        ? l.callScreenResyncFail(
            _localRisk.lastRefreshError ?? l.callScreenNoServer,
            scam.length,
            suspicious.length,
          )
        : l.callScreenResyncSnack(fetched, scam.length, suspicious.length);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), duration: const Duration(seconds: 6)),
    );
    await _refresh();
  }

  @override
  Widget build(BuildContext context) {
    final supported = Platform.isAndroid;
    final roleHeld = context.watch<CallScreeningRoleProvider>().roleHeld;
    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.callScreenTitle)),
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _StatusCard(roleHeld: roleHeld, supported: supported),
                  const SizedBox(height: 16),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppLocalizations.of(context)!.callScreenOfflineList,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 12),
                          _CountRow(
                            icon: Icons.dangerous_outlined,
                            color: AppColors.riskHigh,
                            label: AppLocalizations.of(context)!.callScreenScamCount,
                            count: _scamCount,
                          ),
                          const SizedBox(height: 8),
                          _CountRow(
                            icon: Icons.warning_amber_rounded,
                            color: AppColors.riskMedium,
                            label: AppLocalizations.of(context)!.callScreenSuspiciousCount,
                            count: _suspiciousCount,
                          ),
                          const SizedBox(height: 12),
                          OutlinedButton.icon(
                            onPressed: supported ? _resync : null,
                            icon: const Icon(Icons.refresh),
                            label: Text(AppLocalizations.of(context)!.callScreenResync),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (!roleHeld)
                    ElevatedButton.icon(
                      onPressed: supported ? _enable : null,
                      icon: const Icon(Icons.shield_outlined),
                      label: Text(AppLocalizations.of(context)!.callScreenEnableBtn),
                    ),
                  const SizedBox(height: 16),
                  _NavTile(
                    icon: Icons.format_list_bulleted,
                    accent: AppColors.riskHigh,
                    title: AppLocalizations.of(context)!.navTileBlocklist,
                    subtitle: AppLocalizations.of(context)!.navTileBlocklistSub,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const BlocklistScreen(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  _NavTile(
                    icon: Icons.cloud_outlined,
                    accent: AppColors.of(context).primary,
                    title: AppLocalizations.of(context)!.navTileKnownRisks,
                    subtitle: AppLocalizations.of(context)!.navTileKnownRisksSub,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const KnownRisksScreen(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  _NavTile(
                    icon: Icons.restart_alt,
                    accent: AppColors.riskHigh,
                    title: AppLocalizations.of(context)!.navTileReset,
                    subtitle: AppLocalizations.of(context)!.navTileResetSub,
                    onTap: _confirmReset,
                  ),
                  if (ApiConfig.hasSentry) ...[
                    const SizedBox(height: 10),
                    _NavTile(
                      icon: Icons.bug_report_outlined,
                      accent: AppColors.riskMedium,
                      title: AppLocalizations.of(context)!.navTileSentry,
                      subtitle: AppLocalizations.of(context)!.navTileSentrySub,
                      onTap: _testSentry,
                    ),
                  ],
                  const SizedBox(height: 24),
                  const _Notes(),
                ],
              ),
      ),
    );
  }
}

class _StatusCard extends StatelessWidget {
  const _StatusCard({required this.roleHeld, required this.supported});
  final bool roleHeld;
  final bool supported;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final (color, icon, title, body) = !supported
        ? (
            AppColors.riskUnknown,
            Icons.info_outline,
            l.callStatusAndroidOnly,
            l.callStatusAndroidOnlyBody,
          )
        : roleHeld
            ? (
                AppColors.riskSafe,
                Icons.check_circle_outline,
                l.callStatusActive,
                l.callStatusActiveBody,
              )
            : (
                AppColors.riskMedium,
                Icons.notifications_off_outlined,
                l.callStatusInactive,
                l.callStatusInactiveBody,
              );

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: color,
                    )),
                const SizedBox(height: 4),
                Text(body, style: const TextStyle(fontSize: 13, height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CountRow extends StatelessWidget {
  const _CountRow({
    required this.icon,
    required this.color,
    required this.label,
    required this.count,
  });

  final IconData icon;
  final Color color;
  final String label;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 8),
        Expanded(child: Text(label)),
        Text('$count',
            style: TextStyle(fontWeight: FontWeight.w700, color: color)),
      ],
    );
  }
}

class _NavTile extends StatelessWidget {
  const _NavTile({
    required this.icon,
    required this.accent,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final Color accent;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.of(context).surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.of(context).border),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: accent),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: AppColors.of(context).textTertiary),
            ],
          ),
        ),
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
              AppLocalizations.of(context)!.callScreenNote,
              style: const TextStyle(fontSize: 13, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}
