import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../../data/models/risk_level.dart';
import '../../data/models/scam_check_result.dart';
import '../../services/call_screening_service.dart';
import '../../services/gemini_service.dart';
import '../../services/history_service.dart';
import '../../services/local_risk_service.dart';
import '../../services/remote_risk_service.dart';

/// Scam check flow:
///
///   1. Local lookup     → instant exact match in `known_risks.json`
///   2. Remote aggregate → consensus of community history in Supabase
///   3. Otherwise         → return an "unknown" placeholder; user can tap
///                          [analyzeWithAi] in the result screen for a
///                          deeper behavioural / psychological analysis.
///
/// Gemini is **never** auto-called from [check]. AI is on-demand only.
class ScamCheckProvider extends ChangeNotifier {
  ScamCheckProvider({
    GeminiService? gemini,
    HistoryService? history,
    LocalRiskService? localRisk,
    RemoteRiskService? remoteRisk,
  })  : _gemini = gemini ?? GeminiService(),
        _history = history ?? HistoryService(),
        _localRisk = localRisk ?? LocalRiskService(),
        _remoteRisk = remoteRisk ?? RemoteRiskService();

  final GeminiService _gemini;
  final HistoryService _history;
  final LocalRiskService _localRisk;
  final RemoteRiskService _remoteRisk;
  final _uuid = const Uuid();

  bool _loading = false;
  bool _aiLoading = false;
  String? _error;
  ScamCheckResult? _lastResult;
  List<ScamCheckResult> _historyItems = [];

  bool get isLoading => _loading;
  bool get isAiLoading => _aiLoading;
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
      final id = _uuid.v4();
      ScamCheckResult result;
      if (target == CheckTarget.content) {
        // Free-text content has no useful local / remote lookup — go straight
        // to Gemini for behavioural analysis.
        result = await _gemini.analyze(
          target: target,
          input: trimmed,
          resultId: id,
        );
      } else {
        // 1. Local known list — instant exact match.
        final local = await _localRisk.lookup(
          target: target,
          input: trimmed,
          resultId: id,
        );
        // 2. Supabase aggregate — consensus from community history.
        final remote = local == null
            ? await _remoteRisk.lookup(
                target: target,
                input: trimmed,
                resultId: id,
              )
            : null;
        // 3. Fall through — no data either side. Return placeholder; AI is opt-in.
        result = local ??
            remote ??
            ScamCheckResult(
              id: id,
              target: target,
              input: trimmed,
              riskLevel: RiskLevel.unknown,
              riskScore: 0,
              summary:
                  'Chưa có dữ liệu trên app hoặc cộng đồng. Bạn có thể yêu cầu AI phân tích sâu hơn.',
              reasons: const [
                'Không tìm thấy trong danh sách rủi ro nội bộ.',
                'Chưa ai trong cộng đồng kiểm tra số/đường dẫn này trước đây.',
                'Bấm "Phân tích sâu bằng AI" để Gemini phân tích hành vi.',
              ],
              psychological: const PsychologicalFactors(),
              checkedAt: DateTime.now(),
            );
      }
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

  /// On-demand AI behavioural analysis. Called from the result screen.
  ///
  /// Replaces the in-place [_lastResult] (and the matching row in the history
  /// list + Supabase) with a richer Gemini-derived result.
  Future<ScamCheckResult?> analyzeWithAi(ScamCheckResult original) async {
    _aiLoading = true;
    notifyListeners();
    try {
      final aiResult = await _gemini.analyze(
        target: original.target,
        input: original.input,
        resultId: original.id,
      );
      // Preserve the original id so the row in history is updated, not duplicated.
      _lastResult = aiResult;
      // Replace in history list (in-memory).
      final idx = _historyItems.indexWhere((e) => e.id == original.id);
      if (idx >= 0) {
        _historyItems = List.of(_historyItems)..[idx] = aiResult;
      } else {
        _historyItems = [aiResult, ..._historyItems];
      }
      // Persist updated row (insert; fine as the user can have multiple AI passes).
      await _history.add(aiResult);
      return aiResult;
    } catch (e) {
      _error = e.toString();
      return null;
    } finally {
      _aiLoading = false;
      notifyListeners();
    }
  }

  /// Ingest call-screening events recorded natively by the
  /// [IncomingCallScreener] into the history feed. Called on app start /
  /// resume / when an incoming-call notification fires. Dedupes by stable id
  /// so calling this multiple times with the same event is a no-op.
  Future<int> ingestScreenedCalls(List<ScreenedCallEvent> events) async {
    if (events.isEmpty) return 0;
    final existingIds = _historyItems.map((e) => e.id).toSet();
    var added = 0;
    final newItems = <ScamCheckResult>[];
    for (final e in events) {
      final result = await _buildResultForScreenedCall(e);
      if (existingIds.contains(result.id)) continue;
      existingIds.add(result.id);
      newItems.add(result);
      await _history.add(result);
      added++;
    }
    if (added > 0) {
      // Newest first — events come oldest-first from native, reverse before prepending.
      _historyItems = [...newItems.reversed, ..._historyItems];
      notifyListeners();
    }
    return added;
  }

  Future<ScamCheckResult> _buildResultForScreenedCall(ScreenedCallEvent e) async {
    final normalized = LocalRiskService.normalize(CheckTarget.phone, e.number);
    final stableId = 'native-$normalized-${e.timestamp.millisecondsSinceEpoch}';
    final lookup = await _localRisk.lookup(
      target: CheckTarget.phone,
      input: e.number,
      resultId: stableId,
    );
    if (lookup != null) {
      // Use the offline-lookup risk data, but keep the stable id + actual call time.
      return lookup.copyWith(id: stableId, checkedAt: e.timestamp);
    }
    final isScam = e.label.toLowerCase().contains('lừa');
    return ScamCheckResult(
      id: stableId,
      target: CheckTarget.phone,
      input: e.number,
      riskLevel: isScam ? RiskLevel.scam : RiskLevel.suspicious,
      riskScore: e.blocked ? 92 : 60,
      summary: e.blocked
          ? 'Cuộc gọi bị chặn tự động vì khớp danh sách lừa đảo.'
          : 'Cuộc gọi nghi ngờ — đã được cảnh báo nhưng không chặn.',
      reasons: [
        e.blocked
            ? 'CallScreeningService đã chặn cuộc gọi từ ${e.number}.'
            : 'CallScreeningService cảnh báo cuộc gọi từ ${e.number}.',
        'Số khớp danh sách offline được đồng bộ từ Scam Detector.',
      ],
      psychological: const PsychologicalFactors(),
      checkedAt: e.timestamp,
    );
  }

  Future<void> clearHistory() async {
    await _history.clear();
    _historyItems = [];
    notifyListeners();
  }
}
