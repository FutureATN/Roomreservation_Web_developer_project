// lib/pages/dashboard_page.dart
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../utils/app_colors.dart';
import '../utils/session.dart';
import 'room_list_page.dart';
import '../widgets/app_scaffold.dart';

class ApiConfig {
  static const String baseUrl = 'http://192.168.238.1:3001/api';
}

class DashboardPage extends StatefulWidget {
  final String role; // fallback from login
  const DashboardPage({super.key, required this.role});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  // dynamic stats (initially zero so UI still looks OK before load)
  List<_Stat> _stats = const <_Stat>[
    _Stat('Free Slots', '0', Icons.check_circle, Colors.green),
    _Stat('Pending Requests', '0', Icons.pending, Colors.orange),
    _Stat('Reserved Slots', '0', Icons.event_busy, Colors.red),
    _Stat('Disabled Rooms', '0', Icons.block, Colors.grey),
  ];

  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

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

  Future<void> _loadStats() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      // today as YYYY-MM-DD
      final now = DateTime.now();
      final dateStr =
          '${now.year.toString().padLeft(4, '0')}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

      final uri = Uri.parse('${ApiConfig.baseUrl}/dashboard/summary')
          .replace(queryParameters: {'date': dateStr});

      final res = await http.get(uri, headers: {'Accept': 'application/json'});

      if (res.statusCode != 200) {
        throw Exception('HTTP ${res.statusCode}: ${res.body}');
      }

      final body = jsonDecode(res.body);
      if (body is! Map || body['success'] != true) {
        throw Exception('Bad payload: $body');
      }

      final data = body['data'] as Map<String, dynamic>? ?? {};
      final freeSlots = (data['freeSlots'] ?? 0).toString();
      final pendingRequests = (data['pendingRequests'] ?? 0).toString();
      final reservedSlots = (data['reservedSlots'] ?? 0).toString();
      final disabledRooms = (data['disabledRooms'] ?? 0).toString();

      if (!mounted) return;
      setState(() {
        _stats = <_Stat>[
          _Stat('Free Slots', freeSlots, Icons.check_circle, Colors.green),
          _Stat('Pending Requests', pendingRequests, Icons.pending, Colors.orange),
          _Stat('Reserved Slots', reservedSlots, Icons.event_busy, Colors.red),
          _Stat('Disabled Rooms', disabledRooms, Icons.block, Colors.grey),
        ];
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Today's Overview",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w300,
                color: AppColors.textPrimary,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 4),
            // small loading/error line under the title
            if (_loading)
              const LinearProgressIndicator(minHeight: 2)
            else if (_error != null)
              Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Text(
                  'Failed to load stats: $_error',
                  style: const TextStyle(
                    color: AppColors.error,
                    fontSize: 12,
                  ),
                ),
              ),
            const SizedBox(height: 12),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final isNarrow = constraints.maxWidth < 520;
                  final childAspectRatio = isNarrow ? 0.85 : 1.25;

                  return RefreshIndicator(
                    onRefresh: _loadStats,
                    child: GridView.builder(
                      itemCount: _stats.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: childAspectRatio,
                      ),
                      itemBuilder: (context, i) =>
                          _StatCard(stat: _stats[i]),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
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
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.surface, AppColors.surfaceLight],
        ),
        borderRadius: BorderRadius.circular(16),
        border:
            Border.all(color: AppColors.primary.withOpacity(0.3), width: 1),
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
