class BookingState {
  /// Who is currently logged in (set after login)
  static int? currentUserId;

  /// Track last booking time **per user**
  static final Map<int, DateTime> _lastBookedAtByUser = {};

  static bool hasBookedToday() {
    final uid = currentUserId;
    if (uid == null) return false;
    final last = _lastBookedAtByUser[uid];
    if (last == null) return false;

    final now = DateTime.now();
    return last.year == now.year &&
        last.month == now.month &&
        last.day == now.day;
  }

  static void markBookedNow() {
    final uid = currentUserId;
    if (uid == null) return;
    _lastBookedAtByUser[uid] = DateTime.now();
  }

  /// Optional: call on logout if you want to clear the in-memory mark
  static void clearCurrentUser() {
    currentUserId = null;
  }
}
