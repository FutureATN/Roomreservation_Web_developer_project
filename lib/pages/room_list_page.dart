import 'package:flutter/material.dart';
import '../utils/date_utils.dart';
import 'room_detail_page.dart';

class RoomListPage extends StatelessWidget {
  final String role;
  RoomListPage({super.key, required this.role});

  final List<Map<String, dynamic>> rooms = const [
    {'id': 1, 'name': 'Conference Room A', 'capacity': 20, 'floor': 1},
    {'id': 2, 'name': 'Meeting Room B',  'capacity': 10, 'floor': 2},
    {'id': 3, 'name': 'Seminar Room C',  'capacity': 50, 'floor': 3},
    {'id': 4, 'name': 'Study Room D',    'capacity': 8,  'floor': 1},
  ];

  @override
  Widget build(BuildContext context) {
    final todayStr = formatTodayLong();
    return Scaffold(
      appBar: AppBar(
        title: const Text('BROWSE ROOMS'),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Card(
            color: Colors.blue.shade50,
            child: Padding(
              padding: const EdgeInsets.all(15),
              child: Row(children: [
                const Icon(Icons.info_outline, color: Colors.blue),
                const SizedBox(width: 10),
                Expanded(
                  child: Text('Showing availability for today: $todayStr',
                      style: TextStyle(color: Colors.blue.shade900)),
                ),
              ]),
            ),
          ),
          const SizedBox(height: 15),
          Expanded(
            child: ListView.builder(
              itemCount: rooms.length,
              itemBuilder: (context, index) {
                final r = rooms[index];
                return Card(
                  elevation: 3,
                  margin: const EdgeInsets.only(bottom: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(15),
                    leading: const CircleAvatar(
                      backgroundColor: Colors.blue,
                      child: Icon(Icons.meeting_room, color: Colors.white),
                    ),
                    title: Text(r['name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                    subtitle: Text('Floor ${r['floor']} • Capacity: ${r['capacity']} people'),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(
                        builder: (_) => RoomDetailPage(room: r, role: role),
                      ));
                    },
                  ),
                );
              },
            ),
          ),
        ]),
      ),
    );
  }
}
