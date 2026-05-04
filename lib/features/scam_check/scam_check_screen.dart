import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/scam_check_result.dart';
import '../../shared/widgets/scanning_overlay.dart';
import '../history/history_screen.dart';
import '../result/result_screen.dart';
import 'scam_check_provider.dart';

/// Unified manual check screen — segmented control switches between phone /
/// bank / URL while keeping the input + analysis flow consistent.
class ScamCheckScreen extends StatefulWidget {
  const ScamCheckScreen({super.key, required this.target});

  final CheckTarget target;

  @override
  State<ScamCheckScreen> createState() => _ScamCheckScreenState();
}

class _ScamCheckScreenState extends State<ScamCheckScreen> {
  late CheckTarget _target = widget.target;
  final _controllers = {
    for (final t in CheckTarget.values) t: TextEditingController(),
  };
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    for (final c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  TextEditingController get _controller => _controllers[_target]!;

  String? _validate(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'Vui lòng nhập thông tin';
    switch (_target) {
      case CheckTarget.phone:
        if (!RegExp(r'^[\d+\-\s()]{6,20}$').hasMatch(v)) {
          return 'Số điện thoại không hợp lệ';
        }
      case CheckTarget.bankAccount:
        if (!RegExp(r'^[\d\-\s]{6,30}$').hasMatch(v)) {
          return 'Số tài khoản không hợp lệ';
        }
      case CheckTarget.url:
        if (!RegExp(r'\.[a-z]{2,}', caseSensitive: false).hasMatch(v)) {
          return 'Đường dẫn không hợp lệ';
        }
      case CheckTarget.content:
        if (v.length < 5) {
          return 'Nội dung quá ngắn (tối thiểu 5 ký tự)';
        }
    }
    return null;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    final result = await context.read<ScamCheckProvider>().check(
          target: _target,
          input: _controller.text,
        );
    if (!mounted || result == null) return;
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => ResultScreen(result: result)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loading = context.watch<ScamCheckProvider>().isLoading;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scam Guard'),
        actions: const [
          IconButton(
            icon: Icon(Icons.settings_outlined, color: AppColors.textSecondary),
            onPressed: null,
            tooltip: 'Cài đặt',
          ),
        ],
      ),
      body: SafeArea(
        child: Stack(
          children: [
            ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
              children: [
                _SegmentedTargetSelector(
                  target: _target,
                  onChanged: (t) {
                    setState(() => _target = t);
                    _formKey.currentState?.reset();
                  },
                ),
                const SizedBox(height: 32),
                Center(
                  child: Text(
                    'Xác minh đối tượng',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                ),
                const SizedBox(height: 8),
                Center(
                  child: Text(
                    _subtitleFor(_target),
                    textAlign: TextAlign.center,
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(color: AppColors.textSecondary),
                  ),
                ),
                const SizedBox(height: 28),
                Form(
                  key: _formKey,
                  child: TextFormField(
                    controller: _controller,
                    keyboardType: _keyboardFor(_target),
                    textInputAction: _target == CheckTarget.content
                        ? TextInputAction.newline
                        : TextInputAction.search,
                    onFieldSubmitted: _target == CheckTarget.content
                        ? null
                        : (_) => _submit(),
                    validator: _validate,
                    style: TextStyle(
                      fontSize: _target == CheckTarget.content ? 14 : 16,
                      height: _target == CheckTarget.content ? 1.4 : null,
                    ),
                    minLines: _target == CheckTarget.content ? 5 : 1,
                    maxLines: _target == CheckTarget.content ? 10 : 1,
                    inputFormatters: switch (_target) {
                      CheckTarget.url || CheckTarget.content => null,
                      CheckTarget.phone || CheckTarget.bankAccount => [
                          FilteringTextInputFormatter.allow(
                            RegExp(r'[\d+\-\s()]'),
                          ),
                        ],
                    },
                    decoration: InputDecoration(
                      hintText: _hintFor(_target),
                      hintMaxLines: _target == CheckTarget.content ? 4 : 1,
                      hintStyle: _target == CheckTarget.content
                          ? const TextStyle(fontSize: 13, height: 1.45)
                          : null,
                      prefixIcon: _target == CheckTarget.content
                          ? null
                          : Icon(_iconFor(_target)),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: loading ? null : _submit,
                  icon: Icon(_target == CheckTarget.content
                      ? Icons.auto_awesome
                      : Icons.shield_outlined),
                  label: Text(_target == CheckTarget.content
                      ? 'Phân tích bằng AI'
                      : 'Kiểm tra ngay'),
                ),
                const SizedBox(height: 24),
                const _DetectionEngineCard(),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _SecondaryTile(
                        icon: Icons.history,
                        title: 'Lịch sử',
                        subtitle: 'Xem các lượt đã kiểm tra',
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const HistoryScreen(),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _SecondaryTile(
                        icon: Icons.info_outline,
                        title: 'Mẹo bảo vệ',
                        subtitle: 'Không cung cấp OTP, mã PIN cho ai',
                        onTap: () {},
                      ),
                    ),
                  ],
                ),
              ],
            ),
            if (loading) const Positioned.fill(child: ScanningOverlay()),
          ],
        ),
      ),
    );
  }

  static String _subtitleFor(CheckTarget t) => switch (t) {
        CheckTarget.phone =>
          'Đối chiếu danh sách rủi ro toàn cầu và phân tích tâm lý lừa đảo theo thời gian thực.',
        CheckTarget.bankAccount =>
          'Kiểm tra số tài khoản nhận tiền có nằm trong các vụ lừa đảo đã được báo cáo.',
        CheckTarget.url =>
          'Phân tích cấu trúc tên miền và dấu hiệu giả mạo thương hiệu.',
        CheckTarget.content =>
          'Dán SMS, email hoặc mô tả tình huống — AI phân tích đa góc nhìn.',
      };

  static String _hintFor(CheckTarget t) => switch (t) {
        CheckTarget.phone => '+84 9XX XXX XXX',
        CheckTarget.bankAccount => 'VD: 1903 5762 8810',
        CheckTarget.url => 'VD: vietcombank-online.xyz',
        CheckTarget.content =>
          'VD: "Vietcombank thông báo tài khoản của quý khách bị khoá. Vui lòng truy cập http://vcb-xacminh.tk để xác minh trong 10 phút..."',
      };

  static IconData _iconFor(CheckTarget t) => switch (t) {
        CheckTarget.phone => Icons.phone_outlined,
        CheckTarget.bankAccount => Icons.account_balance_outlined,
        CheckTarget.url => Icons.link,
        CheckTarget.content => Icons.text_snippet_outlined,
      };

  static TextInputType _keyboardFor(CheckTarget t) => switch (t) {
        CheckTarget.phone => TextInputType.phone,
        CheckTarget.bankAccount => TextInputType.number,
        CheckTarget.url => TextInputType.url,
        CheckTarget.content => TextInputType.multiline,
      };
}

