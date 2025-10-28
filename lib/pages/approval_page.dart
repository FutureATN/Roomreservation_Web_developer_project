import 'package:flutter/material.dart';

class ApprovalPage extends StatefulWidget {
  const ApprovalPage({super.key});

  @override
  State<ApprovalPage> createState() => _ApprovalPageState();
}

class _ApprovalPageState extends State<ApprovalPage> {
  List<Map<String, dynamic>> _pending = [
    {'id': 101,'room': 'Conference Room A','date': '2025-10-21','time': '10:00-12:00','status': 'pending','requestedBy': 'John Doe'},
    {'id': 102,'room': 'Seminar Room C','date': '2025-10-21','time': '13:00-15:00','status': 'pending','requestedBy': 'Jane Student'},
  ];

  void _actOn(int id, bool approve) {
    setState(() {
      _pending = _pending.map((e) {
        if (e['id'] == id) {
          final copy = Map<String, dynamic>.from(e);
          copy['status'] = approve ? 'approved' : 'rejected';
          copy['actedAt'] = DateTime.now().toIso8601String();
          copy['approvedBy'] = 'Dr. Smith';
          return copy;
        }
        return e;
      }).toList();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(approve ? 'Request approved' : 'Request rejected')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final items = _pending;
    return Scaffold(
      appBar: AppBar(
        title: const Text('BOOKING APPROVALS'),
         backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (_, i) {
          final r = items[i];
          final status = r['status'] as String;
          final isPending = status == 'pending';
          final chipColor = status == 'pending' ? Colors.orange : (status == 'approved' ? Colors.green : Colors.red);

          return Card(
            elevation: 3,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(r['room'] as String, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                const SizedBox(height: 6),
                Text('Date: ${r['date']}  •  Time: ${r['time']}'),
                Text('Requested by: ${r['requestedBy']}'),
                const SizedBox(height: 12),
                Row(children: [
                  Container(
                  decoration: BoxDecoration(color: chipColor, borderRadius: BorderRadius.circular(24)),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: Text(status.toUpperCase(), style: const TextStyle(color: Colors.white)),
                  ),
                  const Spacer(),
                  if (isPending) ...[
                  OutlinedButton.icon(
                    onPressed: () => _actOn(r['id'] as int, false),
                    icon: const Icon(Icons.close, color: Colors.red, size: 18),
                    label: const Text('Reject', style: TextStyle(fontSize: 14)),
                    style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    minimumSize: Size.zero,
                    ),
                  ),
                  const SizedBox(width: 8),
                  FilledButton.icon(
                    onPressed: () => _actOn(r['id'] as int, true),
                    icon: const Icon(Icons.check_circle, size: 18),
                    label: const Text('Approve', style: TextStyle(fontSize: 14)),
                    style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    minimumSize: Size.zero,
                    ),
                  ),
                  ],
                ]),
              ]),
            ),
          );
        },
      ),
    );
  }
}
