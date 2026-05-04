import 'dart:convert';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../core/constants/api_config.dart';
import '../data/models/scam_check_result.dart';
import '../data/models/risk_level.dart';

/// Wraps Gemini Flash for **on-demand** behavioural analysis.
///
/// The prompt asks the model to combine three lenses:
///
///   1. **Linguistics** (`linguistic`)   — language red flags
///   2. **Cybersecurity** (`cybersecurity`) — technical / infrastructure cues
///   3. **Social psychology** (`socialTactics`) — Cialdini-style persuasion
///
/// The classic `psychological` axes (urgency / fear / authority / greed) are
/// kept as numeric for the radar chart.
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
      CheckTarget.content => 'nội dung tin nhắn / mô tả tình huống',
    };
    final inputBlock = target == CheckTarget.content
        ? '''
Nội dung cần phân tích (có thể là tin nhắn nạn nhân nhận được, mô tả cuộc gọi
đáng ngờ, hoặc kịch bản tình huống):

"""
$input
"""'''
        : 'Đối tượng cần đánh giá: "$input"  (loại: ${target.name} — $targetVi)';

    return '''
Bạn là **chuyên gia phòng chống lừa đảo Việt Nam** kết hợp 3 chuyên môn:
ngôn ngữ học (linguistics), an ninh mạng (cybersecurity) và tâm lý học xã hội
(social psychology, Cialdini & Hofstede).

$inputBlock

Hãy phân tích **đa góc nhìn** và trả về JSON THUẦN (không markdown, không text thừa)
theo schema dưới đây. Mỗi danh sách signal nên có 1–4 mục, ngắn (≤25 từ),
cụ thể, dễ hiểu cho người dùng phổ thông Việt Nam.

### 1. Ngôn ngữ học (`linguistic`)
Dấu hiệu trong cách diễn đạt / ngôn ngữ: từ khoá hối thúc, kịch bản lặp,
mạo danh ngân hàng/cơ quan trong tên hiển thị, lỗi chính tả/ngữ pháp lạ,
giọng điệu hù doạ vs. dụ dỗ, dùng tiếng nước ngoài bất thường.

### 2. An ninh mạng (`cybersecurity`)
Dấu hiệu kỹ thuật: cấu trúc tên miền (typo-squatting, TLD lạ như .xyz/.tk),
HTTPS giả, redirect, dải đầu số đã từng lừa đảo, mẫu IBAN mở dưới tên giả,
chứng chỉ SSL, brand impersonation.

### 3. Tâm lý xã hội (`socialTactics`)
Áp dụng 6 nguyên tắc thuyết phục Cialdini (Reciprocity / Commitment /
Social Proof / Authority / Liking / Scarcity) và các cơ chế thao túng cảm xúc
phổ biến. Liệt kê thủ thuật cụ thể đối tượng đang dùng (vd. "giả danh công an
tạo authority", "deadline 5 phút tạo scarcity").

### 4. Yếu tố tâm lý định lượng (`psychological`)
Vẫn cho điểm 0–100 cho 4 trục cũ: urgency, fear, authority, greed.

### 5. Tổng hợp
- `riskScore`: 0–100
- `riskLevel`: "safe" / "suspicious" / "scam"
- `summary`: 1–2 câu kết luận tiếng Việt
- `reasons`: 3–5 lý do trọng yếu (gộp được từ 3 góc nhìn trên)

JSON BẮT BUỘC (không thêm field):
{
  "riskScore": <int 0-100>,
  "riskLevel": "<safe|suspicious|scam>",
  "summary": "<1-2 câu tiếng Việt>",
  "reasons": ["<lý do 1>", "..."],
  "psychological": {
    "urgency": <0-100>,
    "fear": <0-100>,
    "authority": <0-100>,
    "greed": <0-100>
  },
  "linguistic": ["<dấu hiệu ngôn ngữ 1>", "..."],
  "cybersecurity": ["<dấu hiệu kỹ thuật 1>", "..."],
  "socialTactics": ["<thủ thuật xã hội 1>", "..."]
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

      List<String> readList(String key) =>
          (json[key] as List?)?.cast<dynamic>().map((e) => e.toString()).toList() ??
          const [];

      return ScamCheckResult(
        id: resultId,
        target: target,
        input: input,
        riskLevel: level,
        riskScore: score,
        summary: json['summary'] as String? ?? '',
        reasons: readList('reasons'),
        psychological: PsychologicalFactors.fromJson(
          (json['psychological'] as Map?)?.cast<String, dynamic>() ?? const {},
        ),
        linguisticSignals: readList('linguistic'),
        cyberSignals: readList('cybersecurity'),
        socialTactics: readList('socialTactics'),
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
