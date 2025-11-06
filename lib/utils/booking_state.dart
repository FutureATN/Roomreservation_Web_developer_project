class BookingState {
  static DateTime? _lastBookedAt;

  static var userId;

  static bool hasBookedToday() {
    if (_lastBookedAt == null) return false;
    final now = DateTime.now();
    return _lastBookedAt!.year == now.year &&
        _lastBookedAt!.month == now.month &&
        _lastBookedAt!.day == now.day;
  }

  static void markBookedNow() {
    _lastBookedAt = DateTime.now();
  }
}
