import '../data/models/risk_level.dart';
import '../data/models/scam_check_result.dart';

/// Result of one URL phishing signal detected by [UrlPhishingAnalyzer].
class UrlSignal {
  const UrlSignal({
    required this.message,
    required this.highlighted,
    required this.severity,
  });

  /// Human-readable explanation (Vietnamese).
  final String message;

  /// The problematic URL fragment to highlight (e.g. "http", "youtobe", ".tk").
  final String highlighted;

  /// 0–100, maps to RiskLevel.
  final int severity;
}

/// Detects common phishing patterns in URLs without calling AI or any database.
///
/// Rules:
///   1. Missing HTTPS (scheme is http:// or absent)
///   2. Typo-squatting of popular VN brands (Vietcombank, Techcombank, …)
///   3. Suspicious TLDs (.tk, .ml, .ga, .cf, .gq — known for free abuse)
///   4. Brand impersonation (hyphenated bank + action word)
///   5. Homoglyph in domain (o→0, l→1, i→1, m→rn, w→vv, …)
///   6. Excessive subdomains (≥3 dots — typical phishing structure)
class UrlPhishingAnalyzer {
  UrlPhishingAnalyzer();

  /// Returns a list of detected signals. Empty if nothing suspicious.
  List<UrlSignal> analyze(String raw) {
    final trimmed = raw.trim();
    final url = _ensureHost(trimmed);
    final host = _extractHost(url);
    if (host.isEmpty) return const [];

    final signals = <UrlSignal>[];

    // Rule 1: Missing HTTPS
    if (!_hasSecureScheme(trimmed)) {
      signals.add(const UrlSignal(
        message: 'Thiếu HTTPS — kết nối không được mã hóa. Khuyến nghị luôn dùng https://',
        highlighted: 'http',
        severity: 40,
      ));
    }

    // Rule 2: Suspicious TLDs
    final tld = _extractTld(host);
    if (_suspiciousTlds.contains(tld)) {
      signals.add(UrlSignal(
        message: 'Tên miền sử dụng TLD miễn phí ($tld) — thường được dùng cho phishing.',
        highlighted: tld,
        severity: 60,
      ));
    }

    // Rule 3: Brand impersonation via hyphenated pattern
    if (_isBrandImpersonation(host)) {
      signals.add(UrlSignal(
        message: 'Tên miền giả mạo thương hiệu — ngân hàng thật không dùng pattern "bank-hànhđộng".',
        highlighted: host,
        severity: 80,
      ));
    }

    // Rule 4: Typo-squatting of known VN brands
    final typoMatch = _findTypoSquat(host);
    if (typoMatch != null) {
      signals.add(UrlSignal(
        message: 'Tên miền giống ${typoMatch.brand} nhưng bị sai chính tả "${typoMatch.misspelt}" → "${typoMatch.correct}".',
        highlighted: typoMatch.misspelt,
        severity: 85,
      ));
    }

    // Rule 5: Homoglyph substitution
    final homoglyph = _findHomoglyph(host);
    if (homoglyph != null) {
      signals.add(UrlSignal(
        message: 'Ký tự đánh lừa: "${homoglyph.found}" trông giống "${homoglyph.expected}" — kỹ thuật homoglyph phổ biến trong phishing.',
        highlighted: homoglyph.found,
        severity: 75,
      ));
    }

    // Rule 6: Excessive subdomains
    final dotCount = host.split('.').length - 1;
    if (dotCount >= 3) {
      signals.add(UrlSignal(
        message: 'Quá nhiều subdomain — cấu trúc này thường dùng để né filter phishing.',
        highlighted: host,
        severity: 45,
      ));
    }

    return signals;
  }

  /// Build a [ScamCheckResult] from detected signals. Returns null if none.
  ScamCheckResult? resultFromSignals({
    required String input,
    required String resultId,
    required List<UrlSignal> signals,
  }) {
    if (signals.isEmpty) return null;

    final maxScore = signals.isEmpty ? 0 : signals.map((s) => s.severity).reduce((a, b) => a > b ? a : b);
    final level = _scoreToLevel(maxScore);
    return ScamCheckResult(
      id: resultId,
      target: CheckTarget.url,
      input: input,
      riskLevel: level,
      riskScore: maxScore,
      summary: signals.length == 1
          ? signals.first.message
          : 'Phát hiện ${signals.length} dấu hiệu phishing trên đường dẫn.',
      reasons: signals.map((s) => s.message).toList(),
      psychological: const PsychologicalFactors(),
      urlHighlights: {for (final s in signals) s.highlighted: s.severity},
      checkedAt: DateTime.now(),
    );
  }
}

// ── Rule helpers ────────────────────────────────────────────────────────────

String _ensureHost(String raw) {
  if (!raw.contains('://')) return 'https://$raw';
  return raw;
}

String _extractHost(String url) {
  try {
    final uri = Uri.parse(url);
    return (uri.host).toLowerCase();
  } catch (_) {
    // Fallback: take everything before first '/'.
    final withoutScheme = url.contains('://') ? url.split('://')[1] : url;
    return withoutScheme.split('/').first.toLowerCase();
  }
}

