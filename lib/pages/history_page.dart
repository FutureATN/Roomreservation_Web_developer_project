import 'package:flutter/material.dart';
import '../utils/session.dart';
import '../utils/app_colors.dart';

class HistoryPage extends StatefulWidget {
  final String role;
  const HistoryPage({super.key, required this.role});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  List<Map<String, String?>> _makeFakeHistory(String role) {
    final uname = (Session.username ?? '').trim();
    final now = DateTime.now();
    final rooms = ['Conference Room A', 'Meeting Room B', 'Seminar Room C', 'Study Room D'];
    final slots = ['8:00-10:00', '10:00-12:00', '13:00-15:00', '15:00-17:00'];
    final statuses = ['reserved', 'rejected'];

    String studentName() => uname.isNotEmpty ? uname : 'Student A';
    String lecturerName() => uname.isNotEmpty ? uname : 'Dr. Smith';

    String dateDaysAgo(int d) {
      final dt = now.subtract(Duration(days: d));
      final mm = dt.month.toString().padLeft(2, '0');
      final dd = dt.day.toString().padLeft(2, '0');
      return '${dt.year}-$mm-$dd';
    }

    final List<Map<String, String?>> list = [];

    if (role == 'student') {
      // History of himself/herself (3 items)
      for (int i = 0; i < 3; i++) {
        list.add({
          'room': rooms[i % rooms.length],
          'date': dateDaysAgo(i + 1),
          'time': slots[i % slots.length],
          'bookedBy': studentName(),
          'approvedBy': i % 2 == 0 ? lecturerName() : null,
          'status': statuses[i % statuses.length],
        });
      }
    } else if (role == 'lecturer') {
      // History of himself/herself as approver (3 items)
      for (int i = 0; i < 3; i++) {
        list.add({
          'room': rooms[(i + 1) % rooms.length],
          'date': dateDaysAgo(i + 1),
          'time': slots[(i + 1) % slots.length],
          'bookedBy': 'Student ${String.fromCharCode(65 + (i % 5))}',
          'approvedBy': lecturerName(),
          'status': statuses[i % statuses.length],
        });
      }
    } else {
      // Staff: history of all lecturers (3 items)
      final lecturers = ['Dr. Smith', 'Prof. Lee', 'Dr. Chan', 'Prof. Kumar'];
      for (int i = 0; i < 3; i++) {
        list.add({
          'room': rooms[(i + 2) % rooms.length],
          'date': dateDaysAgo(i + 1),
          'time': slots[(i + 2) % slots.length],
          'bookedBy': 'Student ${String.fromCharCode(65 + (i % 6))}',
          'approvedBy': lecturers[i % lecturers.length],
          'status': statuses[i % statuses.length],
        });
      }
    }

    return list;
  }

  Color _statusColor(String? s) => switch (s) {
        'reserved' => AppColors.success,
        'pending'  => AppColors.warning,
        'rejected' => AppColors.error,
        _ => AppColors.disabled,
      };

  @override
  Widget build(BuildContext context) {
    final items = _makeFakeHistory(widget.role);
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('History', style: TextStyle(fontWeight: FontWeight.w400, letterSpacing: 0.5)),
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      body: items.isEmpty
          ? const Center(child: Text('No history to show.'))
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (_, i) {
                final h = items[i];
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.surface, AppColors.surfaceLight],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.primary.withOpacity(0.3), width: 1),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: _statusColor(h['status']).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(Icons.history_outlined, color: _statusColor(h['status']), size: 24),
                    ),
                    title: Text(
                      '${h['room']} • ${(h['status'] ?? '').toUpperCase()}',
                      style: const TextStyle(fontWeight: FontWeight.w500, color: AppColors.textPrimary),
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
