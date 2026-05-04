import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/constants/api_config.dart';
import '../data/models/risk_level.dart';
import '../data/models/scam_check_result.dart';
import 'device_id_service.dart';
import 'local_risk_service.dart';

/// Hybrid history store:
///   * Writes go to Supabase (`scam_checks`) AND a local SharedPreferences cache.
///   * Reads prefer Supabase; fall back to local cache when offline / unconfigured.
///
/// Local cache holds last [_maxItems] rows so the UI is instant on cold start.
class HistoryService {
  HistoryService({DeviceIdService? deviceId})
      : _deviceId = deviceId ?? DeviceIdService();

  static const _key = 'scam_check_history_v1';
  static const _maxItems = 100;
  static const _table = 'scam_checks';

  final DeviceIdService _deviceId;

  SupabaseClient? get _client => ApiConfig.hasSupabase ? Supabase.instance.client : null;

  Future<List<ScamCheckResult>> load() async {
    final remote = await _loadRemote();
    if (remote != null) {
      // Refresh local cache so cold launches w/o network still work.
      await _writeLocalCache(remote);
      return remote;
    }
    return _loadLocal();
  }

  Future<void> add(ScamCheckResult result) async {
    await _addLocal(result);
    await _addRemote(result);
  }

  Future<void> clear() async {
    await _clearLocal();
    await _clearRemote();
  }

  // ── local cache ─────────────────────────────────────────────────────────

  Future<List<ScamCheckResult>> _loadLocal() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null || raw.isEmpty) return [];
    try {
      final decoded = jsonDecode(raw) as List;
      return decoded
          .cast<Map<String, dynamic>>()
          .map(ScamCheckResult.fromJson)
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> _writeLocalCache(List<ScamCheckResult> items) async {
    final prefs = await SharedPreferences.getInstance();
    final trimmed = items.take(_maxItems).toList();
    await prefs.setString(
      _key,
      jsonEncode(trimmed.map((e) => e.toJson()).toList()),
    );
  }

  Future<void> _addLocal(ScamCheckResult result) async {
    final existing = await _loadLocal();
    final idx = existing.indexWhere((e) => e.id == result.id);
    if (idx >= 0) {
      // Replace in place (e.g. AI re-analysis re-uses the original id).
      existing[idx] = result;
    } else {
      existing.insert(0, result);
    }
    if (existing.length > _maxItems) {
      existing.removeRange(_maxItems, existing.length);
    }
    await _writeLocalCache(existing);
  }

  Future<void> _clearLocal() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }

  // ── remote (Supabase) ───────────────────────────────────────────────────

  Future<List<ScamCheckResult>?> _loadRemote() async {
    final client = _client;
    if (client == null) return null;
    try {
      final deviceId = await _deviceId.get();
      final rows = await client
          .from(_table)
          .select()
          .eq('device_id', deviceId)
          .order('checked_at', ascending: false)
          .limit(_maxItems);
      return (rows as List)
          .cast<Map<String, dynamic>>()
          .map(_rowToResult)
          .toList();
    } catch (_) {
      return null;
    }
  }

  Future<void> _addRemote(ScamCheckResult result) async {
    final client = _client;
    if (client == null) return;
    try {
      final deviceId = await _deviceId.get();
      // Upsert so re-saving an existing id (AI re-analysis, drained native
      // event seen twice) updates the row instead of erroring on PK conflict.
      await client.from(_table).upsert(_resultToRow(result, deviceId));
    } catch (_) {
      // Swallow — local cache still has the row.
    }
  }

  Future<void> _clearRemote() async {
    final client = _client;
    if (client == null) return;
    try {
      final deviceId = await _deviceId.get();
      await client.from(_table).delete().eq('device_id', deviceId);
    } catch (_) {
      // Best-effort.
    }
  }

  Map<String, dynamic> _resultToRow(ScamCheckResult r, String deviceId) => {
        'id': r.id,
        'device_id': deviceId,
        'target': r.target.name,
        'input': r.input,
        'normalized_input': LocalRiskService.normalize(r.target, r.input),
        'risk_level': r.riskLevel.name,
        'risk_score': r.riskScore,
        'summary': r.summary,
        'reasons': r.reasons,
        'psychological': r.psychological.toJson(),
        'linguistic_signals': r.linguisticSignals,
        'cyber_signals': r.cyberSignals,
        'social_tactics': r.socialTactics,
        'checked_at': r.checkedAt.toUtc().toIso8601String(),
      };

  ScamCheckResult _rowToResult(Map<String, dynamic> row) {
    List<String> readJsonbList(String key) =>
        (row[key] as List?)?.cast<dynamic>().map((e) => e.toString()).toList() ??
        const [];
    return ScamCheckResult(
      id: row['id'] as String,
      target: CheckTarget.values.firstWhere(
        (e) => e.name == row['target'],
        orElse: () => CheckTarget.phone,
      ),
      input: row['input'] as String? ?? '',
      riskLevel: RiskLevel.fromString(row['risk_level'] as String?),
      riskScore: (row['risk_score'] as num?)?.toInt() ?? 0,
      summary: row['summary'] as String? ?? '',
      reasons: readJsonbList('reasons'),
      psychological: PsychologicalFactors.fromJson(
        (row['psychological'] as Map?)?.cast<String, dynamic>() ?? const {},
      ),
      linguisticSignals: readJsonbList('linguistic_signals'),
      cyberSignals: readJsonbList('cyber_signals'),
      socialTactics: readJsonbList('social_tactics'),
      checkedAt: DateTime.tryParse(row['checked_at'] as String? ?? '') ??
          DateTime.now(),
    );
  }
}
