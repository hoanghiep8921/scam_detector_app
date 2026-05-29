import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/scam_check_result.dart';
import '../../data/models/vietnamese_bank.dart';
import '../../flutter_gen/gen_l10n/app_localizations.dart';
import '../../shared/widgets/scanning_overlay.dart';
import '../content_analysis/content_analysis_screen.dart';
import '../history/history_screen.dart';
import '../result/result_screen.dart';
import '../settings/settings_screen.dart';
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
  VietnameseBank? _selectedBank;
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
    final l = AppLocalizations.of(context)!;
    final v = value?.trim() ?? '';
    if (v.isEmpty) return l.checkValidationRequired;
    switch (_target) {
      case CheckTarget.phone:
        if (!RegExp(r'^[\d+\-\s()]{6,20}$').hasMatch(v)) {
          return l.checkValidationPhone;
        }
      case CheckTarget.bankAccount:
        final digits = v.replaceAll(RegExp(r'[\s\-]'), '');
        if (!RegExp(r'^\d{6,30}$').hasMatch(digits)) {
          return l.checkValidationBank;
        }
        if (_selectedBank != null && _selectedBank != VietnameseBank.other) {
          if (digits.length < _selectedBank!.minDigits ||
              digits.length > _selectedBank!.maxDigits) {
            return l.checkBankValidationRange(
              _selectedBank!.shortName,
              _selectedBank!.minDigits,
              _selectedBank!.maxDigits,
            );
          }
        }
      case CheckTarget.url:
        if (!RegExp(r'\.[a-z]{2,}', caseSensitive: false).hasMatch(v)) {
          return l.checkValidationUrl;
        }
      case CheckTarget.content:
        if (v.length < 5) {
          return l.checkValidationContentShort;
        }
    }
    return null;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    final bankCode = _target == CheckTarget.bankAccount
        ? _selectedBank?.code
        : null;
    final provider = context.read<ScamCheckProvider>();
    final locale = Localizations.localeOf(context).languageCode;
    final result = await provider.check(
          target: _target,
          input: _controller.text,
          bankCode: bankCode,
          locale: locale,
        );
    if (!mounted) return;
    if (result == null) {
      final error = provider.error;
      if (error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: $error')),
        );
      }
      return;
    }
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => ResultScreen(result: result)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final provider = context.watch<ScamCheckProvider>();
    final loading = provider.isLoading || provider.isAiLoading;
    return Scaffold(
      appBar: AppBar(
        title: Text(l.checkTitle),
        actions: [
          IconButton(
            icon: Icon(Icons.settings_outlined, color: AppColors.of(context).textSecondary),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const SettingsScreen()),
            ),
            tooltip: l.tooltipSettings,
          ),
        ],
      ),
      body: SafeArea(
        child: Stack(
          children: [
            ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              children: [
                _SegmentedTargetSelector(
                  target: _target,
                  onChanged: (t) {
                    if (t == CheckTarget.content) {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const ContentAnalysisScreen(),
                        ),
                      );
                      return;
                    }
                    setState(() {
                      _target = t;
                      _selectedBank = null;
                    });
                    _formKey.currentState?.reset();
                  },
                ),
                const SizedBox(height: 32),
                Center(
                  child: Text(
                    l.checkVerifyTitle,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                ),
                const SizedBox(height: 8),
                Center(
                  child: Text(
                    _subtitleFor(_target, l),
                    textAlign: TextAlign.center,
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(color: AppColors.of(context).textSecondary),
                  ),
                ),
                const SizedBox(height: 28),
                if (_target == CheckTarget.bankAccount)
                  _BankSelector(
                    selectedBank: _selectedBank,
                    onChanged: (bank) =>
                        setState(() => _selectedBank = bank),
                  ),
                if (_target == CheckTarget.bankAccount) const SizedBox(height: 16),
                Form(
                  key: _formKey,
                  child: TextFormField(
                    key: ValueKey(_target),
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
                      hintText: _target == CheckTarget.bankAccount
                          ? _bankHint(_selectedBank, l)
                          : _hintFor(_target, l),
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
                      ? l.checkAnalyzeBtn
                      : l.checkSubmitBtn),
                ),
                const SizedBox(height: 24),
                const _DetectionEngineCard(),
                const SizedBox(height: 16),
                _CommunityReportCard(target: _target),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _SecondaryTile(
                        icon: Icons.history,
                        title: l.historyTile,
                        subtitle: l.historyTileSub,
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
                        title: l.tipsTile,
                        subtitle: l.tipsTileSub,
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

  static String _subtitleFor(CheckTarget t, AppLocalizations l) => switch (t) {
        CheckTarget.phone => l.checkSubtitlePhone,
        CheckTarget.bankAccount => l.checkSubtitleBank,
        CheckTarget.url => l.checkSubtitleUrl,
        CheckTarget.content => l.checkSubtitleContent,
      };

  static String _bankHint(VietnameseBank? bank, AppLocalizations l) {
    if (bank == null) return l.checkHintBank;
    if (bank == VietnameseBank.other) return l.checkBankHintOther;
    final range = bank.minDigits == bank.maxDigits
        ? l.checkBankDigits(bank.minDigits)
        : l.checkBankDigitRange(bank.minDigits, bank.maxDigits);
    return l.checkBankHintWithRange(bank.shortName, range);
  }

  static String _hintFor(CheckTarget t, AppLocalizations l) => switch (t) {
        CheckTarget.phone => l.checkHintPhone,
        CheckTarget.bankAccount => l.checkHintBank,
        CheckTarget.url => l.checkHintUrl,
        CheckTarget.content => l.checkHintContent,
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
        color: AppColors.of(context).primaryContainer.withValues(alpha: 0.6),
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
      CheckTarget.phone => AppLocalizations.of(context)!.segPhone,
      CheckTarget.bankAccount => AppLocalizations.of(context)!.segBank,
      CheckTarget.url => AppLocalizations.of(context)!.segUrl,
      CheckTarget.content => AppLocalizations.of(context)!.segContent,
    };
    final icon = switch (target) {
      CheckTarget.phone => Icons.phone_outlined,
      CheckTarget.bankAccount => Icons.account_balance_outlined,
      CheckTarget.url => Icons.link,
      CheckTarget.content => Icons.text_snippet_outlined,
    };
    final color = selected ? AppColors.of(context).primary : AppColors.of(context).textSecondary;
    return Material(
      color: selected ? AppColors.of(context).surface : Colors.transparent,
      borderRadius: BorderRadius.circular(10),
      elevation: selected ? 1 : 0,
      shadowColor: AppColors.of(context).primary.withValues(alpha: 0.2),
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
                color: AppColors.of(context).primaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.auto_awesome_outlined,
                color: AppColors.of(context).primary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocalizations.of(context)!.engineTitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    AppLocalizations.of(context)!.engineSubtitle,
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
              Icon(icon, color: AppColors.of(context).primary, size: 22),
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

/// Card that lets users report a phone number / URL / bank account as scam.
/// Visible for phone, bank, and URL targets; shows a short form in a dialog.
class _CommunityReportCard extends StatelessWidget {
  const _CommunityReportCard({required this.target});
  final CheckTarget target;

  void _openDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => _ReportDialog(target: target),
    );
  }

  // ignore: use_build_context_synchronously
  BuildContext get _context => throw UnimplementedError();

  @override
  Widget build(BuildContext context) {
    if (target == CheckTarget.content) return const SizedBox.shrink();
    final l = AppLocalizations.of(context)!;
    final subtitle = switch (target) {
      CheckTarget.phone => l.reportSubPhone,
      CheckTarget.bankAccount => l.reportSubBank,
      CheckTarget.url => l.reportSubUrl,
      CheckTarget.content => '',
    };
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.riskMedium.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.flag_outlined, color: AppColors.riskMedium),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l.reportTitle,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            OutlinedButton(
              onPressed: () => _openDialog(context),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(0, 36),
                padding: const EdgeInsets.symmetric(horizontal: 16),
              ),
              child: Text(l.reportBtn),
            ),
          ],
        ),
      ),
    );
  }
}

