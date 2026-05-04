import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/risk_level.dart';
import '../../data/models/scam_check_result.dart';
import '../../shared/widgets/risk_gauge.dart';
import '../../shared/widgets/scanning_overlay.dart';
import '../../shared/widgets/threat_radar_chart.dart';
import '../scam_check/scam_check_provider.dart';

/// Stateful so we can swap [_result] in-place after Gemini analysis without
/// popping back to the previous screen.
class ResultScreen extends StatefulWidget {
  const ResultScreen({super.key, required this.result});

  final ScamCheckResult result;

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  late ScamCheckResult _result = widget.result;

  bool get _hasPsy {
    final p = _result.psychological;
    return p.urgency + p.fear + p.authority + p.greed > 0;
  }

  bool get _isUnknown => _result.riskLevel == RiskLevel.unknown;

  String _shareText() => [
        '[Scam Detector] ${_result.riskLevel.label} (${_result.riskScore}/100)',
        '${_result.target.label}: ${_result.input}',
        _result.summary,
        if (_result.reasons.isNotEmpty) ...[
          '',
          'Lý do:',
          ..._result.reasons.map((r) => '• $r'),
        ],
      ].join('\n');

  Future<void> _copy() async {
    await Clipboard.setData(ClipboardData(text: _shareText()));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Đã sao chép kết quả')),
    );
  }

  Future<void> _runAi() async {
    final updated =
        await context.read<ScamCheckProvider>().analyzeWithAi(_result);
    if (!mounted || updated == null) return;
    setState(() => _result = updated);
  }

  Future<void> _openUrl() async {
    final raw = _result.input.trim();
    final uri = Uri.tryParse(
      raw.startsWith('http') ? raw : 'https://$raw',
    );
    if (uri == null) return;
    if (_result.riskLevel == RiskLevel.scam ||
        _result.riskLevel == RiskLevel.suspicious) {
      final ok = await showDialog<bool>(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Cảnh báo'),
          content: Text(
            'Liên kết này được đánh giá ${_result.riskLevel.label.toLowerCase()}. '
            'Bạn có chắc muốn mở?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Huỷ'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Vẫn mở'),
            ),
          ],
        ),
      );
      if (ok != true) return;
    }
    if (!mounted) return;
    final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!launched && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Không mở được liên kết')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final aiLoading = context.watch<ScamCheckProvider>().isAiLoading;
    final isScam = _result.riskLevel == RiskLevel.scam;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kết quả phân tích'),
        actions: [
          IconButton(
            tooltip: 'Sao chép',
            icon: const Icon(Icons.copy_outlined),
            onPressed: _copy,
          ),
        ],
      ),
      body: SafeArea(
        child: Stack(
          children: [
            ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              children: [
                _RiskHeader(result: _result),
                const SizedBox(height: 16),
                // Hide the target/input card when there's nothing meaningful
                // to show (e.g. native screened-call records that lost their
                // raw number, or placeholder rows). Avoids a visibly empty
                // card on the result screen.
                if (_result.input.trim().isNotEmpty) ...[
                  _TargetCard(result: _result),
                  const SizedBox(height: 16),
                ],

                // AI behavioural analysis CTA. Promoted when verdict is unknown
                // (no local + no community data); otherwise a quieter card.
                _AiAnalysisCard(
                  isUnknown: _isUnknown,
                  hasPsy: _hasPsy,
                  loading: aiLoading,
                  onTap: aiLoading ? null : _runAi,
                ),
                const SizedBox(height: 16),

                if (_result.reasons.isNotEmpty) ...[
                  _SectionHeader(
                    icon: Icons.fact_check_outlined,
                    title: 'Lý do cảnh báo',
                  ),
                  const SizedBox(height: 8),
                  _ReasonsCard(
                    reasons: _result.reasons,
                    accent: _result.riskLevel.color,
                  ),
                  const SizedBox(height: 16),
                ],

                // Multi-axis behavioural analysis (linguistics / cybersecurity /
                // social psychology). Hidden when no signals from any axis.
                if (_result.linguisticSignals.isNotEmpty ||
                    _result.cyberSignals.isNotEmpty ||
                    _result.socialTactics.isNotEmpty) ...[
                  _SectionHeader(
                    icon: Icons.hub_outlined,
                    title: 'Phân tích đa góc nhìn',
                  ),
                  const SizedBox(height: 8),
                  if (_result.linguisticSignals.isNotEmpty)
                    _SignalCard(
                      icon: Icons.translate,
                      title: 'Ngôn ngữ học',
                      subtitle: 'Dấu hiệu trong cách diễn đạt / từ vựng',
                      signals: _result.linguisticSignals,
                      accent: const Color(0xFF7B1FA2),
                    ),
                  if (_result.cyberSignals.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    _SignalCard(
                      icon: Icons.shield_moon_outlined,
                      title: 'An ninh mạng',
                      subtitle: 'Dấu hiệu kỹ thuật / hạ tầng',
                      signals: _result.cyberSignals,
                      accent: const Color(0xFF00838F),
                    ),
                  ],
                  if (_result.socialTactics.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    _SignalCard(
                      icon: Icons.psychology_alt_outlined,
                      title: 'Tâm lý học xã hội',
                      subtitle:
                          'Thủ thuật thuyết phục (Cialdini & thao túng cảm xúc)',
                      signals: _result.socialTactics,
                      accent: const Color(0xFFC2185B),
                    ),
                  ],
                  const SizedBox(height: 16),
                ],

                if (_hasPsy) ...[
                  _SectionHeader(
                    icon: Icons.radar,
                    title: 'Phân tích vector tâm lý',
                  ),
                  const SizedBox(height: 8),
                  _RadarCard(result: _result),
                  const SizedBox(height: 16),
                ],

                if (isScam) ...[
                  const _SecurityProtocolCallout(),
                  const SizedBox(height: 16),
                ],
                if (_result.target == CheckTarget.url) ...[
                  OutlinedButton.icon(
                    onPressed: _openUrl,
                    icon: const Icon(Icons.open_in_new),
                    label: const Text('Mở liên kết'),
                  ),
                  const SizedBox(height: 12),
                ],
                OutlinedButton.icon(
                  onPressed: () =>
                      Navigator.of(context).popUntil((r) => r.isFirst),
                  icon: const Icon(Icons.home_outlined),
                  label: const Text('Về trang chủ'),
                ),
              ],
            ),
            if (aiLoading)
              const Positioned.fill(
                child: ScanningOverlay(
                  message: 'Gemini đang phân tích hành vi…',
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _AiAnalysisCard extends StatelessWidget {
  const _AiAnalysisCard({
    required this.isUnknown,
    required this.hasPsy,
    required this.loading,
    required this.onTap,
  });

  final bool isUnknown;
  final bool hasPsy;
  final bool loading;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final ctaLabel = hasPsy
        ? 'Phân tích lại bằng AI'
        : isUnknown
            ? 'Phân tích sâu bằng AI Gemini'
            : 'Phân tích hành vi bằng AI';
    final subtitle = isUnknown
        ? 'Chưa có dữ liệu offline / cộng đồng. Để Gemini phân tích kịch bản, dấu hiệu thao túng và các yếu tố tâm lý.'
        : 'Bổ sung phân tích hành vi (urgency / fear / authority / greed) và lý do chi tiết từ AI.';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isUnknown
              ? [AppColors.primary, AppColors.primaryDark]
              : [
                  AppColors.primaryContainer,
                  AppColors.primaryContainer.withValues(alpha: 0.6),
                ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.auto_awesome,
                color: isUnknown ? Colors.white : AppColors.primary,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Phân tích hành vi bằng AI',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: isUnknown
                            ? Colors.white
                            : AppColors.onPrimaryContainer,
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: isUnknown
                      ? Colors.white.withValues(alpha: 0.85)
                      : AppColors.textSecondary,
                  height: 1.4,
                ),
          ),
          const SizedBox(height: 14),
          ElevatedButton.icon(
            onPressed: onTap,
            style: ElevatedButton.styleFrom(
              backgroundColor: isUnknown ? Colors.white : AppColors.primary,
              foregroundColor: isUnknown ? AppColors.primary : Colors.white,
              minimumSize: const Size.fromHeight(48),
              shape: const StadiumBorder(),
              textStyle: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
            icon: loading
                ? SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: isUnknown ? AppColors.primary : Colors.white,
                    ),
                  )
                : const Icon(Icons.psychology_outlined, size: 18),
            label: Text(loading ? 'Đang phân tích…' : ctaLabel),
          ),
        ],
      ),
    );
  }
}

