import 'package:shared_preferences/shared_preferences.dart';
import 'call_screening_service.dart';
import 'device_id_service.dart';
import 'history_service.dart';
import 'local_risk_service.dart';

/// One-shot wipe of everything the app stores on the device.
///
/// Order matters: native blocklist + Dart caches before remote rows so the UI
/// reaches an obviously-empty state quickly even if Supabase calls fail.
class DataResetService {
  DataResetService({
    HistoryService? history,
    LocalRiskService? localRisk,
    CallScreeningService? callScreening,
    DeviceIdService? deviceId,
  })  : _history = history ?? HistoryService(),
        _localRisk = localRisk ?? LocalRiskService(),
        _callScreening = callScreening ?? CallScreeningService(),
        _deviceId = deviceId ?? DeviceIdService();

  final HistoryService _history;
  final LocalRiskService _localRisk;
  final CallScreeningService _callScreening;
  final DeviceIdService _deviceId;

  /// Reset every piece of local state — SharedPreferences, native blocklist,
  /// cached known-risks snapshot, history cache, notification-seen marker,
  /// device id. If [includeRemote] is true, also delete the Supabase
  /// `scam_checks` rows attributed to the current device id (history sync
  /// across devices is wiped as well).
  Future<void> resetAll({bool includeRemote = true}) async {
    // 1. Native side — clears scam_numbers / suspicious_numbers / event queue.
    await _callScreening.clearAllNativeData();
    // 2. Local cached centralized blocklist snapshot.
    await _localRisk.clearCache();
    // 3. History (local cache + optionally remote).
    if (includeRemote) {
      await _history.clear();
    } else {
      await _clearLocalHistoryOnly();
    }
    // 4. Remaining ad-hoc keys.
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('notifications_last_seen_at_v1');
    // 5. Drop the device id last so any deletes above still target the
    //    current device's rows.
    await _deviceId.reset();
  }

  Future<void> _clearLocalHistoryOnly() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('scam_check_history_v1');
  }
}
