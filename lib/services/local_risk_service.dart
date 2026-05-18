import 'dart:convert';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/constants/api_config.dart';
import '../data/models/risk_level.dart';
import '../data/models/scam_check_result.dart';

/// Lookup against the centralized scam blocklist stored in Supabase
/// (`public.known_risks`). The class name is kept for backwards compatibility
/// with the rest of the app — "local" now refers to the on-device cache, not
/// to a bundled JSON file.
///
/// Strategy:
///   1. On first lookup, fetch the full table from Supabase and write it to a
///      SharedPreferences cache (TTL 24h).
///   2. Subsequent lookups read from the in-memory cache. Refresh on TTL or
///      force via [refresh].
///   3. If Supabase is offline / not configured, fall back to the most recent
///      cached snapshot. If there is no cache, lookups return null.
class LocalRiskService {
  LocalRiskService();

  static const _cacheKey = 'known_risks_cache_v1';
  static const _cacheTimeKey = 'known_risks_cache_time_v1';
  static const _table = 'known_risks';
  static const _cacheTtl = Duration(hours: 24);

  bool _loaded = false;
  final Map<String, _Entry> _byKey = {};
  final List<_Entry> _all = [];
  DateTime? _lastSyncedAt;

  SupabaseClient? get _client =>
      ApiConfig.hasSupabase ? Supabase.instance.client : null;

  DateTime? get lastSyncedAt => _lastSyncedAt;

  /// Make sure the in-memory cache is populated. Will fetch from Supabase if
  /// the cached snapshot is missing or stale.
  Future<void> ensureLoaded({bool forceRefresh = false}) async {
    if (_loaded && !forceRefresh) return;

    if (!forceRefresh) {
      // Hydrate from local snapshot first so we don't block UI on the network.
      await _loadFromCache();
    }

    final stale = forceRefresh ||
        _lastSyncedAt == null ||
        DateTime.now().difference(_lastSyncedAt!) > _cacheTtl;
    if (stale) {
      final fetched = await _fetchFromSupabase();
      if (fetched != null) {
        _replaceAll(fetched);
        await _writeCache(fetched);
        _lastSyncedAt = DateTime.now();
        await _writeCacheTime(_lastSyncedAt!);
      }
    }
    _loaded = true;
  }

