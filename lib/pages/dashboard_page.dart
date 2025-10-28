import 'package:flutter/material.dart';
import 'room_list_page.dart';
import 'request_status_page.dart';
import 'approval_page.dart';
import 'manage_rooms_page.dart';
import 'history_page.dart';
import 'login_page.dart';

class DashboardPage extends StatelessWidget {
  final String role;
  const DashboardPage({super.key, required this.role});

  IconData _roleIcon(String r) {
    switch (r) {
      case 'student':
        return Icons.school;
      case 'lecturer':
        return Icons.person_outline; // safer across SDKs
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

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
        title: Row(
          children: [
            const Text('DASHBOARD', style: TextStyle(letterSpacing: 1.2)),
            const SizedBox(width: 8),
            Icon(_roleIcon(role)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const LoginPage()),
            ),
          ),
        ],
      ),
      drawer: _buildDrawer(context),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(
              "Today's Overview",
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold, color: Colors.blue.shade800),
            ),
            const SizedBox(height: 12),

            /// Responsive grid to avoid overflow on phones
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final isNarrow = constraints.maxWidth < 520; // phone-ish width
                  final childAspectRatio = isNarrow ? 0.85 : 1.25; // taller cards on phones

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

  Drawer _buildDrawer(BuildContext context) {
    return Drawer(
      child: ListView(padding: EdgeInsets.zero, children: [
        DrawerHeader(
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [Colors.blue.shade400, Colors.blue.shade700]),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const CircleAvatar(
                radius: 30,
                backgroundColor: Colors.white,
                child: Icon(Icons.person, size: 40, color: Colors.blue),
              ),
              const SizedBox(height: 10),
              Text(
                role == 'student'
                    ? 'Future'
                    : role == 'lecturer'
                        ? 'Boss'
                        : 'Staff',
                style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
              ),
              Text(
                role.toUpperCase(),
                style: const TextStyle(color: Colors.white70, fontSize: 14),
              ),
            ],
          ),
        ),
        ListTile(
          leading: const Icon(Icons.dashboard),
          title: const Text('Dashboard'),
          onTap: () => Navigator.pop(context),
        ),
        ListTile(
          leading: const Icon(Icons.meeting_room),
          title: const Text('Browse Rooms'),
          onTap: () {
            Navigator.pop(context);
            Navigator.push(context, MaterialPageRoute(builder: (_) => RoomListPage(role: role)));
          },
        ),
        if (role == 'student')
          ListTile(
            leading: const Icon(Icons.check_circle),
            title: const Text('My Requests'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (_) => const RequestStatusPage()));
            },
          ),
        if (role == 'lecturer')
          ListTile(
            leading: const Icon(Icons.approval),
            title: const Text('Booking Requests'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (_) => const ApprovalPage()));
            },
          ),
        if (role == 'staff')
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Manage Rooms'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (_) => const ManageRoomsPage()));
            },
          ),
        ListTile(
          leading: const Icon(Icons.history),
          title: const Text('History'),
          onTap: () {
            Navigator.pop(context);
            Navigator.push(context, MaterialPageRoute(builder: (_) => HistoryPage(role: role)));
          },
        ),
        const Divider(),
        ListTile(
          leading: const Icon(Icons.logout, color: Colors.red),
          title: const Text('Logout', style: TextStyle(color: Colors.red)),
          onTap: () => Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const LoginPage()),
          ),
        ),
      ]),
    );
  }
}

/// --- tiny model + compact card ---

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
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [stat.color.withOpacity(.7), stat.color.withOpacity(.9)],
          ),
        ),
        child: Column(
          children: [
            const Spacer(),
            Icon(stat.icon, size: 36, color: Colors.white), // slightly smaller
            const SizedBox(height: 6),
            Text(
              stat.count,
              maxLines: 1,
              overflow: TextOverflow.fade,
              style: const TextStyle(
                fontSize: 26, // smaller to avoid overflow
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 6),
            Flexible(
              child: Text(
                stat.title,
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}
