import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/i18n/app_strings.dart';
import '../../services/settings_service.dart';

/// Settings screen — reachable from the home app bar gear icon.
/// Lets the user change theme mode (light/dark/system) and language.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsService>();
    final strings = _S(locale: settings.locale);

    return Scaffold(
      appBar: AppBar(
        title: Text(strings.settingsTitle),
      ),
      body: ListView(
        children: [
          // ── Appearance ──────────────────────────────────────────
          _SectionHeader(strings.settingsAppearance),
          _SegmentedPicker(
            labels: [
              strings.settingsLight,
              strings.settingsDark,
              strings.settingsSystem,
            ],
            selectedIndex: switch (settings.themeMode) {
              ThemeMode.light => 0,
              ThemeMode.dark => 1,
              ThemeMode.system => 2,
            },
            onSelected: (i) {
              final modes = [
                ThemeMode.light,
                ThemeMode.dark,
                ThemeMode.system,
              ];
              settings.setThemeMode(modes[i]);
            },
          ),
          const SizedBox(height: 16),

          // ── Language ────────────────────────────────────────────
          _SectionHeader(strings.settingsLanguage),
          _SegmentedPicker(
            labels: [
              strings.settingsLanguageVi,
              strings.settingsLanguageEn,
            ],
            selectedIndex: settings.locale == 'en' ? 1 : 0,
            onSelected: (i) {
              settings.setLocale(i == 0 ? 'vi' : 'en');
            },
          ),
          const SizedBox(height: 16),

          // ── Behavior ────────────────────────────────────────────
          _SectionHeader(strings.settingsBehavior),
          _SwitchTile(
            title: strings.settingsPreventMinimize,
            subtitle: strings.settingsPreventMinimizeDesc,
            value: settings.preventMinimize,
            onChanged: (v) => settings.setPreventMinimize(v),
          ),
          const SizedBox(height: 24),

          // ── About ───────────────────────────────────────────────
          _AboutCard(
            appName: strings.settingsAppName,
            dataResetLabel: strings.settingsDataReset,
          ),
        ],
      ),
    );
  }
}

/// Per-locale strings for the settings screen to avoid rebuild noise.
class _S {
  _S({required String locale}) : _locale = locale;
  final String _locale;

  String get settingsTitle => AppStrings.of('settings_title', _locale);
  String get settingsAppearance => AppStrings.of('settings_appearance', _locale);
  String get settingsLight => AppStrings.of('settings_light', _locale);
  String get settingsDark => AppStrings.of('settings_dark', _locale);
  String get settingsSystem => AppStrings.of('settings_system', _locale);
  String get settingsLanguage => AppStrings.of('settings_language', _locale);
  String get settingsLanguageVi => AppStrings.of('settings_language_vi', _locale);
  String get settingsLanguageEn => AppStrings.of('settings_language_en', _locale);
  String get settingsAppName => AppStrings.of('settings_app_name', _locale);
  String get settingsDataReset => AppStrings.of('settings_data_reset', _locale);
  String get settingsBehavior => AppStrings.of('settings_behavior', _locale);
  String get settingsPreventMinimize => AppStrings.of('settings_prevent_minimize', _locale);
  String get settingsPreventMinimizeDesc => AppStrings.of('settings_prevent_minimize_desc', _locale);
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Text(
        text,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w700,
            ),
      ),
    );
  }
}

class _SegmentedPicker extends StatelessWidget {
  const _SegmentedPicker({
    required this.labels,
    required this.selectedIndex,
    required this.onSelected,
  });

  final List<String> labels;
  final int selectedIndex;
  final void Function(int) onSelected;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SegmentedButton<int>(
        segments: labels
            .asMap()
            .entries
            .map((e) => ButtonSegment<int>(
                  value: e.key,
                  label: Text(e.value),
                ))
            .toList(),
        selected: {selectedIndex},
        onSelectionChanged: (s) => onSelected(s.first),
        showSelectedIcon: false,
      ),
    );
  }
}

class _SwitchTile extends StatelessWidget {
  const _SwitchTile({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final String title;
  final String subtitle;
  final bool value;
  final void Function(bool) onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: SwitchListTile(
          contentPadding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
          title: Text(title),
          subtitle: Text(
            subtitle,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          value: value,
          onChanged: onChanged,
        ),
      ),
    );
  }
}

class _AboutCard extends StatelessWidget {
  const _AboutCard({
    required this.appName,
    required this.dataResetLabel,
  });
  final String appName;
  final String dataResetLabel;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.shield, color: AppColors.primary, size: 24),
              const SizedBox(width: 12),
              Text(
                appName,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '1.0.0',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const Divider(height: 24),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.delete_forever_outlined,
                color: AppColors.riskHigh),
            title: Text(dataResetLabel),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showResetDialog(context),
          ),
        ],
      ),
    );
  }

  void _showResetDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(dataResetLabel),
        content: Text(
          'Hành động này sẽ xoá toàn bộ dữ liệu trên máy, bao gồm lịch sử, danh sách chặn và cài đặt. Tiếp tục?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Huỷ'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Tính năng này sẽ được bổ sung sau.'),
                ),
              );
            },
            child: const Text('Xác nhận'),
          ),
        ],
      ),
    );
  }
}
