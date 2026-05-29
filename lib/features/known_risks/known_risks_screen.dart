import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/risk_level.dart';
import '../../data/models/scam_check_result.dart';
import '../../data/models/vietnamese_bank.dart';
import '../../flutter_gen/gen_l10n/app_localizations.dart';
import '../../services/local_risk_service.dart';
import '../../shared/widgets/risk_badge.dart';
import '../result/result_screen.dart';

/// Browser for the centralized scam database (`public.known_risks` on
/// Supabase). Three tabs — phones, bank accounts, URLs — each list sorted by
/// scam → suspicious → safe. Tap a row to see the rich detail view (reuses
/// ResultScreen).
class KnownRisksScreen extends StatefulWidget {
  const KnownRisksScreen({super.key});

  @override
  State<KnownRisksScreen> createState() => _KnownRisksScreenState();
}

class _KnownRisksScreenState extends State<KnownRisksScreen>
    with SingleTickerProviderStateMixin {
  final _service = LocalRiskService();
  late final TabController _tabs;

  bool _loading = true;
  Map<CheckTarget, List<KnownRisk>> _byType = const {};

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 3, vsync: this);
    _load();
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  Future<void> _load({bool refresh = false}) async {
    setState(() => _loading = true);
    if (refresh) {
      await _service.refresh();
    } else {
      await _service.ensureLoaded();
    }
    final phones = await _service.listByType(CheckTarget.phone);
    final banks = await _service.listByType(CheckTarget.bankAccount);
    final urls = await _service.listByType(CheckTarget.url);
    if (!mounted) return;
    setState(() {
      _byType = {
        CheckTarget.phone: phones,
        CheckTarget.bankAccount: banks,
        CheckTarget.url: urls,
      };
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final phones = _byType[CheckTarget.phone] ?? const [];
    final banks = _byType[CheckTarget.bankAccount] ?? const [];
    final urls = _byType[CheckTarget.url] ?? const [];

    final currentTarget = switch (_tabs.index) {
      0 => CheckTarget.phone,
      1 => CheckTarget.bankAccount,
      _ => CheckTarget.url,
    };

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.knownRisksTitle),
        actions: [
          IconButton(
            tooltip: AppLocalizations.of(context)!.tooltipRefresh,
            icon: const Icon(Icons.refresh),
            onPressed: _loading ? null : () => _load(refresh: true),
          ),
        ],
        bottom: TabBar(
          controller: _tabs,
          isScrollable: false,
          labelColor: AppColors.of(context).primary,
          unselectedLabelColor: AppColors.of(context).textSecondary,
          indicatorColor: AppColors.of(context).primary,
          onTap: (_) => setState(() {}),
          tabs: [
            Tab(text: AppLocalizations.of(context)!.knownRisksTabPhone(phones.length)),
            Tab(text: AppLocalizations.of(context)!.knownRisksTabBank(banks.length)),
            Tab(text: AppLocalizations.of(context)!.knownRisksTabUrl(urls.length)),
          ],
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabs,
              children: [
                _RiskList(
                  items: phones,
                  target: CheckTarget.phone,
                  onDeleted: _load,
                ),
                _RiskList(
                  items: banks,
                  target: CheckTarget.bankAccount,
                  onDeleted: _load,
                ),
                _RiskList(
                  items: urls,
                  target: CheckTarget.url,
                  onDeleted: _load,
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _loading ? null : () => _showAddDialog(currentTarget),
        icon: const Icon(Icons.add),
        label: Text(AppLocalizations.of(context)!.knownRisksAddBtn),
      ),
    );
  }

  Future<void> _showAddDialog(CheckTarget target) async {
    final saved = await showDialog<bool>(
      context: context,
      builder: (_) => _AddRiskDialog(initialTarget: target, service: _service),
    );
    if (saved == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.knownRisksAddedSnack)),
      );
      _load();
    }
  }
}

