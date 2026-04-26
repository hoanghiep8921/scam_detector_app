import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../../data/models/scam_check_result.dart';
import '../../services/gemini_service.dart';
import '../../services/history_service.dart';

class ScamCheckProvider extends ChangeNotifier {
  ScamCheckProvider({
    GeminiService? gemini,
    HistoryService? history,
  })  : _gemini = gemini ?? GeminiService(),
        _history = history ?? HistoryService();

  final GeminiService _gemini;
  final HistoryService _history;
  final _uuid = const Uuid();

  bool _loading = false;
  String? _error;
  ScamCheckResult? _lastResult;
  List<ScamCheckResult> _historyItems = [];

  bool get isLoading => _loading;
  String? get error => _error;
  ScamCheckResult? get lastResult => _lastResult;
  List<ScamCheckResult> get historyItems => List.unmodifiable(_historyItems);

  Future<void> loadHistory() async {
    _historyItems = await _history.load();
    notifyListeners();
  }

  Future<ScamCheckResult?> check({
    required CheckTarget target,
    required String input,
  }) async {
    final trimmed = input.trim();
    if (trimmed.isEmpty) {
      _error = 'Vui lòng nhập thông tin cần kiểm tra.';
      notifyListeners();
      return null;
    }

    _loading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _gemini.analyze(
        target: target,
        input: trimmed,
        resultId: _uuid.v4(),
      );
      _lastResult = result;
      await _history.add(result);
      _historyItems = [result, ..._historyItems];
      return result;
    } catch (e) {
      _error = e.toString();
      return null;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> clearHistory() async {
    await _history.clear();
    _historyItems = [];
    notifyListeners();
  }
}
