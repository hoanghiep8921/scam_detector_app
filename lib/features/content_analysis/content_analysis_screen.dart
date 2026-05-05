import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/media_attachment.dart';
import '../../data/models/scam_check_result.dart';
import '../../shared/widgets/scanning_overlay.dart';
import '../result/result_screen.dart';
import '../scam_check/scam_check_provider.dart';

/// Free-text + multimodal scam analysis. User can paste / type a suspect
/// message OR pick image(s) / a video from gallery / camera; Gemini reads
/// everything together and returns the same 3-axis verdict.
///
/// Unlike the structured checks, this flow ALWAYS calls Gemini — there's no
/// exact-match local list for free text.
class ContentAnalysisScreen extends StatefulWidget {
  const ContentAnalysisScreen({super.key, this.initialContent});

  final String? initialContent;

  @override
  State<ContentAnalysisScreen> createState() => _ContentAnalysisScreenState();
}

class _ContentAnalysisScreenState extends State<ContentAnalysisScreen> {
  late final TextEditingController _controller =
      TextEditingController(text: widget.initialContent ?? '');
  final _picker = ImagePicker();
  final List<MediaAttachment> _attachments = [];

  // Total inline-data limit Gemini accepts per request. We cap at 18 MB to
  // leave headroom for the prompt + JSON response. Max 5 images + 1 video.
  static const _maxBytes = 18 * 1024 * 1024;
  static const _maxImageCount = 5;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  int get _totalBytes =>
      _attachments.fold(0, (sum, a) => sum + a.sizeBytes);

  bool get _hasVideo =>
      _attachments.any((a) => a.kind == MediaKind.video);

  int get _imageCount =>
      _attachments.where((a) => a.kind == MediaKind.image).length;

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

  Future<void> _pickImages({required ImageSource source}) async {
    if (_imageCount >= _maxImageCount) {
      _snack('Tối đa $_maxImageCount ảnh / lần phân tích.');
      return;
    }
    try {
      final List<XFile> files;
      if (source == ImageSource.camera) {
        final f = await _picker.pickImage(
          source: ImageSource.camera,
          imageQuality: 85,
          maxWidth: 1920,
        );
        files = f == null ? [] : [f];
      } else {
        files = await _picker.pickMultiImage(
          imageQuality: 85,
          maxWidth: 1920,
          limit: _maxImageCount - _imageCount,
        );
      }
      for (final f in files) {
        await _addAttachment(f, MediaKind.image, 'image/jpeg');
      }
    } catch (e) {
      _snack('Không chọn được ảnh: $e');
    }
  }

  Future<void> _pickVideo() async {
    if (_hasVideo) {
      _snack('Đã có 1 video — chỉ phân tích 1 video / lần.');
      return;
    }
    try {
      final f = await _picker.pickVideo(
        source: ImageSource.gallery,
        maxDuration: const Duration(seconds: 30),
      );
      if (f == null) return;
      await _addAttachment(f, MediaKind.video, _detectVideoMime(f.name));
    } catch (e) {
      _snack('Không chọn được video: $e');
    }
  }

  String _detectVideoMime(String fileName) {
    final lower = fileName.toLowerCase();
    if (lower.endsWith('.mp4')) return 'video/mp4';
    if (lower.endsWith('.mov')) return 'video/quicktime';
    if (lower.endsWith('.webm')) return 'video/webm';
    if (lower.endsWith('.3gp')) return 'video/3gpp';
    return 'video/mp4';
  }

  Future<void> _addAttachment(
    XFile file,
    MediaKind kind,
    String mimeType,
  ) async {
    final bytes = await file.readAsBytes();
    if (_totalBytes + bytes.length > _maxBytes) {
      _snack(
        'Vượt quá tổng dung lượng cho phép (~18 MB). '
        'Hãy chọn file nhỏ hơn hoặc bớt media.',
      );
      return;
    }
    if (!mounted) return;
    setState(() {
      _attachments.add(MediaAttachment(
        kind: kind,
        mimeType: mimeType,
        bytes: bytes,
        fileName: file.name,
      ));
    });
  }

  void _removeAt(int i) {
    setState(() => _attachments.removeAt(i));
  }