/// Dialog for submitting a community scam report.
class _ReportDialog extends StatefulWidget {
  const _ReportDialog({required this.target});
  final CheckTarget target;

  @override
  State<_ReportDialog> createState() => _ReportDialogState();
}

class _ReportDialogState extends State<_ReportDialog> {
  final _valueController = TextEditingController();
  final _descController = TextEditingController();
  bool _submitting = false;

  @override
  void dispose() {
    _valueController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_valueController.text.trim().isEmpty) return;
    setState(() => _submitting = true);
    final ok = await context.read<ScamCheckProvider>().submitCommunityReport(
          target: widget.target,
          value: _valueController.text.trim(),
          description: _descController.text.trim(),
        );
    if (!mounted) return;
    Navigator.of(context).pop();
    final l = AppLocalizations.of(context)!;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(ok ? l.reportSuccess : l.reportFail),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final hintLabel = switch (widget.target) {
      CheckTarget.phone => l.reportDialogLabelPhone,
      CheckTarget.bankAccount => l.reportDialogLabelBank,
      CheckTarget.url => l.reportDialogLabelUrl,
      CheckTarget.content => '',
    };
    return AlertDialog(
      title: Text(l.reportDialogTitle),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(hintLabel, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 8),
          TextField(
            controller: _valueController,
            decoration: InputDecoration(
              hintText: switch (widget.target) {
                CheckTarget.phone => '+84 9XX XXX XXX',
                CheckTarget.bankAccount => '1903 5762 8810',
                CheckTarget.url => 'vietcombank-online.xyz',
                CheckTarget.content => '',
              },
            ),
          ),
          const SizedBox(height: 16),
          Text(l.reportDialogDesc, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 8),
          TextField(
            controller: _descController,
            maxLines: 3,
            decoration: InputDecoration(hintText: l.reportDialogDescHint),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _submitting ? null : () => Navigator.of(context).pop(),
          child: Text(l.cancel),
        ),
        FilledButton(
          onPressed: _submitting ? null : _submit,
          child: _submitting
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(l.send),
        ),
      ],
    );
  }
}

/// Dropdown for selecting a Vietnamese bank when checking a bank account.
class _BankSelector extends StatelessWidget {
  const _BankSelector({
    required this.selectedBank,
    required this.onChanged,
  });

  final VietnameseBank? selectedBank;
  final ValueChanged<VietnameseBank?> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<VietnameseBank>(
      initialValue: selectedBank,
      isExpanded: true,
      decoration: InputDecoration(
        labelText: AppLocalizations.of(context)!.checkBankLabel,
        hintText: AppLocalizations.of(context)!.checkBankHint,
        prefixIcon: const Icon(Icons.account_balance_outlined),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      items: [
        ...VietnameseBanks.all.map(
          (b) => DropdownMenuItem(
            value: b,
            child: Text(b.name),
          ),
        ),
      ],
      onChanged: onChanged,
    );
  }
}
