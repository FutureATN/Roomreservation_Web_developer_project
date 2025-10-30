import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

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
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        centerTitle: false,
        title: const Text(
          'Booking Approvals',
          style: TextStyle(
            fontWeight: FontWeight.w300,
            fontSize: 24,
            letterSpacing: 0.5,
          ),
        ),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (_, i) {
          final r = items[i];
          final status = r['status'] as String;
          final isPending = status == 'pending';
          final chipColor = status == 'pending' ? AppColors.warning : (status == 'approved' ? AppColors.success : AppColors.error);

          return Container(
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
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(r['room'] as String, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 18, color: AppColors.textPrimary)),
                const SizedBox(height: 6),
                Text('Date: ${r['date']}  •  Time: ${r['time']}', style: const TextStyle(color: AppColors.textSecondary, fontSize: 14)),
                Text('Requested by: ${r['requestedBy']}', style: const TextStyle(color: AppColors.textSecondary, fontSize: 14)),
                const SizedBox(height: 12),
                Row(children: [
                  Container(
                    decoration: BoxDecoration(
                      color: chipColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: chipColor, width: 1),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    child: Text(
                      status.toUpperCase(),
                      style: TextStyle(color: chipColor, fontSize: 12, fontWeight: FontWeight.w500),
                    ),
                  ),
                  const Spacer(),
                  if (isPending) ...[
                  OutlinedButton.icon(
                    onPressed: () => _actOn(r['id'] as int, false),
                    icon: Icon(Icons.close_outlined, color: AppColors.error, size: 18),
                    label: const Text('Reject', style: TextStyle(fontSize: 14, color: AppColors.error)),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.error, width: 1),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      minimumSize: Size.zero,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  FilledButton.icon(
                    onPressed: () => _actOn(r['id'] as int, true),
                    icon: const Icon(Icons.check_circle_outline, size: 18),
                    label: const Text('Approve', style: TextStyle(fontSize: 14)),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.background,
                      elevation: 0,
                      shadowColor: AppColors.primary.withOpacity(0.5),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      minimumSize: Size.zero,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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