  void _snack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }

  Future<void> _submit() async {
    final text = _controller.text.trim();
    if (text.isEmpty && _attachments.isEmpty) {
      _snack('Nhập text hoặc đính kèm ảnh / video để AI phân tích.');
      return;
    }
    if (text.length < 5 && text.isNotEmpty && _attachments.isEmpty) {
      _snack('Text quá ngắn (tối thiểu 5 ký tự) hoặc kèm thêm ảnh.');
      return;
    }
    FocusScope.of(context).unfocus();
    final result = await context.read<ScamCheckProvider>().check(
          target: CheckTarget.content,
          input: text,
          attachments: List.unmodifiable(_attachments),
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
                  'Dán tin nhắn, mô tả cuộc gọi hoặc đính kèm ảnh / video. '
                  'Gemini đọc cả OCR trong ảnh + nội dung video để phân tích '
                  'theo 3 góc: ngôn ngữ học, an ninh mạng và tâm lý xã hội.',
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
                    maxLines: 8,
                    minLines: 5,
                    keyboardType: TextInputType.multiline,
                    style: const TextStyle(fontSize: 14, height: 1.5),
                    decoration: InputDecoration(
                      filled: false,
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      contentPadding: const EdgeInsets.all(14),
                      hintText:
                          'VD: "Vietcombank xin chào quý khách, tài khoản của quý khách phát sinh giao dịch lạ..."',
                      hintMaxLines: 4,
                      hintStyle: TextStyle(
                        fontSize: 13,
                        color: AppColors.textTertiary,
                        height: 1.45,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                _AttachmentBar(
                  attachments: _attachments,
                  totalBytes: _totalBytes,
                  maxBytes: _maxBytes,
                  onRemoveAt: _removeAt,
                  onPickGallery: () => _pickImages(source: ImageSource.gallery),
                  onPickCamera: () => _pickImages(source: ImageSource.camera),
                  onPickVideo: _pickVideo,
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
              Positioned.fill(
                child: ScanningOverlay(
                  message: _attachments.isEmpty
                      ? 'Gemini đang phân tích nội dung…'
                      : 'Gemini đang đọc ảnh / video + phân tích…',
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Strip showing picker buttons + thumbnails + total size.
class _AttachmentBar extends StatelessWidget {
  const _AttachmentBar({
    required this.attachments,
    required this.totalBytes,
    required this.maxBytes,
    required this.onRemoveAt,
    required this.onPickGallery,
    required this.onPickCamera,
    required this.onPickVideo,
  });

  final List<MediaAttachment> attachments;
  final int totalBytes;
  final int maxBytes;
  final void Function(int) onRemoveAt;
  final VoidCallback onPickGallery;
  final VoidCallback onPickCamera;
  final VoidCallback onPickVideo;

  String _formatSize(int bytes) {
    final mb = bytes / (1024 * 1024);
    if (mb >= 1) return '${mb.toStringAsFixed(1)} MB';
    final kb = bytes / 1024;
    return '${kb.toStringAsFixed(0)} KB';
  }

  @override
  Widget build(BuildContext context) {
    final hasAny = attachments.isNotEmpty;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.attach_file,
                  size: 18, color: AppColors.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  hasAny
                      ? 'Đã đính kèm ${attachments.length} (${_formatSize(totalBytes)} / ${_formatSize(maxBytes)})'
                      : 'Đính kèm ảnh / video (tuỳ chọn)',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _PickerChip(
                icon: Icons.photo_library_outlined,
                label: 'Thư viện',
                onTap: onPickGallery,
              ),
              _PickerChip(
                icon: Icons.camera_alt_outlined,
                label: 'Chụp ảnh',
                onTap: onPickCamera,
              ),
              _PickerChip(
                icon: Icons.videocam_outlined,
                label: 'Video',
                onTap: onPickVideo,
              ),
            ],
          ),
          if (hasAny) ...[
            const SizedBox(height: 12),
            SizedBox(
              height: 84,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: attachments.length,
                separatorBuilder: (_, _) => const SizedBox(width: 8),
                itemBuilder: (_, i) => _Thumb(
                  attachment: attachments[i],
                  onRemove: () => onRemoveAt(i),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _PickerChip extends StatelessWidget {
  const _PickerChip({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.primaryContainer.withValues(alpha: 0.6),
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16, color: AppColors.primary),
              const SizedBox(width: 6),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Thumb extends StatelessWidget {
  const _Thumb({required this.attachment, required this.onRemove});
  final MediaAttachment attachment;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          width: 84,
          height: 84,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: AppColors.primaryContainer.withValues(alpha: 0.3),
          ),
          clipBehavior: Clip.antiAlias,
          child: attachment.kind == MediaKind.image
              ? Image.memory(
                  attachment.bytes,
                  fit: BoxFit.cover,
                  width: 84,
                  height: 84,
                )
              : Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.movie_outlined,
                          color: AppColors.primary, size: 28),
                      const SizedBox(height: 4),
                      Text(
                        attachment.sizeLabel,
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
        ),
        Positioned(
          top: -2,
          right: -2,
          child: Material(
            color: AppColors.riskHigh,
            shape: const CircleBorder(),
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: onRemove,
              child: const Padding(
                padding: EdgeInsets.all(3),
                child: Icon(Icons.close, size: 14, color: Colors.white),
              ),
            ),
          ),
        ),
      ],
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
