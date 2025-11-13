// lib/pages/dashboard_page.dart
import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../utils/session.dart';
import 'room_list_page.dart';
import '../widgets/app_scaffold.dart';

class DashboardPage extends StatefulWidget {
  final String role; // fallback from login
  const DashboardPage({super.key, required this.role});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final stats = const <_Stat>[
    _Stat('Free Slots', '12', Icons.check_circle, Colors.green),
    _Stat('Pending Requests', '5', Icons.pending, Colors.orange),
    _Stat('Reserved Slots', '8', Icons.event_busy, Colors.red),
    _Stat('Disabled Rooms', '2', Icons.block, Colors.grey),
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final roleNow = (Session.role ?? widget.role).toLowerCase();
    // 🚫 Hide dashboard for students: redirect
    if (roleNow == 'student') {
      Future.microtask(() {
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => RoomListPage(role: roleNow)),
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final roleNow = (Session.role ?? widget.role).toLowerCase();

    return AppScaffold(
      title: 'Dashboard',
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text(
            "Today's Overview",
            style: TextStyle(
              fontSize: 24, fontWeight: FontWeight.w300,
              color: AppColors.textPrimary, letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isNarrow = constraints.maxWidth < 520;
                final childAspectRatio = isNarrow ? 0.85 : 1.25;

                return GridView.builder(
                  itemCount: stats.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12,
                    childAspectRatio: childAspectRatio,
                  ),
                  itemBuilder: (context, i) => _StatCard(stat: stats[i]),
                );
              },
            ),
          ),
        ]),
      ),
    );
  }
}

/* ------------ small model + card ------------ */

class _Stat {
  final String title;
  final String count;
  final IconData icon;
  final Color color;
  const _Stat(this.title, this.count, this.icon, this.color);
}

class _StatCard extends StatelessWidget {
  final _Stat stat;
  const _StatCard({required this.stat});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft, end: Alignment.bottomRight,
          colors: [AppColors.surface, AppColors.surfaceLight],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withOpacity(0.3), width: 1),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.1),
            blurRadius: 8, offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          const Spacer(),
          Icon(stat.icon, size: 32, color: AppColors.primary),
          const SizedBox(height: 6),
          Text(
            stat.count,
            maxLines: 1, overflow: TextOverflow.fade,
            style: const TextStyle(
              fontSize: 32, fontWeight: FontWeight.w300, color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Flexible(
            child: Text(
              stat.title,
              textAlign: TextAlign.center, overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppColors.textSecondary, fontWeight: FontWeight.w400, fontSize: 12,
              ),
            ),
          ),
          const Spacer(),
        ],
      ),
    );
  }
}