  /// Wipe the local cached snapshot of the centralized blocklist. The next
  /// lookup will re-fetch from Supabase. Used by the "Reset toàn bộ dữ liệu"
  /// flow.
  Future<void> clearCache() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_cacheKey);
    await prefs.remove(_cacheTimeKey);
    _byKey.clear();
    _all.clear();
    _lastSyncedAt = null;
    _loaded = false;
  }

  /// Force a refresh from Supabase. Returns the new snapshot count, or null
  /// if Supabase is unreachable / not configured. The reason for failure (if
  /// any) is exposed via [lastRefreshError] so the UI can show a useful
  /// message instead of a generic 'connection failed'.
  String? lastRefreshError;
  Future<int?> refresh() async {
    lastRefreshError = null;
    if (_client == null) {
      lastRefreshError = 'Supabase chưa được cấu hình trong .env.';
      return null;
    }
    final fetched = await _fetchFromSupabase();
    if (fetched == null) {
      // Error already populated by _fetchFromSupabase.
      return null;
    }
    _replaceAll(fetched);
    await _writeCache(fetched);
    _lastSyncedAt = DateTime.now();
    await _writeCacheTime(_lastSyncedAt!);
    _loaded = true;
    return fetched.length;
  }

  /// Returns a [ScamCheckResult] if the input is in the blocklist, else null.
  Future<ScamCheckResult?> lookup({
    required CheckTarget target,
    required String input,
    required String resultId,
  }) async {
    if (target == CheckTarget.content) return null;
    await ensureLoaded();
    final entry = _byKey[_makeKey(target, _normalize(target, input))];
    if (entry == null) return null;
    final firstReason = entry.reasons.isEmpty
        ? '(Tra cứu cộng đồng) Đối tượng có trong cơ sở dữ liệu lừa đảo.'
        : '(Tra cứu cộng đồng) ${entry.reasons.first}';
    return ScamCheckResult(
      id: resultId,
      target: target,
      input: input,
      riskLevel: entry.riskLevel,
      riskScore: entry.score,
      summary: entry.summary,
      reasons: [firstReason, ...entry.reasons.skip(1)],
      psychological: entry.psychological,
      linguisticSignals: entry.linguisticSignals,
      cyberSignals: entry.cyberSignals,
      socialTactics: entry.socialTactics,
      checkedAt: DateTime.now(),
    );
  }

  /// All known phone numbers (normalized) at a given risk level. Used to seed
  /// the native CallScreeningService blocklist.
  Future<List<String>> phoneNumbersAt(RiskLevel level) async {
    await ensureLoaded();
    return _all
        .where((e) => e.target == CheckTarget.phone && e.riskLevel == level)
        .map((e) => e.value)
        .toList(growable: false);
  }

  /// All entries for a given target type (phone / bankAccount / url), sorted
  /// by risk level (scam → suspicious → safe → unknown) then descending score.
  /// Used by the "Cơ sở dữ liệu lừa đảo" browser screen.
  Future<List<KnownRisk>> listByType(CheckTarget target) async {
    await ensureLoaded();
    final filtered = _all.where((e) => e.target == target).toList();
    int rank(RiskLevel l) => switch (l) {
          RiskLevel.scam => 0,
          RiskLevel.suspicious => 1,
          RiskLevel.safe => 2,
          RiskLevel.unknown => 3,
        };
    filtered.sort((a, b) {
      final c = rank(a.riskLevel).compareTo(rank(b.riskLevel));
      return c != 0 ? c : b.score.compareTo(a.score);
    });
    return filtered.map((e) => e.toPublic()).toList();
  }

  Future<int> totalCount() async {
    await ensureLoaded();
    return _all.length;
  }

  /// Insert (or upsert) a new entry into Supabase. Returns true on success.
  /// On success, the local cache is invalidated so the next list/lookup re-
  /// fetches the row.
  Future<bool> upsertEntry({
    required CheckTarget target,
    required String value,
    required RiskLevel riskLevel,
    required int score,
    required String summary,
    List<String> reasons = const [],
    PsychologicalFactors? psychological,
    List<String> linguistic = const [],
    List<String> cyber = const [],
    List<String> social = const [],
  }) async {
    final client = _client;
    if (client == null) {
      lastRefreshError = 'Supabase chưa được cấu hình.';
      return false;
    }
    try {
      await client.from(_table).upsert(
        {
          'type': target.name,
          'value': value,
          'normalized_value': _normalize(target, value),
          'risk_level': riskLevel.name,
          'score': score,
          'summary': summary,
          'reasons': reasons,
          'psychological': (psychological ?? const PsychologicalFactors()).toJson(),
          'linguistic_signals': linguistic,
          'cyber_signals': cyber,
          'social_tactics': social,
        },
        onConflict: 'type,normalized_value',
      );
      await refresh();
      return true;
    } on PostgrestException catch (e) {
      lastRefreshError = 'Supabase: ${e.code} — ${e.message}';
      return false;
    } catch (e) {
      lastRefreshError = 'Lỗi: $e';
      return false;
    }
  }

  /// Delete an entry from Supabase by (type, value). Returns true on success.
  Future<bool> deleteEntry({
    required CheckTarget target,
    required String value,
  }) async {
    final client = _client;
    if (client == null) {
      lastRefreshError = 'Supabase chưa được cấu hình.';
      return false;
    }
    try {
      await client
          .from(_table)
          .delete()
          .eq('type', target.name)
          .eq('normalized_value', _normalize(target, value));
      await refresh();
      return true;
    } on PostgrestException catch (e) {
      lastRefreshError = 'Supabase: ${e.code} — ${e.message}';
      return false;
    } catch (e) {
      lastRefreshError = 'Lỗi: $e';
      return false;
    }
  }

  void _replaceAll(List<_Entry> entries) {
    _byKey.clear();
    _all
      ..clear()
      ..addAll(entries);
    for (final e in entries) {
      _byKey[_makeKey(e.target, e.value)] = e;
    }
  }

  Future<void> _loadFromCache() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_cacheKey);
    final ts = prefs.getInt(_cacheTimeKey);
    if (raw == null || raw.isEmpty) return;
    try {
      final decoded = jsonDecode(raw) as List;
      final entries = decoded
          .cast<Map<String, dynamic>>()
          .map(_Entry.fromCacheJson)
          .toList();
      _replaceAll(entries);
      if (ts != null) {
        _lastSyncedAt = DateTime.fromMillisecondsSinceEpoch(ts);
      }
    } catch (_) {
      // Cache corrupt — ignore, will refetch.
    }
  }

  Future<void> _writeCache(List<_Entry> entries) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(entries.map((e) => e.toCacheJson()).toList());
    await prefs.setString(_cacheKey, encoded);
  }

  Future<void> _writeCacheTime(DateTime t) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_cacheTimeKey, t.millisecondsSinceEpoch);
  }

  Future<List<_Entry>?> _fetchFromSupabase() async {
    final client = _client;
    if (client == null) {
      lastRefreshError = 'Supabase chưa được cấu hình trong .env.';
      return null;
    }
    try {
      final rows = await client
          .from(_table)
          .select(
            'type, value, normalized_value, risk_level, score, summary, '
            'reasons, psychological, linguistic_signals, cyber_signals, social_tactics, updated_at',
          )
          .order('risk_level')
          .limit(5000);
      return (rows as List)
          .cast<Map<String, dynamic>>()
          .map(_Entry.fromSupabaseRow)
          .toList();
    } on PostgrestException catch (e, stack) {
      // Most common: PGRST205 — table doesn't exist (migration not run).
      if (e.code == 'PGRST205' || (e.message).contains('known_risks')) {
        lastRefreshError =
            'Bảng `known_risks` chưa tồn tại trên Supabase. Cần chạy migration 0005_known_risks.sql trong SQL Editor.';
      } else {
        lastRefreshError = 'Supabase trả về lỗi: ${e.code} — ${e.message}';
      }
      await Sentry.captureException(e, stackTrace: stack, withScope: (s) {
        s.setTag('service', 'supabase');
        s.setContexts('supabase', {'op': 'select_known_risks', 'code': e.code});
      });
      return null;
    } catch (e, stack) {
      lastRefreshError = 'Lỗi kết nối: $e';
      await Sentry.captureException(e, stackTrace: stack, withScope: (s) {
        s.setTag('service', 'supabase');
      });
      return null;
    }
  }

  String _makeKey(CheckTarget target, String value) =>
      '${target.name}::${value.toLowerCase()}';

  /// Public for tests. Strips formatting from phone/account numbers and
  /// extracts the host from URLs so that input variants match.
  static String normalize(CheckTarget target, String input) =>
      _normalize(target, input);

  static String _normalize(CheckTarget target, String input) {
    final trimmed = input.trim();
    switch (target) {
      case CheckTarget.phone:
        // Strip all non-digits, then canonicalize to Vietnamese domestic form
        // (leading 0) used as the single source of truth in known_risks:
        //   +84 XX…  →  0XX…  (11 digits: 84 + 9-digit subscriber → 0 + 9)
        //   +84 0XX… →  0XX…  (12 digits: 84 + extra 0 + 9-digit subscriber)
        var digits = trimmed.replaceAll(RegExp(r'\D'), '');
        if (digits.startsWith('84') && digits.length == 11) {
          digits = '0${digits.substring(2)}';
        } else if (digits.startsWith('840') && digits.length == 12) {
          digits = '0${digits.substring(3)}';
        }
        return digits;
      case CheckTarget.bankAccount:
        return trimmed.replaceAll(RegExp(r'[\s\-()]'), '');
      case CheckTarget.url:
        var u = trimmed.toLowerCase();
        u = u.replaceFirst(RegExp(r'^https?://'), '');
        u = u.replaceFirst(RegExp(r'^www\.'), '');
        u = u.split('/').first;
        return u;
      case CheckTarget.content:
        return trimmed.toLowerCase().replaceAll(RegExp(r'\s+'), ' ');
    }
  }
}

