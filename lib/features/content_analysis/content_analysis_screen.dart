import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/scam_check_result.dart';
import '../../shared/widgets/scanning_overlay.dart';
import '../result/result_screen.dart';
import '../scam_check/scam_check_provider.dart';

/// Free-text scam analysis. User pastes a suspect SMS / email / describes a
/// phone call or scenario, AI returns the same 3-axis (linguistic +
/// cybersecurity + social) verdict used elsewhere.
///
/// Unlike the structured checks, this flow ALWAYS calls Gemini directly —
/// there's no exact-match local list for free text.
class ContentAnalysisScreen extends StatefulWidget {
  const ContentAnalysisScreen({super.key, this.initialContent});

  final String? initialContent;

  @override
  State<ContentAnalysisScreen> createState() => _ContentAnalysisScreenState();
}

class _ContentAnalysisScreenState extends State<ContentAnalysisScreen> {
  late final TextEditingController _controller =
      TextEditingController(text: widget.initialContent ?? '');

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _pasteFromClipboard() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    final text = data?.text?.trim();
    if (text == null || text.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Clipboard rỗng')),
      );
      return;
    }
    setState(() => _controller.text = text);
  }

  Future<void> _submit() async {
    final text = _controller.text.trim();
    if (text.length < 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nhập tối thiểu 5 ký tự để AI phân tích')),
      );
      return;
    }
    FocusScope.of(context).unfocus();
    final result = await context.read<ScamCheckProvider>().check(
          target: CheckTarget.content,
          input: text,
        );
    if (!mounted || result == null) return;
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => ResultScreen(result: result)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loading = context.watch<ScamCheckProvider>().isLoading;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Phân tích nội dung'),
        actions: [
          IconButton(
            tooltip: 'Dán từ clipboard',
            icon: const Icon(Icons.content_paste),
            onPressed: _pasteFromClipboard,
          ),
        ],
      ),
      body: SafeArea(
        child: Stack(
          children: [
            ListView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
              children: [
                Text(
                  'Phân tích bằng AI đa góc nhìn',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 6),
                Text(
                  'Dán tin nhắn lừa đảo, mô tả cuộc gọi hoặc kể lại tình huống. '
                  'Gemini sẽ phân tích theo 3 góc: ngôn ngữ học, an ninh mạng và tâm lý xã hội.',
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 18),
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border),
                  ),
                  padding: const EdgeInsets.all(4),
                  child: TextField(
                    controller: _controller,
                    maxLines: 10,
                    minLines: 8,
                    keyboardType: TextInputType.multiline,
                    style: const TextStyle(fontSize: 14, height: 1.5),
                    decoration: InputDecoration(
                      filled: false,
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      contentPadding: const EdgeInsets.all(14),
                      hintText:
                          'VD: "Vietcombank xin chào quý khách, tài khoản của quý khách phát sinh giao dịch lạ. Vui lòng truy cập http://vietcombank-xacminh.tk/login để xác minh trong 10 phút, nếu không tài khoản sẽ bị khoá."',
                      hintMaxLines: 6,
                      hintStyle: TextStyle(
                        fontSize: 13,
                        color: AppColors.textTertiary,
                        height: 1.45,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                ElevatedButton.icon(
                  onPressed: loading ? null : _submit,
                  icon: const Icon(Icons.auto_awesome),
                  label: const Text('Phân tích bằng AI'),
                ),
                const SizedBox(height: 18),
                _ExampleCards(onTap: (text) {
                  setState(() => _controller.text = text);
                }),
              ],
            ),
            if (loading)
              const Positioned.fill(
                child: ScanningOverlay(
                  message: 'Gemini đang phân tích nội dung…',
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _ExampleCards extends StatelessWidget {
  const _ExampleCards({required this.onTap});
  final ValueChanged<String> onTap;

  static const _examples = [
    (
      'Mạo danh ngân hàng',
      'Vietcombank thông báo: tài khoản của quý khách bị khoá do nghi ngờ '
          'gian lận. Vui lòng nhấn link sau để xác minh: '
          'http://vcb-online-secure.xyz/login. Nếu không xác minh trong 30 '
          'phút, mọi giao dịch sẽ bị huỷ.'
    ),
    (
      'CTV Shopee lãi cao',
      'Em chào anh/chị, em là tuyển dụng CTV Shopee. Anh/chị chỉ cần đặt '
          'đơn ảo, công ty hoàn lại tiền và cộng thêm 15% hoa hồng. Một '
          'ngày dễ kiếm 500-800k. Anh/chị quan tâm em gửi link nhóm Telegram.'
    ),
    (
      'Giả công an',
      'Đồng chí, đây là Đại uý Nguyễn Văn A — Phòng Cảnh sát Hình sự. '
          'Tài khoản của đồng chí có liên quan đường dây ma tuý xuyên quốc '
          'gia. Đồng chí phải chuyển toàn bộ tiền vào tài khoản tạm giữ '
          'của Bộ Công an để phục vụ điều tra trong 1 tiếng.'
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Hoặc thử với mẫu có sẵn',
          style: Theme.of(context).textTheme.labelLarge,
        ),
        const SizedBox(height: 8),
        for (final ex in _examples) ...[
          Material(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => onTap(ex.$2),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                padding: const EdgeInsets.all(12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.format_quote_outlined,
                        size: 18, color: AppColors.primary),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            ex.$1,
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            ex.$2,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right,
                        color: AppColors.textTertiary),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ],
    );
  }
}
