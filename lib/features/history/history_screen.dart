import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/scam_check_result.dart';
import '../../flutter_gen/gen_l10n/app_localizations.dart';
import '../../services/call_screening_service.dart';
import '../../shared/widgets/risk_badge.dart';
import '../result/result_screen.dart';
import '../scam_check/scam_check_provider.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final provider = context.read<ScamCheckProvider>();
      await provider.loadHistory();
      // Drain any natively-screened calls the user hasn't tapped through yet
      // so they show up in the list immediately.
      final events = await CallScreeningService().drainScreeningEvents();
      if (events.isNotEmpty && mounted) {
        final l = AppLocalizations.of(context)!;
        await provider.ingestScreenedCalls(
          events,
          blockedSummary: l.screenedCallBlockedSummary,
          warnedSummary: l.screenedCallWarnedSummary,
          blockedReason: (n) => l.screenedCallBlockedReason(n),
          warnedReason: (n) => l.screenedCallWarnedReason(n),
          offlineReason: l.screenedCallOfflineReason,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final items = context.watch<ScamCheckProvider>().historyItems;

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.historyScreenTitle),
        actions: [
          if (items.isNotEmpty)
            IconButton(
              tooltip: AppLocalizations.of(context)!.tooltipDeleteAll,
              icon: const Icon(Icons.delete_outline),
              onPressed: () async {
                final l = AppLocalizations.of(context)!;
                final ok = await showDialog<bool>(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: Text(l.historyDeleteAllConfirmTitle),
                    content: Text(l.historyDeleteAllConfirmBody),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: Text(l.cancel),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: Text(l.historyDeleteBtn),
                      ),
                    ],
                  ),
                );
                if (ok == true && context.mounted) {
                  await context.read<ScamCheckProvider>().clearHistory();
                }
              },
            ),
        ],
      ),
      body: items.isEmpty ? const _EmptyState() : _List(items: items),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.history, size: 64, color: AppColors.of(context).textTertiary),
          const SizedBox(height: 12),
          Text(AppLocalizations.of(context)!.historyEmpty,
              style: TextStyle(color: AppColors.of(context).textSecondary)),
        ],
      ),
    );
  }
}

class _List extends StatelessWidget {
  const _List({required this.items});
  final List<ScamCheckResult> items;

  @override
  Widget build(BuildContext context) {
    final df = DateFormat('dd/MM/yyyy HH:mm');
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (_, i) {
        final r = items[i];
        return Card(
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            title: Text(
              r.input,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                '${r.target.localizedLabel(context)} • ${df.format(r.checkedAt)}',
                style: TextStyle(fontSize: 12, color: AppColors.of(context).textSecondary),
              ),
            ),
            trailing: RiskBadge(level: r.riskLevel, score: r.riskScore),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => ResultScreen(result: r)),
            ),
          ),
        );
      },
    );
  }
}
