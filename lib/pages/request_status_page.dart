import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

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
        'approved' => AppColors.success,
        'pending'  => AppColors.warning,
        'rejected' => AppColors.error,
        _ => AppColors.disabled,
      };

  IconData _icon(String s) => switch (s) {
        'approved' => Icons.check_circle_outline,
        'pending'  => Icons.pending_outlined,
        'rejected' => Icons.cancel_outlined,
        _ => Icons.help_outline,
      };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        centerTitle: false,
        title: const Text(
          'My Requests',
          style: TextStyle(
            fontWeight: FontWeight.w300,
            fontSize: 24,
            letterSpacing: 0.5,
          ),
        ),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _requests.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (_, i) {
          final r = _requests[i];
          final status = r['status'] as String;
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
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: _color(status).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(_icon(status), color: _color(status), size: 24),
              ),
              title: Text(r['room'] as String,
                  style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 18, color: AppColors.textPrimary)),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Date: ${r['date']}   Time: ${r['time']}', style: const TextStyle(color: AppColors.textSecondary, fontSize: 14)),
                  const SizedBox(height: 4),
                  Container(
                    margin: const EdgeInsets.only(top: 4),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: _color(status).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: _color(status), width: 1),
                    ),
                    child: Text(
                      '${status.toUpperCase()}${r['approvedBy'] != null ? " • by ${r['approvedBy']}" : ""}',
                      style: TextStyle(color: _color(status), fontWeight: FontWeight.w500, fontSize: 12),
                    ),
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
