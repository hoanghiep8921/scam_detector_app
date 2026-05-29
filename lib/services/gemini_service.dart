import 'dart:convert';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import '../core/constants/api_config.dart';
import '../data/models/media_attachment.dart';
import '../data/models/scam_check_result.dart';
import '../data/models/risk_level.dart';
import '../data/models/vietnamese_bank.dart';

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
    List<MediaAttachment> attachments = const [],
    String? bankCode,
    String locale = 'vi',
  }) async {
    final model = _getModel();
    if (model == null) {
      return _stubResult(target: target, input: input, resultId: resultId);
    }

    final prompt = _buildPrompt(
      target: target,
      input: input,
      attachments: attachments,
      bankCode: bankCode,
      locale: locale,
    );

    try {
      // Multimodal request: text + image(s) + (optional) video. Gemini Flash
      // accepts up to ~20MB of inline data per request — caller must already
      // have size-checked. Falls back to plain text-only when no attachments.
      final Content content;
      if (attachments.isEmpty) {
        content = Content.text(prompt);
      } else {
        content = Content.multi([
          TextPart(prompt),
          for (final m in attachments) DataPart(m.mimeType, m.bytes),
        ]);
      }
      final response = await model.generateContent([content])
          .timeout(const Duration(seconds: 30));
      final text = response.text ?? '';
      return _parseResponse(
        target: target,
        input: input,
        resultId: resultId,
        text: text,
      );
    } catch (e, stack) {
      // Caught for graceful UX, but ALSO forward to Sentry so the error shows
      // up in the dashboard. Tag with model + attachments so we can filter.
      await Sentry.captureException(
        e,
        stackTrace: stack,
        withScope: (scope) {
          scope.setTag('service', 'gemini');
          scope.setContexts('gemini', {
            'model': ApiConfig.geminiModel,
            'target': target.name,
            'attachments': attachments.length,
            'images': attachments
                .where((a) => a.kind == MediaKind.image)
                .length,
            'videos': attachments
                .where((a) => a.kind == MediaKind.video)
                .length,
          });
        },
      );
      final pretty = _humanizeGeminiError(e, locale: locale);
      return ScamCheckResult(
        id: resultId,
        target: target,
        input: input,
        riskLevel: RiskLevel.unknown,
        riskScore: 0,
        summary: pretty.summary,
        reasons: pretty.reasons,
        psychological: const PsychologicalFactors(),
        checkedAt: DateTime.now(),
      );
    }
  }

  /// Convert raw Gemini error into a user-friendly message.
  ({String summary, List<String> reasons}) _humanizeGeminiError(Object e, {String locale = 'vi'}) {
    final msg = e.toString().toLowerCase();
    final isEn = locale == 'en';
    if (msg.contains('unsupporteduserlocation') ||
        msg.contains('user location') ||
        msg.contains('not supported')) {
      return (
        summary: isEn
            ? 'Your network is blocked by Google from accessing Gemini (common with some mobile carriers, VPN, or Private DNS). Switch to WiFi and try again.'
            : 'Mạng hiện tại của thiết bị đang bị Google chặn truy cập Gemini '
              '(thường gặp khi dùng 4G/5G của một số nhà mạng VN, VPN, hoặc '
              'Private DNS). Hãy chuyển sang WiFi và thử lại.',
        reasons: [
          '${isEn ? "Error" : "Lỗi"}: ${e.toString()}',
          isEn ? 'Fix 1: Switch to WiFi.' : 'Cách 1: Đổi WiFi (cùng mạng với máy chạy được là chắc).',
          isEn ? 'Fix 2: Disable VPN / Private DNS.' : 'Cách 2: Tắt VPN / Private DNS trong Settings → Network.',
          isEn ? 'Fix 3: Change DNS to 8.8.8.8 or 1.1.1.1.' : 'Cách 3: Đổi DNS WiFi sang 8.8.8.8 hoặc 1.1.1.1.',
        ],
      );
    }
    if (msg.contains('quota') || msg.contains('rate limit')) {
      return (
        summary: isEn ? 'Gemini quota exceeded. Wait 1 minute and try again.' : 'Vượt quota Gemini. Đợi 1 phút rồi thử lại.',
        reasons: ['${isEn ? "Error" : "Lỗi"}: ${e.toString()}'],
      );
    }
    if (msg.contains('safety') || msg.contains('blocked')) {
      return (
        summary: isEn ? 'Gemini refused to analyze due to safety filters. Try a milder description.' : 'Gemini từ chối phân tích vì bộ lọc an toàn. Thử mô tả nhẹ hơn.',
        reasons: ['${isEn ? "Error" : "Lỗi"}: ${e.toString()}'],
      );
    }
    return (
      summary: isEn ? 'Cannot connect to AI. Please try again.' : 'Không thể kết nối đến AI. Vui lòng thử lại.',
      reasons: ['${isEn ? "Error" : "Lỗi"}: ${e.toString()}'],
    );
  }

  String _buildPrompt({
    required CheckTarget target,
    required String input,
    List<MediaAttachment> attachments = const [],
    String? bankCode,
    String locale = 'vi',
  }) {
    if (locale == 'en') {
      return _buildPromptEn(target: target, input: input, attachments: attachments, bankCode: bankCode);
    }
    final targetVi = switch (target) {
      CheckTarget.phone => 'số điện thoại',
      CheckTarget.bankAccount => 'số tài khoản ngân hàng',
      CheckTarget.url => 'đường dẫn website',
      CheckTarget.content => 'nội dung tin nhắn / mô tả tình huống',
    };

    // Bank context for the AI prompt.
    final bankContext = (target == CheckTarget.bankAccount && bankCode != null)
        ? _bankContextFor(bankCode)
        : '';

    final hasMedia = attachments.isNotEmpty;
    final imgCount = attachments.where((a) => a.kind == MediaKind.image).length;
    final vidCount = attachments.where((a) => a.kind == MediaKind.video).length;
    final mediaBlock = hasMedia
        ? '''

Người dùng đính kèm:
${imgCount > 0 ? '- $imgCount ảnh (chụp màn hình tin nhắn / cuộc gọi / website / video call).' : ''}
${vidCount > 0 ? '- $vidCount video (record màn hình hội thoại / quảng cáo / cuộc gọi).' : ''}

Hãy đọc nội dung văn bản trong ảnh (OCR), giao diện thương hiệu, kịch bản trong
video, ngôn ngữ cơ thể nếu có. Phân tích cùng với phần text user gửi (nếu có).
Nếu phát hiện logo / tên ngân hàng / số tài khoản / URL trong ảnh, trích ra
trong `reasons`.'''
        : '';

    final inputBlock = target == CheckTarget.content
        ? (input.isEmpty
            ? 'Người dùng KHÔNG cung cấp text — phân tích hoàn toàn từ media đính kèm.'
            : '''
Nội dung text user cung cấp:

"""
$input
"""''') + mediaBlock
        : 'Đối tượng cần đánh giá: "$input"  (loại: ${target.name} — $targetVi)$bankContext';

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

  String _buildPromptEn({
    required CheckTarget target,
    required String input,
    List<MediaAttachment> attachments = const [],
    String? bankCode,
  }) {
    final targetEn = switch (target) {
      CheckTarget.phone => 'phone number',
      CheckTarget.bankAccount => 'bank account number',
      CheckTarget.url => 'website URL',
      CheckTarget.content => 'message content / situation description',
    };

    final bankContext = (target == CheckTarget.bankAccount && bankCode != null)
        ? _bankContextFor(bankCode)
        : '';

    final hasMedia = attachments.isNotEmpty;
    final imgCount = attachments.where((a) => a.kind == MediaKind.image).length;
    final vidCount = attachments.where((a) => a.kind == MediaKind.video).length;
    final mediaBlock = hasMedia
        ? '''

User attached:
${imgCount > 0 ? '- $imgCount image(s) (screenshots of messages / calls / websites / video calls).' : ''}
${vidCount > 0 ? '- $vidCount video(s) (screen recordings of conversations / ads / calls).' : ''}

Read text content in images (OCR), brand interfaces, scripts in video,
body language if visible. Analyze together with user's text (if any).
If you detect logos / bank names / account numbers / URLs in images, extract them in `reasons`.'''
        : '';

    final inputBlock = target == CheckTarget.content
        ? (input.isEmpty
            ? 'User provided NO text — analyze entirely from attached media.'
            : '''
User-provided text content:

"""
$input
"""''') + mediaBlock
        : 'Target to evaluate: "$input"  (type: ${target.name} — $targetEn)$bankContext';

    return '''
You are a **Vietnamese fraud prevention expert** combining 3 specializations:
linguistics, cybersecurity, and social psychology (Cialdini & Hofstede).

$inputBlock

Analyze from **multiple angles** and return PURE JSON (no markdown, no extra text)
following the schema below. Each signal list should have 1–4 items, concise (≤25 words),
specific, easy to understand for general users.

### 1. Linguistics (`linguistic`)
Language red flags: urgency keywords, repeated scripts, bank/authority impersonation
in display names, unusual spelling/grammar errors, threatening vs. enticing tone.

### 2. Cybersecurity (`cybersecurity`)
Technical signals: domain structure (typo-squatting, unusual TLDs like .xyz/.tk),
fake HTTPS, redirects, known scam phone number ranges, mule accounts, SSL certs, brand impersonation.

### 3. Social tactics (`socialTactics`)
Apply Cialdini's 6 principles (Reciprocity / Commitment / Social Proof / Authority /
Liking / Scarcity) and common emotional manipulation mechanisms.
List specific tactics being used.

### 4. Quantified psychological factors (`psychological`)
Score 0–100 for 4 axes: urgency, fear, authority, greed.

### 5. Summary
- `riskScore`: 0–100
- `riskLevel`: "safe" / "suspicious" / "scam"
- `summary`: 1–2 sentence conclusion in English
- `reasons`: 3–5 key reasons (combined from the 3 angles above)

REQUIRED JSON (no extra fields):
{
  "riskScore": <int 0-100>,
  "riskLevel": "<safe|suspicious|scam>",
  "summary": "<1-2 sentences in English>",
  "reasons": ["<reason 1>", "..."],
  "psychological": {
    "urgency": <0-100>,
    "fear": <0-100>,
    "authority": <0-100>,
    "greed": <0-100>
  },
  "linguistic": ["<language signal 1>", "..."],
  "cybersecurity": ["<technical signal 1>", "..."],
  "socialTactics": ["<social tactic 1>", "..."]
}
''';
  }

  String _bankContextFor(String bankCode) {
    final bank = VietnameseBank.fromCode(bankCode);
    final range = bank.minDigits == bank.maxDigits
        ? '${bank.minDigits} chữ số'
        : '${bank.minDigits}–${bank.maxDigits} chữ số';
    var ctx = '\n\nLưu ý: Số tài khoản thuộc ${bank.name} (${bank.shortName}), '
        'thường có $range.';
    if (bankCode == 'MB' || bankCode == 'TPB') {
      ctx += ' Ngân hàng này cho phép dùng số điện thoại làm số tài khoản.';
    }
    return ctx;
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
