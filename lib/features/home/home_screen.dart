import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/risk_level.dart';
import '../../data/models/scam_check_result.dart';
import '../../flutter_gen/gen_l10n/app_localizations.dart';
import '../../services/call_screening_service.dart';
import '../../services/local_risk_service.dart';
import '../call_screening/call_screening_role_provider.dart';
import '../content_analysis/content_analysis_screen.dart';
import '../notifications/notifications_screen.dart';
import '../result/result_screen.dart';
import '../scam_check/scam_check_provider.dart';
import '../scam_check/scam_check_screen.dart';
import '../settings/settings_screen.dart';

/// Home dashboard — adapted from the Stitch "Home Dashboard - Modern v2"
/// design. Sections (top → bottom):
///   1. Top bar: app name + notification bell.
///   2. "Real-Time Protection" hero card with status badge.
///   3. 3-up stats row computed from history.
///   4. "Trung tâm điều khiển" — 3 quick check tiles.
///   5. "Hoạt động gần đây" — last 3 history items.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final history = context.watch<ScamCheckProvider>().historyItems;
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 16,
        title: Text(l.appName),
        actions: const [
          _NotificationsBell(),
          _SettingsButton(),
          SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            const _ProtectionHero(),
            const SizedBox(height: 16),
            _StatsRow(history: history),
            const SizedBox(height: 24),
            _SectionTitle(l.homeControlCenter),
            const SizedBox(height: 12),
            _CheckTile(
              icon: Icons.phone_outlined,
              title: l.homeCheckPhone,
              subtitle: l.homeCheckPhoneSub,
              accent: AppColors.of(context).primary,
              target: CheckTarget.phone,
            ),
            const SizedBox(height: 10),
            _CheckTile(
              icon: Icons.account_balance_outlined,
              title: l.homeCheckBank,
              subtitle: l.homeCheckBankSub,
              accent: AppColors.secondary,
              target: CheckTarget.bankAccount,
            ),
            const SizedBox(height: 10),
            _CheckTile(
              icon: Icons.link,
              title: l.homeCheckUrl,
              subtitle: l.homeCheckUrlSub,
              accent: AppColors.riskMedium,
              target: CheckTarget.url,
            ),
            const SizedBox(height: 10),
            const _ContentAnalysisTile(),
            const SizedBox(height: 24),
            _SectionTitle(l.homeRecentActivity),
            const SizedBox(height: 8),
            _RecentActivity(items: history.take(3).toList()),
          ],
        ),
      ),
    );
  }
}

/// Bell icon in the home app bar that mirrors the in-app notification inbox.
/// Shows a red badge with the count of native-screened call events the user
/// hasn't viewed yet (newer than the last time they opened NotificationsScreen).
class _NotificationsBell extends StatefulWidget {
  const _NotificationsBell();

  @override
  State<_NotificationsBell> createState() => _NotificationsBellState();
}

class _NotificationsBellState extends State<_NotificationsBell> {
  DateTime? _lastSeenAt;

  @override
  void initState() {
    super.initState();
    _loadLastSeen();
  }

  Future<void> _loadLastSeen() async {
    final v = await NotificationsScreen.readLastSeenAt();
    if (!mounted) return;
    setState(() => _lastSeenAt = v);
  }

  Future<void> _open() async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const NotificationsScreen()),
    );
    // Refresh the last-seen timestamp the screen just persisted.
    await _loadLastSeen();
  }

  @override
  Widget build(BuildContext context) {
    final history = context.watch<ScamCheckProvider>().historyItems;
    final unread = history.where((e) {
      if (!e.id.startsWith('native-')) return false;
      if (_lastSeenAt == null) return true;
      return e.checkedAt.isAfter(_lastSeenAt!);
    }).length;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        IconButton(
          icon: Icon(Icons.notifications_outlined,
              color: AppColors.of(context).textSecondary),
          onPressed: _open,
          tooltip: AppLocalizations.of(context)!.tooltipNotifications,
        ),
        if (unread > 0)
          Positioned(
            top: 6,
            right: 6,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
              constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
              decoration: BoxDecoration(
                color: AppColors.riskHigh,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: AppColors.of(context).surface, width: 1.5),
              ),
              child: Text(
                unread > 99 ? '99+' : '$unread',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  height: 1.1,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// Settings gear icon next to the notification bell.
class _SettingsButton extends StatelessWidget {
  const _SettingsButton();

  void _open(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const SettingsScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.settings_outlined, color: AppColors.of(context).textSecondary),
      onPressed: () => _open(context),
      tooltip: AppLocalizations.of(context)!.tooltipSettings,
    );
  }
}