/// Public-facing snapshot of one row in the blocklist for the browser UI.
class KnownRisk {
  KnownRisk({
    required this.target,
    required this.value,
    required this.riskLevel,
    required this.score,
    required this.summary,
    required this.reasons,
    required this.psychological,
    required this.linguisticSignals,
    required this.cyberSignals,
    required this.socialTactics,
  });

  final CheckTarget target;
  final String value;
  final RiskLevel riskLevel;
  final int score;
  final String summary;
  final List<String> reasons;
  final PsychologicalFactors psychological;
  final List<String> linguisticSignals;
  final List<String> cyberSignals;
  final List<String> socialTactics;

  /// Build a [ScamCheckResult] view of this row so the existing ResultScreen
  /// can render it without changes.
  ScamCheckResult toResult({String? id}) => ScamCheckResult(
        id: id ?? 'known-${target.name}-$value',
        target: target,
        input: value,
        riskLevel: riskLevel,
        riskScore: score,
        summary: summary,
        reasons: reasons,
        psychological: psychological,
        linguisticSignals: linguisticSignals,
        cyberSignals: cyberSignals,
        socialTactics: socialTactics,
        checkedAt: DateTime.now(),
      );
}

class _Entry {
  final CheckTarget target;
  final String value; // already normalized
  final String displayValue; // raw value as provided
  final RiskLevel riskLevel;
  final int score;
  final String summary;
  final List<String> reasons;
  final PsychologicalFactors psychological;
  final List<String> linguisticSignals;
  final List<String> cyberSignals;
  final List<String> socialTactics;

