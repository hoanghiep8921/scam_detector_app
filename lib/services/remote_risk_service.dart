import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/constants/api_config.dart';
import '../data/models/risk_level.dart';
import '../data/models/scam_check_result.dart';
import 'local_risk_service.dart';

/// Aggregates community check history (Supabase `scam_checks`) for a given
/// (target, input) so the app can give an offline-style answer without
/// burning a Gemini call.
///
/// Returns null when:
///   - Supabase isn't configured, OR
///   - No previous checks exist for this input.
class RemoteRiskService {
  RemoteRiskService();

  static const _table = 'scam_checks';
  // Don't lean on a single noisy report — wait for at least this many entries
  // before treating the consensus as meaningful.
  static const _minEntries = 1;

  SupabaseClient? get _client =>
      ApiConfig.hasSupabase ? Supabase.instance.client : null;

  Future<ScamCheckResult?> lookup({
    required CheckTarget target,
    required String input,
    required String resultId,
    String? bankCode,
  }) async {
    final client = _client;
    if (client == null) return null;
    // Free text rarely matches char-for-char across users; skip aggregate.
    if (target == CheckTarget.content) return null;
    final normalized = LocalRiskService.normalize(target, input);
    try {
      var query = client
          .from(_table)
          .select(
            'risk_level, risk_score, summary, reasons, psychological, '
            'linguistic_signals, cyber_signals, social_tactics, '
            'checked_at, device_id',
          )
          .eq('target', target.name)
          .eq('normalized_input', normalized);

      // If bankCode is provided for bank account checks, filter by it to get
      // more precise results.
      if (bankCode != null && bankCode.isNotEmpty && target == CheckTarget.bankAccount) {
        query = query.eq('bank_code', bankCode);
      }

      final rows = await query
          .order('checked_at', ascending: false)
          .limit(50);
      final list = (rows as List).cast<Map<String, dynamic>>();
      if (list.length < _minEntries) return null;
      return _aggregate(
        target: target,
        input: input,
        resultId: resultId,
        rows: list,
      );
    } catch (_) {
      return null;
    }
  }

  ScamCheckResult _aggregate({
    required CheckTarget target,
    required String input,
    required String resultId,
    required List<Map<String, dynamic>> rows,
  }) {
    // Vote by risk_level, weighted by distinct devices.
    final byLevel = <String, Set<String>>{};
    var scoreSum = 0;
    var scoreCount = 0;
    final reasons = <String>{};
    final linguistic = <String>{};
    final cyber = <String>{};
    final social = <String>{};
    var avgUrgency = 0, avgFear = 0, avgAuthority = 0, avgGreed = 0;
    var psyCount = 0;
    DateTime? latest;

    List<String> readList(Map row, String key) =>
        (row[key] as List?)?.cast<dynamic>().map((e) => e.toString()).toList() ??
        const [];

    for (final row in rows) {
      final lvl = row['risk_level'] as String? ?? 'unknown';
      final dev = row['device_id'] as String? ?? '';
      byLevel.putIfAbsent(lvl, () => {}).add(dev);
      final s = (row['risk_score'] as num?)?.toInt();
      if (s != null) {
        scoreSum += s;
        scoreCount++;
      }
      reasons.addAll(readList(row, 'reasons').take(2));
      linguistic.addAll(readList(row, 'linguistic_signals').take(2));
      cyber.addAll(readList(row, 'cyber_signals').take(2));
      social.addAll(readList(row, 'social_tactics').take(2));
      final psy = (row['psychological'] as Map?)?.cast<String, dynamic>();
      if (psy != null && psy.isNotEmpty) {
        avgUrgency += (psy['urgency'] as num?)?.toInt() ?? 0;
        avgFear += (psy['fear'] as num?)?.toInt() ?? 0;
        avgAuthority += (psy['authority'] as num?)?.toInt() ?? 0;
        avgGreed += (psy['greed'] as num?)?.toInt() ?? 0;
        psyCount++;
      }
      final t = DateTime.tryParse(row['checked_at'] as String? ?? '');
      if (t != null && (latest == null || t.isAfter(latest))) latest = t;
    }

    // Pick the risk level with the most distinct reporters.
    final consensusLevel = byLevel.entries
        .map((e) => MapEntry(e.key, e.value.length))
        .fold<MapEntry<String, int>?>(
      null,
      (best, cur) => best == null || cur.value > best.value ? cur : best,
    );
    final levelStr = consensusLevel?.key ?? 'unknown';
    final votes = consensusLevel?.value ?? 0;

    final totalDevices = byLevel.values.expand((e) => e).toSet().length;
    final score = scoreCount == 0 ? 0 : (scoreSum / scoreCount).round();

    return ScamCheckResult(
      id: resultId,
      target: target,
      input: input,
      riskLevel: RiskLevel.fromString(levelStr),
      riskScore: score,
      summary: 'Tổng hợp từ $totalDevices lượt kiểm tra cộng đồng. '
          '$votes/$totalDevices xác định là "${RiskLevel.fromString(levelStr).label.toLowerCase()}".',
      reasons: [
        '(Cơ sở dữ liệu cộng đồng) ${rows.length} báo cáo gần nhất.',
        ...reasons.take(4),
      ],
      psychological: psyCount == 0
          ? const PsychologicalFactors()
          : PsychologicalFactors(
              urgency: (avgUrgency / psyCount).round(),
              fear: (avgFear / psyCount).round(),
              authority: (avgAuthority / psyCount).round(),
              greed: (avgGreed / psyCount).round(),
            ),
      linguisticSignals: linguistic.take(5).toList(),
      cyberSignals: cyber.take(5).toList(),
      socialTactics: social.take(5).toList(),
      checkedAt: DateTime.now(),
    );
  }
}
