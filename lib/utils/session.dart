import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Session {
  static int? userId;
  static String? username;
  static String? role;
  static String? token; // <-- JWT or any auth token

  // UI can listen to these
  static final ValueNotifier<int?> userId$ = ValueNotifier<int?>(null);
  static final ValueNotifier<String?> username$ = ValueNotifier<String?>(null);
  static final ValueNotifier<String?> role$ = ValueNotifier<String?>(null);
  static final ValueNotifier<String?> token$ = ValueNotifier<String?>(null);

  // Keys for SharedPreferences
  static const _kUserId = 'session_user_id';
  static const _kUsername = 'session_username';
  static const _kRole = 'session_role';
  static const _kToken = 'session_token';

  /// True if we have a non-empty token (you can change logic if you prefer)
  static bool get isLoggedIn => token != null && token!.isNotEmpty;

  /// Load session from storage (call in main() before runApp)
  static Future<void> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // support both int and string-stored ids (legacy)
      int? storedId = prefs.getInt(_kUserId);
      if (storedId == null) {
        final idStr = prefs.getString(_kUserId);
        if (idStr != null) storedId = int.tryParse(idStr);
      }

      final storedName = prefs.getString(_kUsername);
      final storedRole = prefs.getString(_kRole);
      final storedToken = prefs.getString(_kToken);

      userId = storedId;
      username = storedName;
      role = storedRole;
      token = storedToken;

      userId$.value = userId;
      username$.value = username;
      role$.value = role;
      token$.value = token;
    } catch (e, st) {
      debugPrint('Session.load failed: $e\n$st');
    }
  }

  /// Set current session (use after successful login)
  static Future<void> set({
    required int id,
    required String name,
    required String r,
    String? t, // optional token
  }) async {
    try {
      userId = id;
      username = name;
      role = r;
      token = t;

      userId$.value = id;
      username$.value = name;
      role$.value = r;
      token$.value = t;

      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_kUserId, id);
      await prefs.setString(_kUsername, name);
      await prefs.setString(_kRole, r);
      if (t != null && t.isNotEmpty) {
        await prefs.setString(_kToken, t);
      } else {
        await prefs.remove(_kToken);
      }
    } catch (e, st) {
      debugPrint('Session.set failed: $e\n$st');
    }
  }

  /// Clear session (use on logout)
  static Future<void> clear() async {
    try {
      userId = null;
      username = null;
      role = null;
      token = null;

      userId$.value = null;
      username$.value = null;
      role$.value = null;
      token$.value = null;

      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_kUserId);
      await prefs.remove(_kUsername);
      await prefs.remove(_kRole);
      await prefs.remove(_kToken);
    } catch (e, st) {
      debugPrint('Session.clear failed: $e\n$st');
    }
  }
}
