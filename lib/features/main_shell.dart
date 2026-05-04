import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_colors.dart';
import '../data/models/risk_level.dart';
import '../data/models/scam_check_result.dart';
import '../services/call_screening_service.dart';
import '../services/local_risk_service.dart';
import 'call_screening/call_screening_screen.dart';
import 'history/history_screen.dart';
import 'home/home_screen.dart';
import 'incoming_call/incoming_call_screen.dart';
import 'scam_check/scam_check_provider.dart';
import 'scam_check/scam_check_screen.dart';

/// Root scaffold with the 4-tab bottom navigation.
///
/// Layout follows the Stitch "Home Dashboard - Modern v2" design.
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> with WidgetsBindingObserver {
  int _index = 0;
  final _navKey = GlobalKey<NavigatorState>();
  final _callScreening = CallScreeningService();
  final _localRisk = LocalRiskService();

  static const _tabs = [
    HomeScreen(),
    ScamCheckScreen(target: CheckTarget.phone),
    HistoryScreen(),
    CallScreeningScreen(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _callScreening.setIncomingCallListener(_onIncomingCall);
    WidgetsBinding.instance.addPostFrameCallback((_) => _drainScreenedCalls());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _drainScreenedCalls();
    }
  }

  /// Pull any call-screening events the native side recorded while Dart wasn't
  /// listening (cold launch, app in background, user dismissed notification)
  /// into the history feed.
  Future<void> _drainScreenedCalls() async {
    final events = await _callScreening.drainScreeningEvents();
    if (events.isEmpty || !mounted) return;
    await context.read<ScamCheckProvider>().ingestScreenedCalls(events);
  }

  Future<void> _onIncomingCall(IncomingCallEvent event) async {
    final lookup = await _localRisk.lookup(
      target: CheckTarget.phone,
      input: event.number,
      resultId: 'native-${DateTime.now().millisecondsSinceEpoch}',
    );
    final result = lookup ??
        ScamCheckResult(
          id: 'native',
          target: CheckTarget.phone,
          input: event.number,
          riskLevel: event.label.toLowerCase().contains('lừa')
              ? RiskLevel.scam
              : RiskLevel.suspicious,
          riskScore: event.blocked ? 92 : 60,
          summary:
              'Cuộc gọi từ số có dấu hiệu ${event.label.toLowerCase()}. '
              'Hãy thận trọng nếu bắt máy.',
          reasons: const [
            'CallScreeningService phát hiện trùng danh sách offline.',
          ],
          psychological: const PsychologicalFactors(),
          checkedAt: DateTime.now(),
        );
    final navigator = _navKey.currentState;
    if (navigator == null) return;
    navigator.push(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => IncomingCallScreen(
          phoneNumber: event.number,
          result: result,
        ),
      ),
    );
    // Persist this call (and any others queued meanwhile) into history.
    await _drainScreenedCalls();
  }

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: _navKey,
      onGenerateRoute: (settings) => MaterialPageRoute(
        builder: (_) => Scaffold(
          body: IndexedStack(index: _index, children: _tabs),
          bottomNavigationBar: NavigationBar(
            selectedIndex: _index,
            onDestinationSelected: (i) => setState(() => _index = i),
            backgroundColor: AppColors.surface,
            indicatorColor: AppColors.primaryContainer,
            height: 68,
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.home_outlined),
                selectedIcon: Icon(Icons.home, color: AppColors.primary),
                label: 'Trang chủ',
              ),
              NavigationDestination(
                icon: Icon(Icons.search_outlined),
                selectedIcon: Icon(Icons.search, color: AppColors.primary),
                label: 'Kiểm tra',
              ),
              NavigationDestination(
                icon: Icon(Icons.history_outlined),
                selectedIcon: Icon(Icons.history, color: AppColors.primary),
                label: 'Lịch sử',
              ),
              NavigationDestination(
                icon: Icon(Icons.shield_outlined),
                selectedIcon: Icon(Icons.shield, color: AppColors.primary),
                label: 'Bảo vệ',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
