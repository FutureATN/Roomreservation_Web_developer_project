// lib/utils/booking_state.dart
class BookingState {
  static int? _currentUserId;
  static DateTime? _lastBookedDate; // date-only (no time)

  /// Read current user
  static int? get currentUserId => _currentUserId;

  /// Set current user; when user changes, we reset "has booked today" memory
  static set currentUserId(int? value) {
    if (value != _currentUserId) {
      _currentUserId = value;
      _lastBookedDate = null; // reset per-user booking memory
    }
  }

  /// Mark that the current user has booked something *today*
  static void markBookedNow() {
    if (_currentUserId == null) return;
    final now = DateTime.now();
    _lastBookedDate = DateTime(now.year, now.month, now.day);
  }

  /// In case you want to clear everything completely (used on logout)
  static void clearCurrentUser() {
    _currentUserId = null;
    _lastBookedDate = null;
  }

  /// Local fallback: has this user booked *today* on this device?
  /// (Primary source of truth is still the server /api/bookings/today)
  static bool hasBookedToday() {
    if (_currentUserId == null || _lastBookedDate == null) return false;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return _lastBookedDate == today;
  }
}
