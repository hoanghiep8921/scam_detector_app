import 'dart:convert';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../core/constants/api_config.dart';
import '../data/models/scam_check_result.dart';
import '../data/models/risk_level.dart';

/// Wraps the Gemini Flash model and produces structured ScamCheckResult.
///
/// The model is instructed to return strict JSON. We parse defensively;
/// if parsing fails we fall back to an "unknown" result with the raw text.
class GeminiService {
  GeminiService();

  GenerativeModel? _model;

  GenerativeModel? _getModel() {
    if (!ApiConfig.hasGeminiKey) return null;
    return _model ??= GenerativeModel(
      model: ApiConfig.geminiModel,
      apiKey: ApiConfig.geminiApiKey,
      generationConfig: GenerationConfig(
        temperature: 0.2,
        responseMimeType: 'application/json',
      ),
    );
  }

  /// Analyze a phone number, bank account, or URL.
  /// Returns a [ScamCheckResult]. If the API key is missing, returns a
  /// stub result so the UI flow can still be demonstrated.
  Future<ScamCheckResult> analyze({
    required CheckTarget target,
    required String input,
    required String resultId,
  }) async {
    final model = _getModel();
    if (model == null) {
      return _stubResult(target: target, input: input, resultId: resultId);
    }

    final prompt = _buildPrompt(target: target, input: input);

    try {
      final response = await model.generateContent([Content.text(prompt)]);
      final text = response.text ?? '';
      return _parseResponse(
        target: target,
        input: input,
        resultId: resultId,
        text: text,
      );
    } catch (e) {
      return ScamCheckResult(
        id: resultId,
        target: target,
        input: input,
        riskLevel: RiskLevel.unknown,
        riskScore: 0,
        summary: 'Không thể kết nối đến AI. Vui lòng thử lại.',
        reasons: ['Lỗi: ${e.toString()}'],
        psychological: const PsychologicalFactors(),
        checkedAt: DateTime.now(),
      );
    }
  }

  String _buildPrompt({required CheckTarget target, required String input}) {
    final targetVi = switch (target) {
      CheckTarget.phone => 'số điện thoại',
      CheckTarget.bankAccount => 'số tài khoản ngân hàng',
      CheckTarget.url => 'đường dẫn website',
    };

    return '''
Bạn là chuyên gia phân tích lừa đảo trực tuyến tại Việt Nam.
Hãy đánh giá $targetVi sau và trả về JSON THUẦN (không markdown, không text thừa):

Đối tượng cần kiểm tra: "$input"
Loại: ${target.name}

Phân tích các khía cạnh:
1. Mức độ rủi ro (0-100)
2. Phân loại: "safe" / "suspicious" / "scam"
3. Các yếu tố tâm lý lừa đảo (0-100 mỗi yếu tố):
   - urgency: tạo áp lực thời gian
   - fear: đe doạ, gây sợ hãi
   - authority: giả danh cơ quan/tổ chức
   - greed: hứa hẹn lợi ích lớn
4. Lý do cụ thể (3-5 gạch đầu dòng, dễ hiểu cho người dùng phổ thông)
5. Tóm tắt 1-2 câu

Định dạng JSON BẮT BUỘC:
{
  "riskScore": <int 0-100>,
  "riskLevel": "<safe|suspicious|scam>",
  "summary": "<1-2 câu tiếng Việt>",
  "reasons": ["<lý do 1>", "<lý do 2>", "..."],
  "psychological": {
    "urgency": <0-100>,
    "fear": <0-100>,
    "authority": <0-100>,
    "greed": <0-100>
  }
}
''';
  }

  ScamCheckResult _parseResponse({
    required CheckTarget target,
    required String input,
    required String resultId,
    required String text,
  }) {
    try {
      // Strip potential markdown fences just in case.
      var cleaned = text.trim();
      if (cleaned.startsWith('```')) {
        cleaned = cleaned.replaceAll(RegExp(r'^```(?:json)?\s*'), '');
        cleaned = cleaned.replaceAll(RegExp(r'\s*```\s*$'), '');
      }
      final json = jsonDecode(cleaned) as Map<String, dynamic>;

      final score = (json['riskScore'] as num?)?.toInt().clamp(0, 100) ?? 0;
      final levelStr = json['riskLevel'] as String?;
      final level = RiskLevel.fromString(levelStr) == RiskLevel.unknown
          ? RiskLevel.fromScore(score)
          : RiskLevel.fromString(levelStr);

      return ScamCheckResult(
        id: resultId,
        target: target,
        input: input,
        riskLevel: level,
        riskScore: score,
        summary: json['summary'] as String? ?? '',
        reasons: (json['reasons'] as List?)?.cast<String>() ?? const [],
        psychological: PsychologicalFactors.fromJson(
          (json['psychological'] as Map?)?.cast<String, dynamic>() ?? const {},
        ),
        checkedAt: DateTime.now(),
      );
    } catch (_) {
      return ScamCheckResult(
        id: resultId,
        target: target,
        input: input,
        riskLevel: RiskLevel.unknown,
        riskScore: 0,
        summary: 'Không phân tích được phản hồi từ AI.',
        reasons: text.isNotEmpty ? [text] : ['Phản hồi rỗng'],
        psychological: const PsychologicalFactors(),
        checkedAt: DateTime.now(),
      );
    }
  }

  /// Returned when no API key is configured. Lets the UI flow be demonstrated.
  ScamCheckResult _stubResult({
    required CheckTarget target,
    required String input,
    required String resultId,
  }) {
    return ScamCheckResult(
      id: resultId,
      target: target,
      input: input,
      riskLevel: RiskLevel.unknown,
      riskScore: 0,
      summary:
          'Chưa cấu hình GEMINI_API_KEY. Thêm vào file .env để kích hoạt phân tích AI.',
      reasons: const [
        'Chế độ demo: chưa có khoá API.',
        'Cấu hình GEMINI_API_KEY trong .env và chạy lại.',
      ],
      psychological: const PsychologicalFactors(),
      checkedAt: DateTime.now(),
    );
  }
}