class _RiskList extends StatelessWidget {
  const _RiskList({
    required this.items,
    required this.target,
    required this.onDeleted,
  });
  final List<KnownRisk> items;
  final CheckTarget target;
  final VoidCallback onDeleted;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.cloud_off,
                  size: 56, color: AppColors.of(context).textTertiary),
              const SizedBox(height: 12),
              Text(
                AppLocalizations.of(context)!.knownRisksEmpty,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.of(context).textSecondary,
                    ),
              ),
            ],
          ),
        ),
      );
    }
    final icon = switch (target) {
      CheckTarget.phone => Icons.phone_outlined,
      CheckTarget.bankAccount => Icons.account_balance_outlined,
      CheckTarget.url => Icons.link,
      CheckTarget.content => Icons.text_snippet_outlined,
    };
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      itemCount: items.length,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (_, i) {
        final r = items[i];
        return Dismissible(
          key: ValueKey('${r.target.name}-${r.value}'),
          direction: DismissDirection.endToStart,
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            decoration: BoxDecoration(
              color: AppColors.riskHigh,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const Icon(Icons.delete_outline, color: Colors.white),
                const SizedBox(width: 8),
                Text(AppLocalizations.of(context)!.knownRisksSwipeDelete,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    )),
              ],
            ),
          ),
          confirmDismiss: (_) => _confirmDelete(context, r),
          onDismissed: (_) => onDeleted(),
          child: Card(
            child: ListTile(
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: r.riskLevel.color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: r.riskLevel.color, size: 20),
              ),
              title: Text(
                r.value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontFamily: 'monospace',
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (r.target == CheckTarget.bankAccount && r.bankCode != null)
                    Text(
                      VietnameseBank.fromCode(r.bankCode).shortName,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: AppColors.of(context).textTertiary,
                          ),
                    ),
                  if (r.summary.isNotEmpty)
                    Padding(
                      padding: EdgeInsets.only(
                          top: r.bankCode != null ? 2 : 0),
                      child: Text(
                        r.summary,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.of(context).textSecondary,
                            ),
                      ),
                    ),
                ],
              ),
              trailing: RiskBadge(level: r.riskLevel, score: r.score),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => ResultScreen(result: r.toResult()),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Future<bool> _confirmDelete(BuildContext context, KnownRisk r) async {
    final l = AppLocalizations.of(context)!;
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(l.knownRisksDeleteTitle),
        content: Text(l.knownRisksDeleteBody(r.value)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l.knownRisksSwipeDelete, style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (ok != true) return false;
    final success = await LocalRiskService().deleteEntry(
      target: r.target,
      value: r.value,
    );
    if (!context.mounted) return false;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(success
            ? l.knownRisksDeletedSnack(r.value)
            : l.knownRisksDeleteFail(LocalRiskService().lastRefreshError ?? '')),
      ),
    );
    return success;
  }
}

class _AddRiskDialog extends StatefulWidget {
  const _AddRiskDialog({required this.initialTarget, required this.service});
  final CheckTarget initialTarget;
  final LocalRiskService service;

  @override
  State<_AddRiskDialog> createState() => _AddRiskDialogState();
}

class _AddRiskDialogState extends State<_AddRiskDialog> {
  late CheckTarget _target = widget.initialTarget;
  VietnameseBank? _selectedBank;
  RiskLevel _level = RiskLevel.scam;
  final _valueCtrl = TextEditingController();
  final _summaryCtrl = TextEditingController();
  final _reasonCtrl = TextEditingController();
  int _score = 85;
  bool _saving = false;

