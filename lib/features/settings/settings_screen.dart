import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../flutter_gen/gen_l10n/app_localizations.dart';
import '../../services/settings_service.dart';

/// Settings screen — reachable from the home app bar gear icon.
/// Lets the user change theme mode (light/dark/system) and language.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsService>();
    final l = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l.settingsTitle),
      ),
      body: ListView(
        children: [
          // ── Appearance ──────────────────────────────────────────
          _SectionHeader(l.settingsAppearance),
          _SegmentedPicker(
            labels: [
              l.settingsLight,
              l.settingsDark,
              l.settingsSystem,
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
          _SectionHeader(l.settingsLanguage),
          _SegmentedPicker(
            labels: [
              l.settingsLanguageVi,
              l.settingsLanguageEn,
            ],
            selectedIndex: settings.locale == 'en' ? 1 : 0,
            onSelected: (i) {
              settings.setLocale(i == 0 ? 'vi' : 'en');
            },
          ),
          const SizedBox(height: 16),

          // ── Behavior ────────────────────────────────────────────
          _SectionHeader(l.settingsBehavior),
          _SwitchTile(
            title: l.settingsPreventMinimize,
            subtitle: l.settingsPreventMinimizeDesc,
            value: settings.preventMinimize,
            onChanged: (v) => settings.setPreventMinimize(v),
          ),
          const SizedBox(height: 24),

          // ── About ───────────────────────────────────────────────
          _AboutCard(
            appName: l.settingsAppName,
            dataResetLabel: l.settingsDataReset,
          ),
        ],
      ),
    );
  }
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
          color: AppColors.of(context).surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.of(context).border),
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
        color: AppColors.of(context).surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.of(context).border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.shield, color: AppColors.of(context).primary, size: 24),
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
    final l = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(dataResetLabel),
        content: Text(l.settingsResetDialogBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l.cancel),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(l.settingsResetComingSoon),
                ),
              );
            },
            child: Text(l.confirm),
          ),
        ],
      ),
    );
  }
}
