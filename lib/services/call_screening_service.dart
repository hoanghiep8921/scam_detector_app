import 'dart:io' show Platform;
import 'package:flutter/services.dart';
import '../data/models/risk_level.dart';

/// Payload pushed by native when a scam call has been screened and the user
/// (or full-screen intent) brought the app forward.
class IncomingCallEvent {
  IncomingCallEvent({
    required this.number,
    required this.label,
    required this.blocked,
  });

  final String number;
  final String label;
  final bool blocked;

  factory IncomingCallEvent.fromMap(Map map) => IncomingCallEvent(
        number: map['number'] as String? ?? '',
        label: map['label'] as String? ?? '',
        blocked: map['blocked'] as bool? ?? false,
      );
}

typedef IncomingCallListener = void Function(IncomingCallEvent event);

/// A screened-call record drained from the native queue. Native pushes one of
/// these for every call the [IncomingCallScreener] blocks or flags, regardless
/// of whether the user tapped the resulting notification.
class ScreenedCallEvent {
  ScreenedCallEvent({
    required this.number,
    required this.label,
    required this.blocked,
    required this.timestamp,
  });

  final String number;
  final String label;
  final bool blocked;
  final DateTime timestamp;

  factory ScreenedCallEvent.fromMap(Map map) => ScreenedCallEvent(
        number: map['number'] as String? ?? '',
        label: map['label'] as String? ?? '',
        blocked: map['blocked'] as bool? ?? false,
        timestamp: DateTime.fromMillisecondsSinceEpoch(
          (map['timestamp'] as num?)?.toInt() ?? DateTime.now().millisecondsSinceEpoch,
        ),
      );
}

/// Wraps the native CallScreening MethodChannel.
///
/// All operations are no-ops outside of Android.
class CallScreeningService {
  CallScreeningService._internal();
  static final CallScreeningService _instance = CallScreeningService._internal();
  factory CallScreeningService() => _instance;

  static const _channel = MethodChannel('com.scamdetector/call_screening');

  IncomingCallListener? _listener;
  bool _listenerRegistered = false;

  bool get isSupportedPlatform => Platform.isAndroid;

  /// Register the Dart-side listener for incoming-call events forwarded from
  /// the native CallScreeningService notification.
  ///
  /// Call once from app startup. The most recent listener wins. Native buffers
  /// the latest event if it arrived before this was called (cold launch).
  void setIncomingCallListener(IncomingCallListener listener) {
    _listener = listener;
    if (!isSupportedPlatform) return;
    if (!_listenerRegistered) {
      _channel.setMethodCallHandler(_handleMethodCall);
      _listenerRegistered = true;
    }
    // Tell native we're ready; it will replay any buffered event.
    _channel.invokeMethod('registerIncomingCallListener');
  }

  Future<dynamic> _handleMethodCall(MethodCall call) async {
    if (call.method == 'incomingCallDetected') {
      final args = call.arguments;
      if (args is Map && _listener != null) {
        _listener!(IncomingCallEvent.fromMap(args));
      }
    }
    return null;
  }

  /// Whether this app currently holds ROLE_CALL_SCREENING.
  /// Returns false on non-Android or pre-Android-10 devices.
  Future<bool> isRoleHeld() async {
    if (!isSupportedPlatform) return false;
    try {
      final held = await _channel.invokeMethod<bool>('isCallScreeningRoleHeld');
      return held ?? false;
    } catch (_) {
      return false;
    }
  }

  /// Asks the user (via Android system dialog) to grant the call screening role.
  /// Returns true if granted.
  Future<bool> requestRole() async {
    if (!isSupportedPlatform) return false;
    try {
      final granted = await _channel.invokeMethod<bool>('requestCallScreeningRole');
      return granted ?? false;
    } on PlatformException {
      return false;
    }
  }

  /// Add a phone number to the native blocklist (per-device override). The
  /// number is normalized natively. If [level] is `scam` the number is moved
  /// out of the suspicious set if it was there (and vice versa). Used by the
  /// "CHẶN & NGẮT MÁY" button on the incoming-call overlay.
  Future<bool> addToBlocklist({
    required String number,
    RiskLevel level = RiskLevel.scam,
  }) async {
    if (!isSupportedPlatform) return false;
    try {
      final ok = await _channel.invokeMethod<bool>(
        'addBlocklistNumber',
        {
          'number': number,
          'level': level == RiskLevel.scam ? 'scam' : 'suspicious',
        },
      );
      return ok ?? false;
    } catch (_) {
      return false;
    }
  }

  /// Remove a number from BOTH scam and suspicious sets in the native
  /// blocklist. Used by the "Tôi vẫn tin số này" button — acts as a per-device
  /// whitelist override. Note: a subsequent "Đồng bộ lại từ máy chủ" may
  /// re-add the number if it's in the centralized DB.
  Future<bool> removeFromBlocklist(String number) async {
    if (!isSupportedPlatform) return false;
    try {
      final ok = await _channel.invokeMethod<bool>(
        'removeBlocklistNumber',
        {'number': number},
      );
      return ok ?? false;
    } catch (_) {
      return false;
    }
  }

  /// Read the phone numbers currently in the native CallScreening blocklist
  /// (the actual SharedPreferences entries that [IncomingCallScreener] checks
  /// against on each incoming call). Empty on iOS / before first sync /
  /// after a Reset.
  Future<({Set<String> scam, Set<String> suspicious})> getNativeBlocklist() async {
    if (!isSupportedPlatform) {
      return (scam: <String>{}, suspicious: <String>{});
    }
    try {
      final raw = await _channel.invokeMethod<Map<dynamic, dynamic>>('getBlocklist');
      final scam = (raw?['scam'] as List?)?.cast<String>().toSet() ?? <String>{};
      final suspicious =
          (raw?['suspicious'] as List?)?.cast<String>().toSet() ?? <String>{};
      return (scam: scam, suspicious: suspicious);
    } catch (_) {
      return (scam: <String>{}, suspicious: <String>{});
    }
  }

  /// Wipe ALL data the native side stores in `scam_detector_prefs`
  /// (blocklist, screened-call event queue). Used by the in-app
  /// "Reset toàn bộ dữ liệu" button.
  Future<void> clearAllNativeData() async {
    if (!isSupportedPlatform) return;
    try {
      await _channel.invokeMethod('clearAllNativeData');
    } catch (_) {
      // Best-effort.
    }
  }

  /// Pull and clear the queue of calls the native [IncomingCallScreener] has
  /// processed since the last drain. Returns oldest-first.
  Future<List<ScreenedCallEvent>> drainScreeningEvents() async {
    if (!isSupportedPlatform) return const [];
    try {
      final raw = await _channel.invokeMethod<List<dynamic>>('drainScreeningEvents');
      if (raw == null) return const [];
      return raw
          .whereType<Map>()
          .map(ScreenedCallEvent.fromMap)
          .toList();
    } catch (_) {
      return const [];
    }
  }

  /// Push the current scam / suspicious phone lists to native side so the
  /// CallScreeningService can match incoming calls offline.
  Future<void> syncBlocklist({
    required List<String> scam,
    required List<String> suspicious,
  }) async {
    if (!isSupportedPlatform) return;
    try {
      await _channel.invokeMethod('syncBlocklist', {
        'scam': scam,
        'suspicious': suspicious,
      });
    } catch (_) {
      // Native bridge may not be registered (e.g. running on iOS).
    }
  }
}