  @override
  void dispose() {
    _valueCtrl.dispose();
    _summaryCtrl.dispose();
    _reasonCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final value = _valueCtrl.text.trim();
    if (value.isEmpty) return;
    setState(() => _saving = true);
    final reasons = _reasonCtrl.text
        .trim()
        .split('\n')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
    final bankCode = _target == CheckTarget.bankAccount
        ? _selectedBank?.code
        : null;
    final ok = await widget.service.upsertEntry(
      target: _target,
      value: value,
      riskLevel: _level,
      score: _score,
      summary: _summaryCtrl.text.trim(),
      reasons: reasons,
      bankCode: bankCode,
    );
    if (!mounted) return;
    if (ok) {
      Navigator.pop(context, true);
    } else {
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.service.lastRefreshError ?? AppLocalizations.of(context)!.addDialogSaveFail),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return AlertDialog(
      title: Text(l.addDialogTitle),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DropdownButtonFormField<CheckTarget>(
              initialValue: _target,
              decoration: InputDecoration(labelText: l.addDialogType),
              items: [
                DropdownMenuItem(
                    value: CheckTarget.phone, child: Text(l.addDialogTypePhone)),
                DropdownMenuItem(
                    value: CheckTarget.bankAccount, child: Text(l.addDialogTypeBank)),
                DropdownMenuItem(value: CheckTarget.url, child: Text(l.addDialogTypeUrl)),
              ],
              onChanged: _saving
                  ? null
                  : (v) => setState(() {
                        _target = v ?? _target;
                        if (_target != CheckTarget.bankAccount) {
                          _selectedBank = null;
                        }
                      }),
            ),
            if (_target == CheckTarget.bankAccount) ...[
              const SizedBox(height: 8),
              DropdownButtonFormField<VietnameseBank>(
                initialValue: _selectedBank,
                isExpanded: true,
                decoration: InputDecoration(labelText: l.addDialogBank),
                items: [
                  ...VietnameseBanks.all.map(
                    (b) => DropdownMenuItem(
                      value: b,
                      child: Text(b.name),
                    ),
                  ),
                ],
                onChanged: _saving
                    ? null
                    : (v) => setState(() => _selectedBank = v),
              ),
            ],
            const SizedBox(height: 8),
            TextField(
              controller: _valueCtrl,
              decoration: InputDecoration(
                labelText: l.addDialogValue,
                hintText: l.addDialogValueHint,
              ),
              enabled: !_saving,
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<RiskLevel>(
              initialValue: _level,
              decoration: InputDecoration(labelText: l.addDialogRisk),
              items: [
                DropdownMenuItem(
                    value: RiskLevel.scam, child: Text(l.addDialogRiskScam)),
                DropdownMenuItem(
                    value: RiskLevel.suspicious,
                    child: Text(l.addDialogRiskSuspicious)),
                DropdownMenuItem(
                    value: RiskLevel.safe, child: Text(l.addDialogRiskSafe)),
              ],
              onChanged: _saving
                  ? null
                  : (v) => setState(() {
                        _level = v ?? _level;
                        _score = switch (_level) {
                          RiskLevel.scam => 90,
                          RiskLevel.suspicious => 55,
                          RiskLevel.safe => 5,
                          RiskLevel.unknown => 0,
                        };
                      }),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Text('Score'),
                Expanded(
                  child: Slider(
                    value: _score.toDouble(),
                    min: 0,
                    max: 100,
                    divisions: 100,
                    label: '$_score',
                    onChanged: _saving
                        ? null
                        : (v) => setState(() => _score = v.round()),
                  ),
                ),
                SizedBox(
                  width: 36,
                  child: Text('$_score',
                      textAlign: TextAlign.end,
                      style: const TextStyle(fontWeight: FontWeight.w700)),
                ),
              ],
            ),
            TextField(
              controller: _summaryCtrl,
              decoration: InputDecoration(labelText: l.addDialogSummary),
              maxLines: 2,
              enabled: !_saving,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _reasonCtrl,
              decoration: InputDecoration(
                labelText: l.addDialogReasons,
                alignLabelWithHint: true,
              ),
              maxLines: 4,
              enabled: !_saving,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _saving ? null : () => Navigator.pop(context, false),
          child: Text(l.cancel),
        ),
        FilledButton(
          onPressed: _saving ? null : _save,
          child: _saving
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(l.addDialogSave),
        ),
      ],
    );
  }
}