class _RiskHeader extends StatelessWidget {
  const _RiskHeader({required this.result});
  final ScamCheckResult result;

  @override
  Widget build(BuildContext context) {
    final color = result.riskLevel.color;
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
        child: Column(
          children: [
            RiskGauge(score: result.riskScore, level: result.riskLevel),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(result.riskLevel.icon, color: Colors.white, size: 16),
                  const SizedBox(width: 6),
                  Text(
                    result.riskLevel.label.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                      letterSpacing: 1.0,
                    ),
                  ),
                ],
              ),
            ),
            if (result.summary.trim().isNotEmpty) ...[
              const SizedBox(height: 14),
              Text(
                result.summary,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _TargetCard extends StatelessWidget {
  const _TargetCard({required this.result});
  final ScamCheckResult result;

  @override
  Widget build(BuildContext context) {
    final icon = switch (result.target) {
      CheckTarget.phone => Icons.phone_outlined,
      CheckTarget.bankAccount => Icons.account_balance_outlined,
      CheckTarget.url => Icons.link,
      CheckTarget.content => Icons.text_snippet_outlined,
    };
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: const Border(
          left: BorderSide(width: 4, color: AppColors.primary),
          top: BorderSide(color: AppColors.border),
          right: BorderSide(color: AppColors.border),
          bottom: BorderSide(color: AppColors.border),
        ),
      ),
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(result.target.label.toUpperCase(),
                    style: Theme.of(context).textTheme.labelSmall),
                const SizedBox(height: 2),
                Text(
                  result.input,
                  maxLines: result.target == CheckTarget.content ? 4 : 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: result.target == CheckTarget.content ? 14 : 16,
                        height: result.target == CheckTarget.content ? 1.4 : null,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.icon, required this.title});
  final IconData icon;
  final String title;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
        ],
      ),
    );
  }
}

