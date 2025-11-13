// lib/widgets/app_drawer.dart
import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../utils/session.dart';
import '../utils/booking_state.dart';

import '../pages/room_list_page.dart';
import '../pages/request_status_page.dart';
import '../pages/approval_page.dart';
import '../pages/manage_rooms_page.dart';
import '../pages/history_page.dart';
import '../pages/login_page.dart';
import '../pages/dashboard_page.dart';

class AppDrawer extends StatelessWidget {
  final String roleNow; // "student" | "staff" | "lecturer"
  const AppDrawer({super.key, required this.roleNow});

  @override
  Widget build(BuildContext context) {
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
                begin: Alignment.topLeft, end: Alignment.bottomRight,
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
                        ValueListenableBuilder<String?>(
                          valueListenable: Session.username$,
                          builder: (_, name, __) => Text(
                            (name ?? Session.username ?? 'Guest'),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
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

          // Dashboard => HIDE for students
          if (roleNow != 'student')
            ListTile(
              leading: const Icon(Icons.dashboard_outlined, color: AppColors.primary, size: 22),
              title: const Text('Dashboard', style: TextStyle(color: AppColors.textPrimary, fontSize: 16)),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => DashboardPage(role: roleNow)),
                );
              },
            ),

          ListTile(
            leading: const Icon(Icons.meeting_room_outlined, color: AppColors.primary, size: 22),
            title: const Text('Browse Rooms', style: TextStyle(color: AppColors.textPrimary, fontSize: 16)),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => RoomListPage(role: roleNow)),
              );
            },
          ),

          if (roleNow == 'student')
            ListTile(
              leading: const Icon(Icons.check_circle_outline, color: AppColors.primary, size: 22),
              title: const Text('My Requests', style: TextStyle(color: AppColors.textPrimary, fontSize: 16)),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const RequestStatusPage()),
                );
              },
            ),

          if (roleNow == 'lecturer')
            ListTile(
              leading: const Icon(Icons.approval_outlined, color: AppColors.primary, size: 22),
              title: const Text('Booking Requests', style: TextStyle(color: AppColors.textPrimary, fontSize: 16)),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const ApprovalPage()),
                );
              },
            ),

          if (roleNow == 'staff')
            ListTile(
              leading: const Icon(Icons.settings_outlined, color: AppColors.primary, size: 22),
              title: const Text('Manage Rooms', style: TextStyle(color: AppColors.textPrimary, fontSize: 16)),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const ManageRoomsPage()),
                );
              },
            ),

          ListTile(
            leading: const Icon(Icons.history_outlined, color: AppColors.primary, size: 22),
            title: const Text('History', style: TextStyle(color: AppColors.textPrimary, fontSize: 16)),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => HistoryPage(role: roleNow)),
              );
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
