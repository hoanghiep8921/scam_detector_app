import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/risk_level.dart';
import '../../data/models/scam_check_result.dart';
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
        title: const Text('Cơ sở dữ liệu lừa đảo'),
        actions: [
          IconButton(
            tooltip: 'Tải lại từ máy chủ',
            icon: const Icon(Icons.refresh),
            onPressed: _loading ? null : () => _load(refresh: true),
          ),
        ],
        bottom: TabBar(
          controller: _tabs,
          isScrollable: false,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.primary,
          onTap: (_) => setState(() {}),
          tabs: [
            Tab(text: 'Số ĐT (${phones.length})'),
            Tab(text: 'Tài khoản (${banks.length})'),
            Tab(text: 'Đường dẫn (${urls.length})'),
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
        label: const Text('Thêm'),
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
        const SnackBar(content: Text('Đã thêm vào cơ sở dữ liệu.')),
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
              const Icon(Icons.cloud_off,
                  size: 56, color: AppColors.textTertiary),
              const SizedBox(height: 12),
              Text(
                'Chưa có dữ liệu cho danh mục này.\nKiểm tra kết nối Supabase rồi bấm tải lại.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
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
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Icon(Icons.delete_outline, color: Colors.white),
                SizedBox(width: 8),
                Text('Xoá',
                    style: TextStyle(
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
              subtitle: r.summary.isEmpty
                  ? null
                  : Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        r.summary,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                      ),
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
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Xoá khỏi cơ sở dữ liệu?'),
        content: Text(
          '${r.value} sẽ bị xoá khỏi Supabase. Mọi thiết bị khác cũng sẽ '
          'không nhận được entry này khi đồng bộ.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Huỷ'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Xoá', style: TextStyle(color: Colors.red)),
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
            ? 'Đã xoá ${r.value}.'
            : 'Không xoá được: ${LocalRiskService().lastRefreshError ?? ""}'),
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
    final ok = await widget.service.upsertEntry(
      target: _target,
      value: value,
      riskLevel: _level,
      score: _score,
      summary: _summaryCtrl.text.trim(),
      reasons: reasons,
    );
    if (!mounted) return;
    if (ok) {
      Navigator.pop(context, true);
    } else {
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.service.lastRefreshError ?? 'Lưu thất bại.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Thêm vào cơ sở dữ liệu'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DropdownButtonFormField<CheckTarget>(
              initialValue: _target,
              decoration: const InputDecoration(labelText: 'Loại'),
              items: const [
                DropdownMenuItem(
                    value: CheckTarget.phone, child: Text('Số điện thoại')),
                DropdownMenuItem(
                    value: CheckTarget.bankAccount, child: Text('Tài khoản NH')),
                DropdownMenuItem(value: CheckTarget.url, child: Text('Đường dẫn')),
              ],
              onChanged: _saving
                  ? null
                  : (v) => setState(() => _target = v ?? _target),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _valueCtrl,
              decoration: const InputDecoration(
                labelText: 'Giá trị',
                hintText: 'VD: 0888888888 / vietcombank-online.xyz',
              ),
              enabled: !_saving,
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<RiskLevel>(
              initialValue: _level,
              decoration: const InputDecoration(labelText: 'Mức rủi ro'),
              items: const [
                DropdownMenuItem(
                    value: RiskLevel.scam, child: Text('Lừa đảo (scam)')),
                DropdownMenuItem(
                    value: RiskLevel.suspicious,
                    child: Text('Nghi ngờ (suspicious)')),
                DropdownMenuItem(
                    value: RiskLevel.safe, child: Text('An toàn (safe)')),
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
              decoration: const InputDecoration(
                labelText: 'Tóm tắt (1 câu)',
              ),
              maxLines: 2,
              enabled: !_saving,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _reasonCtrl,
              decoration: const InputDecoration(
                labelText: 'Lý do (mỗi dòng 1 ý)',
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
          child: const Text('Huỷ'),
        ),
        FilledButton(
          onPressed: _saving ? null : _save,
          child: _saving
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Lưu'),
        ),
      ],
    );
  }
}
