import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/risk_level.dart';
import '../../data/models/scam_check_result.dart';
import '../../shared/widgets/risk_badge.dart';
import '../result/result_screen.dart';
import '../scam_check/scam_check_provider.dart';

/// In-app inbox showing every call the native [IncomingCallScreener] has
/// blocked or flagged. Mirrors the Android system notifications, so users who
/// open the app via the launcher icon (not the notification tap) can still
/// see what happened.
///
/// All items are sourced from [ScamCheckProvider.historyItems] filtered to
/// the "native-" id prefix that screened-call rows use.
class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  static const _seenAtKey = 'notifications_last_seen_at_v1';

  /// Read the timestamp the user last opened this screen. Used by the bell
  /// badge on the home dashboard to compute the unread count.
  static Future<DateTime?> readLastSeenAt() async {
    final prefs = await SharedPreferences.getInstance();
    final ts = prefs.getInt(_seenAtKey);
    return ts == null ? null : DateTime.fromMillisecondsSinceEpoch(ts);
  }

  static Future<void> markAllSeen() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_seenAtKey, DateTime.now().millisecondsSinceEpoch);
  }

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
    // Mark all current items as seen — clears the bell badge on the home tab.
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await NotificationsScreen.markAllSeen();
    });
  }

  @override
  Widget build(BuildContext context) {
    final history = context.watch<ScamCheckProvider>().historyItems;
    final items = history
        .where((e) => e.id.startsWith('native-'))
        .toList(growable: false);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Thông báo'),
      ),
      body: items.isEmpty
          ? const _EmptyState()
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: items.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (_, i) => _NotificationCard(item: items[i]),
            ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  const _NotificationCard({required this.item});
  final ScamCheckResult item;

  @override
  Widget build(BuildContext context) {
    final df = DateFormat('dd/MM/yyyy HH:mm');
    final isScam = item.riskLevel == RiskLevel.scam;
    final accent = item.riskLevel.color;
    final action = isScam ? 'Đã chặn cuộc gọi' : 'Cuộc gọi nghi ngờ';
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => ResultScreen(result: item)),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  isScam ? Icons.block : Icons.warning_amber_rounded,
                  color: accent,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            action,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context)
                                .textTheme
                                .titleSmall
                                ?.copyWith(
                                  color: accent,
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        RiskBadge(level: item.riskLevel, score: item.riskScore),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.input,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                    if (item.summary.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        item.summary,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                      ),
                    ],
                    const SizedBox(height: 6),
                    Text(
                      df.format(item.checkedAt),
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: AppColors.textTertiary,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.notifications_off_outlined,
                size: 56, color: AppColors.textTertiary),
            const SizedBox(height: 12),
            Text(
              'Chưa có cuộc gọi nào được CallScreening xử lý.\nKhi có số trong danh sách lừa đảo gọi tới, bạn sẽ thấy ở đây.',
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
}