/// Hero card that mirrors the call-screening role state. The same toggle is
/// also exposed in the "Bảo vệ" tab — both surfaces read [CallScreeningService.isRoleHeld]
/// so they stay in sync. Refreshes on lifecycle resume to catch the moment the
/// user returns from the system role dialog or the OS settings page.
class _ProtectionHero extends StatefulWidget {
  const _ProtectionHero();

  @override
  State<_ProtectionHero> createState() => _ProtectionHeroState();
}

class _ProtectionHeroState extends State<_ProtectionHero>
    with WidgetsBindingObserver {
  final _service = CallScreeningService();
  final _localRisk = LocalRiskService();
  bool _enabling = false;

  bool get _supported => _service.isSupportedPlatform;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      context.read<CallScreeningRoleProvider>().refresh();
    }
  }

  Future<void> _enable() async {
    if (_enabling) return;
    setState(() => _enabling = true);
    final roleProvider = context.read<CallScreeningRoleProvider>();
    final scam = await _localRisk.phoneNumbersAt(RiskLevel.scam);
    final suspicious = await _localRisk.phoneNumbersAt(RiskLevel.suspicious);
    await _service.syncBlocklist(scam: scam, suspicious: suspicious);
    final granted = await _service.requestRole();
    if (!mounted) return;
    setState(() => _enabling = false);
    roleProvider.setRoleHeld(granted);
    if (granted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.heroEnabledSnack)),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.heroPermissionSnack),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<CallScreeningRoleProvider>();
    final loading = state.loading;
    final roleHeld = state.roleHeld;
    final l = AppLocalizations.of(context)!;
    final subtitle = !_supported
        ? l.heroSubtitleIos
        : roleHeld
            ? l.heroSubtitleActive
            : l.heroSubtitleInactive;

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors = AppColors.of(context);
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 22),
      decoration: BoxDecoration(
        gradient: isDark ? null : LinearGradient(
          colors: [colors.primary, AppColors.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        color: isDark ? colors.surface : null,
        border: isDark ? Border.all(color: colors.border) : null,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: isDark ? colors.primary.withValues(alpha: 0.15) : Colors.white.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.shield, color: isDark ? colors.primary : Colors.white),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.heroTitle,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: isDark ? colors.textPrimary : Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
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
          const SizedBox(height: 16),
          _buildStatusRow(loading: loading, roleHeld: roleHeld),
        ],
      ),
    );
  }

  Widget _buildStatusRow({required bool loading, required bool roleHeld}) {
    final l = AppLocalizations.of(context)!;
    if (loading) {
      return _StatusPill(
        color: Colors.white.withValues(alpha: 0.6),
        background: Colors.white.withValues(alpha: 0.16),
        icon: Icons.hourglass_empty,
        label: l.heroStatusChecking,
      );
    }
    if (!_supported) {
      return _StatusPill(
        color: Colors.white,
        background: Colors.white.withValues(alpha: 0.16),
        icon: Icons.info_outline,
        label: l.heroStatusIos,
      );
    }
    if (roleHeld) {
      return _StatusPill(
        color: AppColors.riskSafe,
        background: AppColors.riskSafeContainer,
        icon: Icons.check_circle,
        label: l.heroStatusActive,
      );
    }
    return Row(
      children: [
        Flexible(
          child: _StatusPill(
            color: AppColors.riskHigh,
            background: AppColors.riskHighContainer,
            icon: Icons.notifications_off_outlined,
            label: l.heroStatusInactive,
          ),
        ),
        const SizedBox(width: 8),
        FilledButton.tonal(
          onPressed: _enabling ? null : _enable,
          style: FilledButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: AppColors.primaryDark,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
            shape: const StadiumBorder(),
            visualDensity: VisualDensity.compact,
          ),
          child: _enabling
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(
                  l.heroEnableBtn,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
        ),
      ],
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({
    required this.color,
    required this.background,
    required this.icon,
    required this.label,
  });

  final Color color;
  final Color background;
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 14),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  const _StatsRow({required this.history});
  final List<ScamCheckResult> history;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final total = history.length;
    final scams = history.where((h) => h.riskLevel == RiskLevel.scam).length;
    final safe = history.where((h) => h.riskLevel == RiskLevel.safe).length;
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            label: l.statChecked,
            value: '$total',
            color: AppColors.of(context).primary,
            icon: Icons.fact_check_outlined,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _StatCard(
            label: l.statSafe,
            value: '$safe',
            color: AppColors.riskSafe,
            icon: Icons.verified_outlined,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _StatCard(
            label: l.statScam,
            value: '$scams',
            color: AppColors.riskHigh,
            icon: Icons.dangerous_outlined,
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });

  final String label;
  final String value;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.of(context).surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.of(context).border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: color,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall,
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);
  final String text;
  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
    );
  }
}

