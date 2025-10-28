String formatTodayLong() {
  final now = DateTime.now();
  const months = [
    'January','February','March','April','May','June',
    'July','August','September','October','November','December'
  ];
  return '${months[now.month - 1]} ${now.day}, ${now.year}';
}
