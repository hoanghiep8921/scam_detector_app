import 'risk_level.dart';

enum CheckTarget { phone, bankAccount, url }

extension CheckTargetX on CheckTarget {
  String get label {
    switch (this) {
      case CheckTarget.phone:
        return 'Số điện thoại';
      case CheckTarget.bankAccount:
        return 'Tài khoản ngân hàng';
      case CheckTarget.url:
        return 'Đường dẫn';
    }
  }
}

/// Psychological factors per the AI Behavioral Analysis spec.
class PsychologicalFactors {
  final int urgency;   // 0-100 - tạo áp lực thời gian
  final int fear;      // 0-100 - đe doạ, gây sợ hãi
  final int authority; // 0-100 - giả danh tổ chức
  final int greed;     // 0-100 - hứa hẹn lợi ích lớn

  const PsychologicalFactors({
    this.urgency = 0,
    this.fear = 0,
    this.authority = 0,
    this.greed = 0,
  });

  factory PsychologicalFactors.fromJson(Map<String, dynamic> json) {
    int read(String k) => (json[k] as num?)?.round().clamp(0, 100) ?? 0;
    return PsychologicalFactors(
      urgency: read('urgency'),
      fear: read('fear'),
      authority: read('authority'),
      greed: read('greed'),
    );
  }

  Map<String, dynamic> toJson() => {
        'urgency': urgency,
        'fear': fear,
        'authority': authority,
        'greed': greed,
      };
}

/// Outcome of a scam check, regardless of target type.
class ScamCheckResult {
  final String id;
  final CheckTarget target;
  final String input;
  final RiskLevel riskLevel;
  final int riskScore;          // 0-100
  final String summary;         // 1-2 dòng tóm tắt
  final List<String> reasons;   // các lý do explainable
  final PsychologicalFactors psychological;
  final DateTime checkedAt;

  const ScamCheckResult({
    required this.id,
    required this.target,
    required this.input,
    required this.riskLevel,
    required this.riskScore,
    required this.summary,
    required this.reasons,
    required this.psychological,
    required this.checkedAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'target': target.name,
        'input': input,
        'riskLevel': riskLevel.name,
        'riskScore': riskScore,
        'summary': summary,
        'reasons': reasons,
        'psychological': psychological.toJson(),
        'checkedAt': checkedAt.toIso8601String(),
      };

  factory ScamCheckResult.fromJson(Map<String, dynamic> json) {
    return ScamCheckResult(
      id: json['id'] as String,
      target: CheckTarget.values
          .firstWhere((e) => e.name == json['target'], orElse: () => CheckTarget.phone),
      input: json['input'] as String,
      riskLevel: RiskLevel.fromString(json['riskLevel'] as String?),
      riskScore: (json['riskScore'] as num?)?.toInt() ?? 0,
      summary: json['summary'] as String? ?? '',
      reasons: (json['reasons'] as List?)?.cast<String>() ?? const [],
      psychological: PsychologicalFactors.fromJson(
        (json['psychological'] as Map?)?.cast<String, dynamic>() ?? const {},
      ),
      checkedAt: DateTime.tryParse(json['checkedAt'] as String? ?? '') ??
          DateTime.now(),
    );
  }
}
