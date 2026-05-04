import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

/// Stores a stable per-install random UUID used to attribute Supabase rows to
/// a device without requiring sign-in. Generated once on first launch.
class DeviceIdService {
  DeviceIdService();

  static const _key = 'device_id_v1';
  String? _cached;

  Future<String> get() async {
    if (_cached != null) return _cached!;
    final prefs = await SharedPreferences.getInstance();
    var id = prefs.getString(_key);
    if (id == null || id.isEmpty) {
      id = const Uuid().v4();
      await prefs.setString(_key, id);
    }
    _cached = id;
    return id;
  }

  /// Clear the persisted device id so the next call to [get] generates a new
  /// one. Used by the "Reset toàn bộ dữ liệu" flow so that history rows the
  /// user creates next don't conflict with the previous device's rows in
  /// Supabase.
  Future<void> reset() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
    _cached = null;
  }
}