String _extractTld(String host) {
  final parts = host.split('.');
  if (parts.length < 2) return '';
  return '.${parts.last}';
}

bool _hasSecureScheme(String raw) {
  final lower = raw.toLowerCase().trim();
  return lower.startsWith('https://') || (!lower.contains('://'));
}

const _suspiciousTlds = {
  '.tk', '.ml', '.ga', '.cf', '.gq', '.buzz', '.click',
  '.top', '.icu', '.work', '.rest', '.cyou', '.shop',
};

const _brandKeywords = {
  'vietcombank', 'techcombank', 'mbbank', 'tpbank', 'vpbank',
  'bidv', 'agribank', 'acb', 'sacombank', 'shb',
  'ocb', 'eximbank', 'vietinbank', 'msb', 'vib',
  'zalopay', 'momovnpay', 'shopeepay',
  'google', 'facebook', 'apple', 'microsoft',
};

const _suspiciousKeywords = {
  'login', 'signin', 'sign-in', 'verify', 'xac-minh', 'xacminh',
  'confirm', 'security', 'update', 'cap-nhat', 'capnhat',
  'secure', 'account', 'tai-khoan', 'taikhoan', 'unusual',
  'suspended', 'khoa', 'locked', 'alert', 'phishing',
  'reset', 'password', 'otp', 'recover', 'unblock',
};

bool _isBrandImpersonation(String host) {
  // Remove scheme artifacts and common prefixes.
  final cleaned = host
      .replaceFirst('www.', '')
      .split('.')
      .take(2)
      .join('.');
  final parts = cleaned.split(RegExp(r'[-._]'));
  if (parts.length < 2) return false;
  final hasBrand = parts.any((p) => _brandKeywords.contains(p.toLowerCase()));
  final hasAction = parts.any((p) => _suspiciousKeywords.contains(p.toLowerCase()));
  return hasBrand && hasAction;
}

// Typo-squatting detection: compare SLD (second-level domain) against known
// brand names using Levenshtein distance ≤ 2.
_TypoMatch? _findTypoSquat(String host) {
  final parts = host.split('.');
  if (parts.length < 2) return null;
  // Take the full domain minus TLD for comparison.
  // For subdomains like login.vietcombank-xyz.tk, check each part.
  final sld = parts[parts.length - 2];
  for (final brand in _brandKeywords) {
    if (sld == brand) continue; // exact match, not typo
    final dist = _levenshtein(sld, brand);
    if (dist >= 1 && dist <= 2) {
      return _TypoMatch(brand: brand, misspelt: sld, correct: brand);
    }
    // Also check the full host (minus TLD) in case typo is in a subdomain.
    final fullMinusTld = parts.take(parts.length - 1).join('.');
    for (final segment in fullMinusTld.split(RegExp(r'[-.]'))) {
      final d = _levenshtein(segment, brand);
      if (d >= 1 && d <= 2) {
        return _TypoMatch(brand: brand, misspelt: segment, correct: brand);
      }
    }
  }
  return null;
}

// Homoglyph detection: look for common character substitutions.
_HomoglyphMatch? _findHomoglyph(String host) {
  const pairs = [
    _HomoglyphPair('0', 'o'), // zero → o
    _HomoglyphPair('1', 'l'), // one → l
    _HomoglyphPair('1', 'i'), // one → i
    _HomoglyphPair('rn', 'm'), // rn → m
    _HomoglyphPair('vv', 'w'), // vv → w
    _HomoglyphPair('cl', 'd'), // cl → d
  ];
  for (final p in pairs) {
    if (host.contains(p.sub)) {
      return _HomoglyphMatch(found: p.sub, expected: p.orig);
    }
  }
  return null;
}

RiskLevel _scoreToLevel(int score) {
  if (score >= 70) return RiskLevel.scam;
  if (score >= 40) return RiskLevel.suspicious;
  return RiskLevel.safe;
}

int _levenshtein(String a, String b) {
  if (a == b) return 0;
  if (a.isEmpty) return b.length;
  if (b.isEmpty) return a.length;

  final m = a.length;
  final n = b.length;
  final dp = List.generate(m + 1, (i) => List.filled(n + 1, 0));

  for (var i = 0; i <= m; i++) { dp[i][0] = i; }
  for (var j = 0; j <= n; j++) { dp[0][j] = j; }

  for (var i = 1; i <= m; i++) {
    for (var j = 1; j <= n; j++) {
      final cost = a[i - 1] == b[j - 1] ? 0 : 1;
      dp[i][j] = [
        dp[i - 1][j] + 1,
        dp[i][j - 1] + 1,
        dp[i - 1][j - 1] + cost,
      ].reduce((a, b) => a < b ? a : b);
    }
  }
  return dp[m][n];
}

class _TypoMatch {
  const _TypoMatch({
    required this.brand,
    required this.misspelt,
    required this.correct,
  });
  final String brand;
  final String misspelt;
  final String correct;
}

class _HomoglyphPair {
  const _HomoglyphPair(this.sub, this.orig);
  final String sub;
  final String orig;
}

class _HomoglyphMatch {
  const _HomoglyphMatch({required this.found, required this.expected});
  final String found;
  final String expected;
}
