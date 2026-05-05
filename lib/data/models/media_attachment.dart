import 'dart:typed_data';

/// One image or video the user attaches to a free-text content analysis
/// request. Bytes are loaded fully into memory (Gemini inline-data limit is
/// ~20 MB total per request, so callers should size-check before adding).
class MediaAttachment {
  MediaAttachment({
    required this.kind,
    required this.mimeType,
    required this.bytes,
    required this.fileName,
  });

  final MediaKind kind;
  final String mimeType; // e.g. 'image/jpeg', 'video/mp4'
  final Uint8List bytes;
  final String fileName;

  int get sizeBytes => bytes.length;

  /// Human-readable size (e.g. "1.4 MB").
  String get sizeLabel {
    final mb = sizeBytes / (1024 * 1024);
    if (mb >= 1) return '${mb.toStringAsFixed(1)} MB';
    final kb = sizeBytes / 1024;
    return '${kb.toStringAsFixed(0)} KB';
  }
}

enum MediaKind { image, video }
