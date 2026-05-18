import 'risk_level.dart';

enum CheckTarget { phone, bankAccount, url, content }

extension CheckTargetX on CheckTarget {
  String get label {
    switch (this) {
      case CheckTarget.phone:
        return 'Số điện thoại';
      case CheckTarget.bankAccount:
        return 'Tài khoản ngân hàng';
      case CheckTarget.url:
        return 'Đường dẫn';
      case CheckTarget.content:
        return 'Nội dung tin nhắn';
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
///
/// AI analysis combines three lenses: linguistics, cybersecurity and social
/// psychology. Each lens contributes a list of human-readable signals.
class ScamCheckResult {
  final String id;
  final CheckTarget target;
  final String input;
  final RiskLevel riskLevel;
  final int riskScore;
  final String summary;
  final List<String> reasons;
  final PsychologicalFactors psychological;

  /// Linguistic red flags detected (e.g. urgency words, scripted phrasing,
  /// translation artifacts, brand impersonation in copy).
  final List<String> linguisticSignals;

  /// Cybersecurity red flags (e.g. suspicious TLD, typo-squatting domain,
  /// reused scam phone-number range, mismatched ASN, etc).
  final List<String> cyberSignals;

  /// Social-psychology persuasion tactics (Cialdini-style: authority,
  /// scarcity, reciprocity, commitment, social proof, liking) detected.
  final List<String> socialTactics;

  /// URL phishing highlights — maps problematic fragments to severity (0–100).
  /// e.g. {'http': 40, 'youtobe': 85, '.tk': 60}
  final Map<String, int> urlHighlights;

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
    this.linguisticSignals = const [],
    this.cyberSignals = const [],
    this.socialTactics = const [],
    this.urlHighlights = const {},
    required this.checkedAt,
  });

  ScamCheckResult copyWith({
    String? id,
    RiskLevel? riskLevel,
    int? riskScore,
    String? summary,
    List<String>? reasons,
    PsychologicalFactors? psychological,
    List<String>? linguisticSignals,
    List<String>? cyberSignals,
    List<String>? socialTactics,
    Map<String, int>? urlHighlights,
    DateTime? checkedAt,
  }) =>
      ScamCheckResult(
        id: id ?? this.id,
        target: target,
        input: input,
        riskLevel: riskLevel ?? this.riskLevel,
        riskScore: riskScore ?? this.riskScore,
        summary: summary ?? this.summary,
        reasons: reasons ?? this.reasons,
        psychological: psychological ?? this.psychological,
        linguisticSignals: linguisticSignals ?? this.linguisticSignals,
        cyberSignals: cyberSignals ?? this.cyberSignals,
        socialTactics: socialTactics ?? this.socialTactics,
        urlHighlights: urlHighlights ?? this.urlHighlights,
        checkedAt: checkedAt ?? this.checkedAt,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'target': target.name,
        'input': input,
        'riskLevel': riskLevel.name,
        'riskScore': riskScore,
        'summary': summary,
        'reasons': reasons,
        'psychological': psychological.toJson(),
        'linguisticSignals': linguisticSignals,
        'cyberSignals': cyberSignals,
        'socialTactics': socialTactics,
        'urlHighlights': urlHighlights,
        'checkedAt': checkedAt.toIso8601String(),
      };

  factory ScamCheckResult.fromJson(Map<String, dynamic> json) {
    List<String> readList(String key) =>
        (json[key] as List?)?.cast<String>() ?? const [];
    return ScamCheckResult(
      id: json['id'] as String,
      target: CheckTarget.values.firstWhere(
        (e) => e.name == json['target'],
        orElse: () => CheckTarget.phone,
      ),
      input: json['input'] as String,
      riskLevel: RiskLevel.fromString(json['riskLevel'] as String?),
      riskScore: (json['riskScore'] as num?)?.toInt() ?? 0,
      summary: json['summary'] as String? ?? '',
      reasons: readList('reasons'),
      psychological: PsychologicalFactors.fromJson(
        (json['psychological'] as Map?)?.cast<String, dynamic>() ?? const {},
      ),
      linguisticSignals: readList('linguisticSignals'),
      cyberSignals: readList('cyberSignals'),
      socialTactics: readList('socialTactics'),
      urlHighlights: (json['urlHighlights'] as Map?)?.cast<String, int>() ?? const {},
      checkedAt: DateTime.tryParse(json['checkedAt'] as String? ?? '') ??
          DateTime.now(),
    );
  }
}
