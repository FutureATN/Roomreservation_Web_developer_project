import 'package:flutter/material.dart';

class RequestStatusPage extends StatefulWidget {
  const RequestStatusPage({super.key});

  @override
  State<RequestStatusPage> createState() => _RequestStatusPageState();
}

class _RequestStatusPageState extends State<RequestStatusPage> {
  final List<Map<String, dynamic>> _requests = [
    {'room': 'Conference Room A','date': '2025-10-21','time': '10:00-12:00','status': 'pending','approvedBy': null,'requestedBy': 'John Doe'},
    {'room': 'Meeting Room B','date': '2025-10-20','time': '13:00-15:00','status': 'approved','approvedBy': 'Dr. Smith','requestedBy': 'John Doe'},
    {'room': 'Study Room D','date': '2025-10-18','time': '8:00-10:00','status': 'rejected','approvedBy': 'Dr. Smith','requestedBy': 'John Doe'},
  ];

  Color _color(String s) => switch (s) {
        'approved' => Colors.green,
        'pending'  => Colors.orange,
        'rejected' => Colors.red,
        _ => Colors.grey,
      };

  IconData _icon(String s) => switch (s) {
        'approved' => Icons.check_circle,
        'pending'  => Icons.pending,
        'rejected' => Icons.cancel,
        _ => Icons.help_outline,
      };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MY REQUESTS'),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _requests.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (_, i) {
          final r = _requests[i];
          final status = r['status'] as String;
          return Card(
            elevation: 3,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              leading: CircleAvatar(
                backgroundColor: _color(status),
                child: Icon(_icon(status), color: Colors.white),
              ),
              title: Text(r['room'] as String,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Date: ${r['date']}   Time: ${r['time']}'),
                  const SizedBox(height: 4),
                  Text(
                    'Status: ${status.toUpperCase()}${r['approvedBy'] != null ? " • by ${r['approvedBy']}" : ""}',
                    style: TextStyle(color: _color(status), fontWeight: FontWeight.w600),
                  ),
                ]),
              ),
            ),
          );
        },
      ),
    );
  }
}