class _SegmentedTargetSelector extends StatelessWidget {
  const _SegmentedTargetSelector({
    required this.target,
    required this.onChanged,
  });

  final CheckTarget target;
  final ValueChanged<CheckTarget> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.primaryContainer.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          for (final t in CheckTarget.values)
            Expanded(child: _SegmentTab(
              target: t,
              selected: t == target,
              onTap: () => onChanged(t),
            )),
        ],
      ),
    );
  }
}

class _SegmentTab extends StatelessWidget {
  const _SegmentTab({
    required this.target,
    required this.selected,
    required this.onTap,
  });

  final CheckTarget target;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final label = switch (target) {
      CheckTarget.phone => 'Số ĐT',
      CheckTarget.bankAccount => 'Tài khoản',
      CheckTarget.url => 'Đường dẫn',
      CheckTarget.content => 'Nội dung',
    };
    final icon = switch (target) {
      CheckTarget.phone => Icons.phone_outlined,
      CheckTarget.bankAccount => Icons.account_balance_outlined,
      CheckTarget.url => Icons.link,
      CheckTarget.content => Icons.text_snippet_outlined,
    };
    final color = selected ? AppColors.primary : AppColors.textSecondary;
    return Material(
      color: selected ? AppColors.surface : Colors.transparent,
      borderRadius: BorderRadius.circular(10),
      elevation: selected ? 1 : 0,
      shadowColor: AppColors.primary.withValues(alpha: 0.2),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 2),
          // Clamp text scale so device-level "huge font" accessibility
          // settings (Samsung often defaults to 1.15x+) don't blow up the
          // segmented control. Text is small + can wrap to 2 lines if needed.
          child: MediaQuery.withClampedTextScaling(
            maxScaleFactor: 1.1,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 16, color: color),
                const SizedBox(height: 4),
                Text(
                  label,
                  maxLines: 2,
                  softWrap: true,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11,
                    height: 1.15,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                    color: color,
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

class _DetectionEngineCard extends StatelessWidget {
  const _DetectionEngineCard();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.primaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.auto_awesome_outlined,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hybrid Detection Engine',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Local blocklist  •  Gemini Flash AI',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SecondaryTile extends StatelessWidget {
  const _SecondaryTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: AppColors.primary, size: 22),
              const SizedBox(height: 10),
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodySmall,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
