import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/constants/api_config.dart';
import '../data/models/risk_level.dart';
import '../data/models/scam_check_result.dart';
import 'device_id_service.dart';
import 'local_risk_service.dart';

/// Submit & query community scam reports from Supabase.
///
/// Unlike `known_risks` (curated blocklist), `community_reports` is a raw
/// intake — any user can flag a phone/URL/account as scam. The provider
/// checks this table as a secondary signal before falling back to "unknown".
class CommunityReportService {
  CommunityReportService();

  SupabaseClient? get _client =>
      ApiConfig.hasSupabase ? Supabase.instance.client : null;
  final _deviceId = DeviceIdService();

  /// Submit a community report. Returns true on success.
  Future<bool> submit({
    required CheckTarget target,
    required String value,
    required String description,
  }) async {
    final client = _client;
    if (client == null) return false;
    try {
      final deviceId = await _deviceId.get();
      final normalized = LocalRiskService.normalize(target, value);
      await client.from('community_reports').upsert(
        {
          'device_id': deviceId,
          'target': target.name,
          'reported_value': value,
          'normalized_value': normalized,
          'description': description.trim().isEmpty ? null : description.trim(),
        },
        onConflict: 'device_id,normalized_value',
      );
      return true;
    } catch (e, st) {
      await Sentry.captureException(e, stackTrace: st, withScope: (s) {
        s.setTag('target', target.name);
        s.setExtra('value', value);
        s.setExtra('desc_length', description.length);
      });
      return false;
    }
  }

  /// Check if the input has community reports. Returns a result if found.
  Future<({ScamCheckResult result, int reportCount})?> lookup({
    required CheckTarget target,
    required String input,
    required String resultId,
  }) async {
    final client = _client;
    if (client == null) return null;
    try {
      final normalized = LocalRiskService.normalize(target, input);
      final rows = await client
          .from('community_reports')
          .select('id, reported_value, description')
          .eq('normalized_value', normalized)
          .limit(10);
      final reports = rows as List;
      if (reports.isEmpty) return null;

      final first = reports[0] as Map;
      final reportedValue = first['reported_value'] as String? ?? input;
      return (
        result: ScamCheckResult(
          id: resultId,
          target: target,
          input: input,
          riskLevel: RiskLevel.suspicious,
          riskScore: 50 + reports.length * 5, // escalate with report count
          summary: '${reports.length} người dùng đã báo cáo đối tượng này là lừa đảo.',
          reasons: [
            '(Cộng đồng báo cáo) $reportedValue đã bị ${reports.length} người báo cáo.',
            if ((first['description'] as String?)?.isNotEmpty ?? false)
              '(Mô tả) ${first['description']}',
            ...reports.skip(1).take(2).map((r) =>
                '(Báo cáo) ${(r as Map)['description'] as String? ?? 'Không có mô tả'}'),
          ],
          psychological: const PsychologicalFactors(),
          checkedAt: DateTime.now(),
        ),
        reportCount: reports.length,
      );
    } catch (_) {
      return null;
    }
  }
}
