import 'package:flutter/foundation.dart';

class Session {
  static int? userId;
  static String? username;
  static String? role;

  // ให้ UI ฟังการเปลี่ยนแปลงแบบ live
  static final ValueNotifier<int?> userId$ = ValueNotifier<int?>(null);
  static final ValueNotifier<String?> username$ = ValueNotifier<String?>(null);
  static final ValueNotifier<String?> role$ = ValueNotifier<String?>(null);

  static void set({required int id, required String name, required String r}) {
    userId = id;
    username = name;
    role = r;
    userId$.value = id;
    username$.value = name;
    role$.value = r;
  }

  static void clear() {
    set(id: -1, name: 'Guest', r: '');
    userId = null;
    username = null;
    role = null;
    userId$.value = null;
    username$.value = null;
    role$.value = null;
  }
}