class _CheckTile extends StatelessWidget {
  const _CheckTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.accent,
    required this.target,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color accent;
  final CheckTarget target;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.of(context).surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => ScamCheckScreen(target: target),
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border(
              top: BorderSide(color: AppColors.of(context).border),
              right: BorderSide(color: AppColors.of(context).border),
              bottom: BorderSide(color: AppColors.of(context).border),
            ),
          ),
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
          child: Row(
            children: [
              Container(
                width: 4,
                height: 44,
                decoration: BoxDecoration(
                  color: accent,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 14),
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
                    Text(title,
                        style: Theme.of(context).textTheme.titleSmall),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
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

/// Highlighted tile for the free-text AI analysis flow. Visually distinct
/// from the 3 structured-input tiles to signal "AI-driven, no DB lookup".
class _ContentAnalysisTile extends StatelessWidget {
  const _ContentAnalysisTile();

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors = AppColors.of(context);
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const ContentAnalysisScreen()),
        ),
        child: Container(
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
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: isDark ? colors.primary.withValues(alpha: 0.15) : Colors.white.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.auto_awesome, color: isDark ? colors.primary : Colors.white),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l.homeCheckContent,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            color: isDark ? colors.textPrimary : Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      l.homeCheckContentSub,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: isDark ? colors.textSecondary : Colors.white.withValues(alpha: 0.85),
                          ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: isDark ? colors.textTertiary : Colors.white70),
            ],
          ),
        ),
      ),
    );
  }
}

class _RecentActivity extends StatelessWidget {
  const _RecentActivity({required this.items});
  final List<ScamCheckResult> items;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.of(context).surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.of(context).border),
        ),
        child: Row(
          children: [
            Icon(Icons.lightbulb_outline,
                color: AppColors.of(context).textTertiary),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                AppLocalizations.of(context)!.homeNoActivity,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          ],
        ),
      );
    }
    final df = DateFormat('dd/MM HH:mm');
    return Container(
      decoration: BoxDecoration(
        color: AppColors.of(context).surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.of(context).border),
      ),
      child: Column(
        children: [
          for (var i = 0; i < items.length; i++) ...[
            if (i > 0) const Divider(height: 1, indent: 16, endIndent: 16),
            _ActivityRow(item: items[i], df: df),
          ],
        ],
      ),
    );
  }
}

class _ActivityRow extends StatelessWidget {
  const _ActivityRow({required this.item, required this.df});
  final ScamCheckResult item;
  final DateFormat df;

  @override
  Widget build(BuildContext context) {
    final icon = switch (item.target) {
      CheckTarget.phone => Icons.phone_outlined,
      CheckTarget.bankAccount => Icons.account_balance_outlined,
      CheckTarget.url => Icons.link,
      CheckTarget.content => Icons.text_snippet_outlined,
    };
    final color = item.riskLevel.color;
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => ResultScreen(result: item)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.input,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context)
                        .textTheme
                        .titleSmall
                        ?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${item.riskLevel.localizedLabel(context)} • ${df.format(item.checkedAt)}',
                    style: Theme.of(context)
                        .textTheme
                        .labelSmall
                        ?.copyWith(color: color, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: AppColors.of(context).textTertiary),
          ],
        ),
      ),
    );
  }
}
