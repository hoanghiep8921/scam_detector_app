import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/scam_check_result.dart';
import '../../shared/widgets/risk_badge.dart';

class ResultScreen extends StatelessWidget {
  const ResultScreen({super.key, required this.result});

  final ScamCheckResult result;

  @override
  Widget build(BuildContext context) {
    final color = result.riskLevel.color;
    return Scaffold(
      appBar: AppBar(title: const Text('Kết quả phân tích')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Header card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: color.withValues(alpha: 0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(result.riskLevel.icon, color: color, size: 32),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              result.riskLevel.label,
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                                color: color,
                              ),
                            ),
                            Text(
                              'Điểm rủi ro: ${result.riskScore}/100',
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    result.summary,
                    style: const TextStyle(fontSize: 14, height: 1.5),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Target info
            _SectionCard(
              title: 'Thông tin đã kiểm tra',
              child: Row(
                children: [
                  const Icon(Icons.search, size: 18, color: AppColors.textSecondary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          result.target.label,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        Text(
                          result.input,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Reasons - Explainable AI
            if (result.reasons.isNotEmpty)
              _SectionCard(
                title: 'Lý do cảnh báo',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: result.reasons
                      .map((r) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Padding(
                                  padding: EdgeInsets.only(top: 6),
                                  child: Icon(Icons.circle, size: 6),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(r, style: const TextStyle(height: 1.4)),
                                ),
                              ],
                            ),
                          ))
                      .toList(),
                ),
              ),
            const SizedBox(height: 16),

            // Psychological factors
            _SectionCard(
              title: 'Phân tích tâm lý',
              child: Column(
                children: [
                  FactorBar(label: 'Tạo áp lực thời gian (Urgency)', value: result.psychological.urgency),
                  FactorBar(label: 'Đe doạ, gây sợ hãi (Fear)', value: result.psychological.fear),
                  FactorBar(label: 'Giả danh tổ chức (Authority)', value: result.psychological.authority),
                  FactorBar(label: 'Hứa hẹn lợi ích (Greed)', value: result.psychological.greed),
                ],
              ),
            ),
            const SizedBox(height: 24),

            OutlinedButton.icon(
              onPressed: () => Navigator.of(context).popUntil((r) => r.isFirst),
              icon: const Icon(Icons.home_outlined),
              label: const Text('Về trang chủ'),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}
