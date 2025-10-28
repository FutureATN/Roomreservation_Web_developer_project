import 'package:flutter/material.dart';
import '../utils/date_utils.dart';
import 'booking_confirm_page.dart';

class RoomDetailPage extends StatelessWidget {
  final Map<String, dynamic> room;
  final String role;
  const RoomDetailPage({super.key, required this.room, required this.role});

  final List<Map<String, String>> timeSlots = const [
    {'time': '8:00-10:00',  'status': 'free'},
    {'time': '10:00-12:00', 'status': 'pending'},
    {'time': '13:00-15:00', 'status': 'reserved'},
    {'time': '15:00-17:00', 'status': 'free'},
  ];

  Color _color(String s) => switch (s) {
        'free' => Colors.green,
        'pending' => Colors.orange,
        'reserved' => Colors.red,
        'disabled' => Colors.grey,
        _ => Colors.grey,
      };

  IconData _icon(String s) => switch (s) {
        'free' => Icons.check_circle,
        'pending' => Icons.pending,
        'reserved' => Icons.event_busy,
        'disabled' => Icons.block,
        _ => Icons.help,
      };

  @override
  Widget build(BuildContext context) {
    final todayStr = formatTodayLong();
    return Scaffold(
      appBar: AppBar(
        title: Text(room['NAME'] as String),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            width: double.infinity, padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(gradient: LinearGradient(colors: [Colors.blue.shade400, Colors.blue.shade700])),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Icon(Icons.meeting_room, size: 60, color: Colors.white),
              const SizedBox(height: 10),
              Text(room['name'] as String,
                  style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
              const SizedBox(height: 5),
              Text('Floor ${room['floor']} • Capacity: ${room['capacity']} people',
                  style: const TextStyle(fontSize: 16, color: Colors.white70)),
            ]),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Available Time Slots - Today ($todayStr)',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.blue.shade800)),
              const SizedBox(height: 15),
              ...timeSlots.map((slot) {
                final status = slot['status']!;
                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: _color(status), width: 2),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    leading: Icon(Icons.access_time, size: 40, color: _color(status)),
                    title: Text(slot['time']!, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    subtitle: Row(children: [
                      Icon(_icon(status), size: 16, color: _color(status)),
                      const SizedBox(width: 5),
                      Text(status.toUpperCase(), style: TextStyle(color: _color(status), fontWeight: FontWeight.w600)),
                    ]),
                    trailing: role == 'student' && status == 'free'
                        ? FilledButton(
                            onPressed: () {
                              Navigator.push(context, MaterialPageRoute(
                                builder: (_) => BookingConfirmPage(room: room, timeSlot: slot['time']!),
                              ));
                            },
                            child: const Text('Book'),
                          )
                        : null,
                  ),
                );
              }).toList(),
              const SizedBox(height: 20),
              _legend(),
            ]),
          ),
        ]),
      ),
    );
  }

  Widget _legend() {
    return Card(
      color: Colors.grey.shade100,
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Status Legend', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 10),
          Row(children: [
            _legendItem('Free', Colors.green), const SizedBox(width: 20),
            _legendItem('Pending', Colors.orange),
          ]),
          const SizedBox(height: 8),
          Row(children: [
            _legendItem('Reserved', Colors.red), const SizedBox(width: 20),
            _legendItem('Disabled', Colors.grey),
          ]),
        ]),
      ),
    );
  }

  Widget _legendItem(String label, Color color) {
    return Row(children: [
      Container(width: 20, height: 20, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
      const SizedBox(width: 8),
      Text(label),
    ]);
  }
}
