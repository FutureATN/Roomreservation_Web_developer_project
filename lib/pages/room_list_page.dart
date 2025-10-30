import 'package:flutter/material.dart';
import '../utils/date_utils.dart';
import '../utils/booking_state.dart';

class RoomListPage extends StatefulWidget {
  final String role;
  RoomListPage({super.key, required this.role});

  @override
  State<RoomListPage> createState() => _RoomListPageState();
}

class _RoomListPageState extends State<RoomListPage> {
  final PageController _pageController = PageController(viewportFraction: 0.9);

  // You can fetch from API later; keep types dynamic but read safely.
  final List<Map<String, dynamic>> rooms = const [
    {'id': 1, 'name': 'Conference Room A', 'capacity': 20, 'floor': 1},
    {'id': 2, 'name': 'Meeting Room B', 'capacity': 10, 'floor': 2},
    {'id': 3, 'name': 'Seminar Room C', 'capacity': 50, 'floor': 3},
    {'id': 4, 'name': 'Study Room D', 'capacity': 8, 'floor': 1},
    // Example of a partially-missing item that USED to crash:
    // {'id': 5, 'capacity': 6, 'floor': 2},
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  List<Map<String, String>> get _timeSlots => const [
        {'time': '8:00-10:00', 'status': 'free'},
        {'time': '10:00-12:00', 'status': 'free'},
        {'time': '13:00-15:00', 'status': 'free'},
        {'time': '15:00-17:00', 'status': 'free'},
      ];

  @override
  Widget build(BuildContext context) {
    final todayStr = formatTodayLong();
    final now = DateTime.now();
    final isStudent = widget.role == 'student';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Browse Rooms'),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              color: Colors.blue.shade50,
              child: Padding(
                padding: const EdgeInsets.all(15),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, color: Colors.blue),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Showing availability for today: $todayStr',
                        style: TextStyle(color: Colors.blue.shade900),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: rooms.length,
                itemBuilder: (context, index) {
                  final r = rooms[index];
                  final name = (r['name'] ?? 'Unknown Room').toString();
                  final floor = r['floor'] is int ? r['floor'] as int : int.tryParse('${r['floor']}') ?? 0;
                  final cap = r['capacity'] is int ? r['capacity'] as int : int.tryParse('${r['capacity']}') ?? 0;

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const CircleAvatar(
                                  backgroundColor: Colors.blue,
                                  child: Icon(Icons.meeting_room, color: Colors.white),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                                      Text('Floor $floor • Capacity: $cap people'),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Text('Today\'s Time Slots', style: TextStyle(fontSize: 16, color: Colors.blue.shade900, fontWeight: FontWeight.w600)),
                            const SizedBox(height: 8),
                            Expanded(
                              child: GridView.builder(
                                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  mainAxisSpacing: 10,
                                  crossAxisSpacing: 10,
                                  childAspectRatio: 2.6,
                                ),
                                itemCount: _timeSlots.length,
                                itemBuilder: (context, i) {
                                  final slot = _timeSlots[i];
                                  final time = (slot['time'] ?? '').toString();
                                  final start = time.split('-').first;
                                  int sh = 0, sm = 0;
                                  if (start.contains(':')) {
                                    final hm = start.split(':');
                                    sh = int.tryParse(hm[0]) ?? 0;
                                    sm = int.tryParse(hm[1]) ?? 0;
                                  }
                                  final slotStart = DateTime(now.year, now.month, now.day, sh, sm);
                                  final isPast = now.isAfter(slotStart);
                                  final hasBooked = isStudent && BookingState.hasBookedToday();
                                  final enabled = isStudent && !isPast && !hasBooked;

                                  return ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: enabled ? Colors.blue : Colors.grey.shade400,
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    ),
                                    onPressed: enabled
                                        ? () => _showBookingDialog(context, r, time)
                                        : null,
                                    child: Text(time),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showBookingDialog(BuildContext context, Map<String, dynamic> room, String timeSlot) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Row(children: const [
          Icon(Icons.check_circle, color: Colors.blue, size: 28),
          SizedBox(width: 8),
          Text('Confirm Booking'),
        ]),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Room: ${room['name']}'),
            Text("Date: ${formatTodayLong()}"),
            Text('Time: $timeSlot'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              BookingState.markBookedNow();
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Booking submitted and pending approval.')),
              );
            },
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }
}