  _Entry({
    required this.target,
    required this.value,
    required this.displayValue,
    required this.riskLevel,
    required this.score,
    required this.summary,
    required this.reasons,
    required this.psychological,
    this.linguisticSignals = const [],
    this.cyberSignals = const [],
    this.socialTactics = const [],
  });

  factory _Entry.fromSupabaseRow(Map<String, dynamic> row) {
    final typeStr = row['type'] as String? ?? 'phone';
    final target = CheckTarget.values.firstWhere(
      (e) => e.name == typeStr,
      orElse: () => CheckTarget.phone,
    );
    List<String> readList(dynamic raw) {
      if (raw is List) return raw.map((e) => e.toString()).toList();
      return const [];
    }

    final rawValue = row['value'] as String? ?? '';
    final normalized = (row['normalized_value'] as String?) ??
        LocalRiskService._normalize(target, rawValue);
    return _Entry(
      target: target,
      value: normalized,
      displayValue: rawValue,
      riskLevel: RiskLevel.fromString(row['risk_level'] as String?),
      score: (row['score'] as num?)?.toInt() ?? 0,
      summary: row['summary'] as String? ?? '',
      reasons: readList(row['reasons']),
      psychological: PsychologicalFactors.fromJson(
        (row['psychological'] as Map?)?.cast<String, dynamic>() ?? const {},
      ),
      linguisticSignals: readList(row['linguistic_signals']),
      cyberSignals: readList(row['cyber_signals']),
      socialTactics: readList(row['social_tactics']),
    );
  }

  Map<String, dynamic> toCacheJson() => {
        'type': target.name,
        'value': value,
        'displayValue': displayValue,
        'riskLevel': riskLevel.name,
        'score': score,
        'summary': summary,
        'reasons': reasons,
        'psychological': psychological.toJson(),
        'linguisticSignals': linguisticSignals,
        'cyberSignals': cyberSignals,
        'socialTactics': socialTactics,
      };

  factory _Entry.fromCacheJson(Map<String, dynamic> json) {
    final typeStr = json['type'] as String? ?? 'phone';
    final target = CheckTarget.values.firstWhere(
      (e) => e.name == typeStr,
      orElse: () => CheckTarget.phone,
    );
    List<String> readList(String key) =>
        (json[key] as List?)?.cast<String>() ?? const [];
    return _Entry(
      target: target,
      value: json['value'] as String? ?? '',
      displayValue: json['displayValue'] as String? ?? json['value'] as String? ?? '',
      riskLevel: RiskLevel.fromString(json['riskLevel'] as String?),
      score: (json['score'] as num?)?.toInt() ?? 0,
      summary: json['summary'] as String? ?? '',
      reasons: readList('reasons'),
      psychological: PsychologicalFactors.fromJson(
        (json['psychological'] as Map?)?.cast<String, dynamic>() ?? const {},
      ),
      linguisticSignals: readList('linguisticSignals'),
      cyberSignals: readList('cyberSignals'),
      socialTactics: readList('socialTactics'),
    );
  }

  KnownRisk toPublic() => KnownRisk(
        target: target,
        value: displayValue.isNotEmpty ? displayValue : value,
        riskLevel: riskLevel,
        score: score,
        summary: summary,
        reasons: reasons,
        psychological: psychological,
        linguisticSignals: linguisticSignals,
        cyberSignals: cyberSignals,
        socialTactics: socialTactics,
      );
}
