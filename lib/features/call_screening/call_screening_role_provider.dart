import 'package:flutter/foundation.dart';
import '../../services/call_screening_service.dart';

/// Shared single source of truth for whether this app currently holds the
/// `ROLE_CALL_SCREENING` system role on Android.
///
/// Both the home hero card ("Bật ngay" button) and the Bảo Vệ tab
/// ([CallScreeningScreen]) watch this provider so toggling the role from
/// either surface keeps the other UI in sync.
class CallScreeningRoleProvider extends ChangeNotifier {
  CallScreeningRoleProvider({CallScreeningService? service})
      : _service = service ?? CallScreeningService();

  final CallScreeningService _service;

  bool _loading = true;
  bool _roleHeld = false;

  bool get loading => _loading;
  bool get roleHeld => _roleHeld;
  bool get supported => _service.isSupportedPlatform;

  /// Re-query the OS for the current role state. Cheap — safe to call on
  /// every lifecycle resume / tab change.
  Future<void> refresh() async {
    final held = await _service.isRoleHeld();
    if (_loading || held != _roleHeld) {
      _loading = false;
      _roleHeld = held;
      notifyListeners();
    }
  }

  /// Apply a known role state without re-querying. Used right after the
  /// system role dialog returns so the UI updates instantly without waiting
  /// for the next refresh cycle.
  void setRoleHeld(bool held) {
    if (_loading || held != _roleHeld) {
      _loading = false;
      _roleHeld = held;
      notifyListeners();
    }
  }
}
