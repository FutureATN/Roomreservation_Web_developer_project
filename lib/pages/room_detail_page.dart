import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/date_utils.dart';
import 'booking_confirm_page.dart';
import '../utils/booking_state.dart';
import '../utils/app_colors.dart';

class RoomDetailPage extends StatelessWidget {
  final Map<String, dynamic> room;
  final String role;
  const RoomDetailPage({super.key, required this.room, required this.role});

  // ========== API SERVICE ==========
  static const String _baseUrl = 'http://192.168.240.1:3001'; // ← YOUR IP

  Future<Map<String, dynamic>> _fetchRoomDetails() async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/api/rooms/${room['id']}'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['room'] ?? room; // Return API data or fallback to passed room
      } else {
        print('Failed to load room details: ${response.statusCode}');
        return room; // Return passed room as fallback
      }
    } catch (e) {
      print('Error fetching room details: $e');
      return room; // Return passed room as fallback
    }
  }
  // ========== END API SERVICE ==========

  final List<Map<String, String>> timeSlots = const [
    {'time': '8:00-10:00',  'status': 'free'},
    {'time': '10:00-12:00', 'status': 'pending'},
    {'time': '13:00-15:00', 'status': 'reserved'},
    {'time': '15:00-17:00', 'status': 'free'},
  ];

  Color _color(String s) {
    switch (s) {
      case 'free': return Colors.green;
      case 'pending': return Colors.orange;
      case 'reserved': return Colors.red;
      case 'disabled': return Colors.grey;
      default: return Colors.grey;
    }
  }

  IconData _icon(String s) {
    switch (s) {
      case 'free': return Icons.check_circle;
      case 'pending': return Icons.pending;
      case 'reserved': return Icons.event_busy;
      case 'disabled': return Icons.block;
      default: return Icons.help;
    }
  }

  @override
  Widget build(BuildContext context) {
    final todayStr = formatTodayLong();
    final now = DateTime.now();

    // SAFE reads — no `as String` casts.
    final name  = (room['name'] ?? 'Unknown Room').toString();
    final floor = room['floor'] is int ? room['floor'] as int : int.tryParse('${room['floor']}') ?? 0;
    final cap   = room['capacity'] is int ? room['capacity'] as int : int.tryParse('${room['capacity']}') ?? 0;

    return Scaffold(
      appBar: AppBar(
        title: Text(name),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [Colors.blue.shade400, Colors.blue.shade700]),
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Icon(Icons.meeting_room, size: 60, color: Colors.white),
              const SizedBox(height: 10),
              Text(name, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
              const SizedBox(height: 5),
              Text('Floor $floor • Capacity: $cap people',
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
                final status = (slot['status'] ?? 'disabled').toString();
                final time   = (slot['time'] ?? '').toString();
                final parts = time.split('-');
                final start = parts.isNotEmpty ? parts.first : '';
                int sh = 0, sm = 0;
                if (start.contains(':')) {
                  final hm = start.split(':');
                  sh = int.tryParse(hm[0]) ?? 0;
                  sm = int.tryParse(hm[1]) ?? 0;
                }
                final slotStart = DateTime(now.year, now.month, now.day, sh, sm);
                final isPast = now.isAfter(slotStart);
                final hasBooked = role == 'student' && BookingState.hasBookedToday();

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
                    title: Text(time, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    subtitle: Row(children: [
                      Icon(_icon(status), size: 16, color: _color(status)),
                      const SizedBox(width: 5),
                      Text(status.toUpperCase(),
                          style: TextStyle(color: _color(status), fontWeight: FontWeight.w600)),
                    ]),
                    trailing: role == 'student' && status == 'free' && !isPast && !hasBooked
                        ? FilledButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => BookingConfirmPage(room: room, timeSlot: time),
                                ),
                              );
                            },
                            child: const Text('Book'),
                          )
                        : null,
                  ),
                );
              }).toList(),
            ]),
          ),
        ]),
      ),
    );
  }
}