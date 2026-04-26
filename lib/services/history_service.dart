import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/models/scam_check_result.dart';

/// Persists scam check history in SharedPreferences as a JSON list.
class HistoryService {
  static const _key = 'scam_check_history_v1';
  static const _maxItems = 100;

  Future<List<ScamCheckResult>> load() async {
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

  Future<void> add(ScamCheckResult result) async {
    final prefs = await SharedPreferences.getInstance();
    final existing = await load();
    existing.insert(0, result);
    if (existing.length > _maxItems) {
      existing.removeRange(_maxItems, existing.length);
    }
    final encoded = jsonEncode(existing.map((e) => e.toJson()).toList());
    await prefs.setString(_key, encoded);
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
