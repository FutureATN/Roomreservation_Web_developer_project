import 'package:flutter/material.dart';

class HistoryPage extends StatefulWidget {
  final String role;
  const HistoryPage({super.key, required this.role});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  final List<Map<String, String?>> _log = [
    {'room': 'Meeting Room B','date': '2025-10-20','time': '13:00-15:00','bookedBy': 'John Doe','approvedBy': 'Dr. Smith','status': 'reserved'},
    {'room': 'Study Room D','date': '2025-10-18','time': '8:00-10:00','bookedBy': 'John Doe','approvedBy': 'Dr. Smith','status': 'rejected'},
    {'room': 'Seminar Room C','date': '2025-10-21','time': '13:00-15:00','bookedBy': 'Jane Student','approvedBy': 'Dr. Smith','status': 'reserved'},
    {'room': 'Conference Room A','date': '2025-10-21','time': '10:00-12:00','bookedBy': 'John Doe','approvedBy': null,'status': 'pending'},
  ];

  List<Map<String, String?>> _filtered(String role) {
    if (role == 'student') {
      return _log.where((e) => e['bookedBy'] == 'John Doe').toList();
    } else if (role == 'lecturer') {
      return _log.where((e) => (e['approvedBy'] ?? '').isNotEmpty).toList();
    } else {
      return _log;
    }
  }

  Color _statusColor(String? s) => switch (s) {
        'reserved' => Colors.green,
        'pending'  => Colors.orange,
        'rejected' => Colors.red,
        _ => Colors.grey,
      };

  @override
  Widget build(BuildContext context) {
    final items = _filtered(widget.role);
    return Scaffold(
      appBar: AppBar(
        
        title: const Text('HISTORY'),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
      ),
      body: items.isEmpty
          ? const Center(child: Text('No history to show.'))
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (_, i) {
                final h = items[i];
                return Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    leading: CircleAvatar(
                      backgroundColor: _statusColor(h['status']),
                      child: const Icon(Icons.history, color: Colors.white),
                    ),
                    title: Text(
                      '${h['room']} • ${(h['status'] ?? '').toUpperCase()}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text('Date: ${h['date']}   •  Time: ${h['time']}'),
                        Text('Booked by: ${h['bookedBy']}'),
                        Text('Approved by: ${h['approvedBy'] ?? "-"}'),
                      ]),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
