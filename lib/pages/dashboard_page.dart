// lib/pages/dashboard_page.dart
import 'package:flutter/material.dart';

import 'room_list_page.dart';
import 'request_status_page.dart';
import 'approval_page.dart';
import 'manage_rooms_page.dart';
import 'history_page.dart';
import 'login_page.dart';

import '../utils/app_colors.dart';
import '../utils/session.dart';
import '../utils/booking_state.dart';

class DashboardPage extends StatelessWidget {
  final String role; // รับมาจากหน้า Login (fallback เฉยๆ)
  const DashboardPage({super.key, required this.role});

  IconData _roleIcon(String r) {
    switch (r) {
      case 'student':
        return Icons.school;
      case 'lecturer':
        return Icons.person_outline;
      case 'staff':
        return Icons.admin_panel_settings;
      default:
        return Icons.person;
    }
  }

  @override
  Widget build(BuildContext context) {
    final stats = const <_Stat>[
      _Stat('Free Slots', '12', Icons.check_circle, Colors.green),
      _Stat('Pending Requests', '5', Icons.pending, Colors.orange),
      _Stat('Reserved Slots', '8', Icons.event_busy, Colors.red),
      _Stat('Disabled Rooms', '2', Icons.block, Colors.grey),
    ];

    // ใช้ค่าจาก Session ถ้ามี (สดกว่า), ถ้าไม่มีค่อย fallback เป็น role จาก constructor
    final roleNow = (Session.role ?? role).toLowerCase();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        title: Row(
          children: [
            const Text(
              'Dashboard',
              style: TextStyle(letterSpacing: 0.5, fontWeight: FontWeight.w400),
            ),
            const SizedBox(width: 8),
            Icon(_roleIcon(roleNow), size: 20, color: AppColors.primary),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_outlined, color: AppColors.textSecondary),
            onPressed: () {
              // ล้าง session ให้เกลี้ยง
              Session.clear();
              BookingState.clearCurrentUser();
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const LoginPage()),
                (route) => false,
              );
            },
          ),
        ],
      ),
      drawer: _buildDrawer(context, roleNow),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text(
              "Today's Overview",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w300,
                color: AppColors.textPrimary,
                letterSpacing: 0.5,
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
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: childAspectRatio,
                    ),
                    itemBuilder: (context, i) => _StatCard(stat: stats[i]),
                  );
                },
              ),
            ),
          ]),
        ),
      ),
    );
  }

  Drawer _buildDrawer(BuildContext context, String roleNow) {
    return Drawer(
      backgroundColor: AppColors.background,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            margin: EdgeInsets.zero,
            padding: EdgeInsets.zero,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.primary, AppColors.accent],
              ),
            ),
            child: Container(
              padding: const EdgeInsets.fromLTRB(16, 28, 16, 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.white.withOpacity(0.25),
                    child: const Icon(Icons.person_outline, size: 36, color: Colors.white),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ชื่อผู้ใช้ — ฟังการเปลี่ยนแปลงแบบสดจาก Session
                        ValueListenableBuilder<String?>(
                          valueListenable: Session.username$,
                          builder: (_, name, __) => Text(
                            (name ?? Session.username ?? 'Guest'),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        // บทบาท — ฟังการเปลี่ยนแปลงแบบสดจาก Session
                        ValueListenableBuilder<String?>(
                          valueListenable: Session.role$,
                          builder: (_, r, __) => Text(
                            (r ?? roleNow).toUpperCase(),
                            style: const TextStyle(color: Colors.white70, fontSize: 14),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // --- เมนู ---
          ListTile(
            leading: const Icon(Icons.dashboard_outlined, color: AppColors.primary, size: 22),
            title: const Text('Dashboard', style: TextStyle(color: AppColors.textPrimary, fontSize: 16)),
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            leading: const Icon(Icons.meeting_room_outlined, color: AppColors.primary, size: 22),
            title: const Text('Browse Rooms', style: TextStyle(color: AppColors.textPrimary, fontSize: 16)),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (_) => RoomListPage(role: roleNow)));
            },
          ),

          if (roleNow == 'student')
            ListTile(
              leading: const Icon(Icons.check_circle_outline, color: AppColors.primary, size: 22),
              title: const Text('My Requests', style: TextStyle(color: AppColors.textPrimary, fontSize: 16)),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const RequestStatusPage()));
              },
            ),

          if (roleNow == 'lecturer')
            ListTile(
              leading: const Icon(Icons.approval_outlined, color: AppColors.primary, size: 22),
              title: const Text('Booking Requests', style: TextStyle(color: AppColors.textPrimary, fontSize: 16)),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const ApprovalPage()));
              },
            ),

          if (roleNow == 'staff')
            ListTile(
              leading: const Icon(Icons.settings_outlined, color: AppColors.primary, size: 22),
              title: const Text('Manage Rooms', style: TextStyle(color: AppColors.textPrimary, fontSize: 16)),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const ManageRoomsPage()));
              },
            ),

          ListTile(
            leading: const Icon(Icons.history_outlined, color: AppColors.primary, size: 22),
            title: const Text('History', style: TextStyle(color: AppColors.textPrimary, fontSize: 16)),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (_) => HistoryPage(role: roleNow)));
            },
          ),

          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.logout_outlined, color: AppColors.textSecondary, size: 22),
            title: const Text('Logout', style: TextStyle(color: AppColors.textSecondary, fontSize: 16)),
            onTap: () {
              Session.clear();
              BookingState.clearCurrentUser();
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const LoginPage()),
                (route) => false,
              );
            },
          ),
        ],
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
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.surface, AppColors.surfaceLight],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withOpacity(0.3), width: 1),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
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
            maxLines: 1,
            overflow: TextOverflow.fade,
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w300,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Flexible(
            child: Text(
              stat.title,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w400,
                fontSize: 12,
              ),
            ),
          ),
          const Spacer(),
        ],
      ),
    );
  }
}