/// Card grouping a list of textual signals from one analytical axis
/// (linguistics / cybersecurity / social psychology).
class _SignalCard extends StatelessWidget {
  const _SignalCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.signals,
    required this.accent,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final List<String> signals;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: const Border(
          top: BorderSide(color: AppColors.border),
          right: BorderSide(color: AppColors.border),
          bottom: BorderSide(color: AppColors.border),
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border(left: BorderSide(width: 4, color: accent)),
        ),
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: accent, size: 18),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: Theme.of(context)
                            .textTheme
                            .titleSmall
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      Text(
                        subtitle,
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ...signals.map(
              (s) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 7),
                      child: Container(
                        width: 6,
                        height: 6,
                        decoration:
                            BoxDecoration(color: accent, shape: BoxShape.circle),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        s,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReasonsCard extends StatelessWidget {
  const _ReasonsCard({required this.reasons, required this.accent});
  final List<String> reasons;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
        child: Column(
          children: reasons
              .map(
                (r) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: accent.withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.warning_amber_rounded,
                            size: 14, color: accent),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          r,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}

class _RadarCard extends StatelessWidget {
  const _RadarCard({required this.result});
  final ScamCheckResult result;
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
        child: Column(
          children: [
            ThreatRadarChart(
              factors: result.psychological,
              color: result.riskLevel.color,
            ),
            const SizedBox(height: 8),
            Text(
              'Mỗi trục là một thủ thuật tâm lý lừa đảo phổ biến (0–100). '
              'Diện tích càng lớn, mức độ thao túng càng cao.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

class _SecurityProtocolCallout extends StatelessWidget {
  const _SecurityProtocolCallout();
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primaryDark,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Icon(Icons.shield, color: Colors.white, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Cần áp dụng quy trình bảo vệ',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Không cung cấp OTP, mã PIN, mật khẩu cho bất kỳ ai. '
                  'Báo cáo cho ngân hàng / cơ quan chức năng nếu đã chuyển tiền.',
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: Colors.white70),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
