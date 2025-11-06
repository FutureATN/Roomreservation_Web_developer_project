// lib/pages/room_list_page.dart
import 'dart:convert';
import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:roomreservation/utils/session.dart';

import '../utils/date_utils.dart';      // formatTodayLong()
import '../utils/booking_state.dart';   // BookingState.hasBookedToday(), markBookedNow()
import '../utils/app_colors.dart';
import 'booking_confirm_page.dart';     // (optional) if you want to navigate after booking

class RoomListPage extends StatefulWidget {
  final String role; // 'student' | 'lecturer' | 'staff'
  const RoomListPage({super.key, required this.role});

  @override
  State<RoomListPage> createState() => _RoomListPageState();
}

class _RoomListPageState extends State<RoomListPage> {
  // ---------- BASE URL ----------
  // Use 10.0.2.2 for Android emulator; for real device, pass your PC LAN IP at runtime:
  // flutter run --dart-define=API_BASE_URL=http://192.168.1.23:3001
static const String _baseUrl = 'http://192.168.238.1:3001';

  // ---------- STATE ----------
  final PageController _pageController = PageController(viewportFraction: 0.92);
  int _currentPage = 0;
  List<Map<String, dynamic>> rooms = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadRooms();
    _pageController.addListener(() {
      final p = _pageController.page;
      if (p != null) {
        final next = p.round();
        if (_currentPage != next) setState(() => _currentPage = next);
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // ---------- API: ROOMS ----------
  Future<void> _loadRooms() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final data = await _fetchRooms();
      setState(() {
        rooms = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<List<Map<String, dynamic>>> _fetchRooms() async {
    try {
      final uri = Uri.parse('$_baseUrl/api/rooms');
      final response = await http.get(uri, headers: {'Accept': 'application/json'});

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);

        // Accept either: [{...}, {...}] OR { success:true, data:[...] }
        if (decoded is List) {
          return decoded.cast<Map<String, dynamic>>();
        } else if (decoded is Map && decoded['data'] is List) {
          return (decoded['data'] as List).cast<Map<String, dynamic>>();
        } else {
          throw Exception('Unexpected /api/rooms payload: ${response.body}');
        }
      }

      // Fallback data if server returns non-200 (useful while wiring)
      return const [
        {'id': 1, 'name': 'Conference Room A', 'capacity': 20, 'floor': 1},
        {'id': 2, 'name': 'Meeting Room B', 'capacity': 10, 'floor': 2},
        {'id': 3, 'name': 'Seminar Room C', 'capacity': 50, 'floor': 3},
        {'id': 4, 'name': 'Study Room D', 'capacity': 8,  'floor': 1},
      ];
    } catch (e) {
      // Fallback on network error, so UI still works
      return const [
        {'id': 1, 'name': 'Conference Room A', 'capacity': 20, 'floor': 1},
        {'id': 2, 'name': 'Meeting Room B', 'capacity': 10, 'floor': 2},
        {'id': 3, 'name': 'Seminar Room C', 'capacity': 50, 'floor': 3},
        {'id': 4, 'name': 'Study Room D', 'capacity': 8,  'floor': 1},
      ];
    }
  }

  // ---------- API: CREATE BOOKING ----------
  String _todayIso() {
    final now = DateTime.now();
    final mm = now.month.toString().padLeft(2, '0');
    final dd = now.day.toString().padLeft(2, '0');
    return '${now.year}-$mm-$dd';
  }

  Future<void> _submitBooking({
    required int userId,
    required int roomId,
    required String timeSlot,
  }) async {
    final uri = Uri.parse('$_baseUrl/api/bookings');
    final res = await http.post(
      uri,
      headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
      body: jsonEncode({
        'user_id': userId,
        'room_id': roomId,
        'booking_date': _todayIso(),
        'time_slot': timeSlot,
      }),
    );

    if (res.statusCode != 200) {
      throw Exception('HTTP ${res.statusCode}: ${res.body}');
    }
    final body = json.decode(res.body);
    if (body is! Map || body['success'] != true) {
      throw Exception('Bad payload: $body');
    }
  }

  // ---------- TIMESLOTS ----------
  List<Map<String, String>> get _timeSlots => const [
        {'time': '8:00-10:00',  'status': 'free'},
        {'time': '10:00-12:00', 'status': 'free'},
        {'time': '13:00-15:00', 'status': 'free'},
        {'time': '18:00-21:00', 'status': 'free'},
      ];

  // ---------- DIALOG ----------
  void _showBookingDialog(BuildContext context, Map<String, dynamic> room, String timeSlot) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.check_circle_outline, color: AppColors.primary, size: 24),
            const SizedBox(width: 12),
            const Text('Confirm Booking', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDialogRow(Icons.meeting_room_outlined, 'Room', '${room['name']}'),
            const SizedBox(height: 12),
            _buildDialogRow(Icons.calendar_today_outlined, 'Date', formatTodayLong()),
            const SizedBox(height: 12),
            _buildDialogRow(Icons.access_time_outlined, 'Time', timeSlot),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () async {
  Navigator.of(context).pop();

  final snack = ScaffoldMessenger.of(context);

  // ✅ ใช้ Session.userId
  final userId = Session.userId;  // <— ต้องไม่เป็น null
  final roomId = room['id'] is int
      ? room['id'] as int
      : int.tryParse('${room['id']}') ?? 0;

  if (userId == null || roomId == 0) {
    snack.showSnackBar(const SnackBar(
      content: Text('Missing userId or roomId'),
      backgroundColor: AppColors.error,
    ));
    return;
  }

  try {
    snack.showSnackBar(const SnackBar(content: Text('Submitting booking...')));
    await _submitBooking(userId: userId, roomId: roomId, timeSlot: timeSlot);

    BookingState.markBookedNow();
    snack.showSnackBar(const SnackBar(
      content: Text('Booking submitted successfully'),
      backgroundColor: AppColors.primary,
    ));
    setState(() {}); // รีเฟรชสถานะปุ่ม
  } catch (e) {
    snack.showSnackBar(SnackBar(
      content: Text('Booking failed: $e'),
      backgroundColor: AppColors.error,
    ));
  }
},

            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }

  Widget _buildDialogRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.primary),
        const SizedBox(width: 12),
        Text('$label: ', style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  // ---------- UI ----------
  @override
  Widget build(BuildContext context) {
    final todayStr = formatTodayLong();
    final now = DateTime.now();
    final isStudent = widget.role == 'student';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        centerTitle: false,
        title: const Text(
          'Browse Rooms',
          style: TextStyle(fontWeight: FontWeight.w300, fontSize: 24, letterSpacing: 0.5),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20, color: AppColors.textSecondary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? _Error(message: _error!, onRetry: _loadRooms)
              : Column(
                  children: [
                    // Date banner
                    Container(
                      margin: const EdgeInsets.all(16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: [AppColors.surface, AppColors.surfaceLight]),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.primary.withOpacity(0.3), width: 1),
                        boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.1), blurRadius: 8, offset: Offset(0, 2))],
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.calendar_today_outlined, color: AppColors.primary, size: 20),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(todayStr, style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w400)),
                          ),
                        ],
                      ),
                    ),

                    // Page indicators
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(rooms.length, (index) {
                        return Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: _currentPage == index ? 24 : 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: _currentPage == index ? AppColors.primary : AppColors.primaryLight,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 16),

                    // Room cards
                    Expanded(
                      child: PageView.builder(
                        controller: _pageController,
                        itemCount: rooms.length,
                        itemBuilder: (context, index) {
                          final r = rooms[index];
                          final name = (r['name'] ?? 'Unknown Room').toString();
                          final floor = r['floor'] is int ? r['floor'] as int : int.tryParse('${r['floor']}') ?? 0;
                          final cap   = r['capacity'] is int ? r['capacity'] as int : int.tryParse('${r['capacity']}') ?? 0;

                          return Container(
                            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [AppColors.surface, AppColors.surfaceLight],
                              ),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: AppColors.primary.withOpacity(0.3), width: 1),
                              boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.15), blurRadius: 12, offset: Offset(0, 4))],
                            ),
                            child: Column(
                              children: [
                                // Header
                                Container(
                                  padding: const EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(colors: [AppColors.primary.withOpacity(0.2), AppColors.accent.withOpacity(0.2)]),
                                    borderRadius: const BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(12)),
                                        child: Icon(Icons.meeting_room_outlined, color: AppColors.primary, size: 28),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w500, color: AppColors.textPrimary)),
                                            const SizedBox(height: 4),
                                            Text('Floor $floor • $cap people', style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                // Time slots
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.all(20),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text('Available Time Slots',
                                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.textPrimary, letterSpacing: 0.5)),
                                        const SizedBox(height: 16),
                                        Expanded(
                                          child: GridView.builder(
                                            physics: const NeverScrollableScrollPhysics(),
                                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                              crossAxisCount: 2,
                                              mainAxisSpacing: 12,
                                              crossAxisSpacing: 12,
                                              childAspectRatio: 2.5,
                                            ),
                                            itemCount: _timeSlots.length,
                                            itemBuilder: (context, i) {
                                              final slot = _timeSlots[i];
                                              final time = (slot['time'] ?? '').toString();

                                              // Disable past slots & enforce student can only book once per day
                                              final now = DateTime.now();
                                              final startStr = time.split('-').first;
                                              int sh = 0, sm = 0;
                                              if (startStr.contains(':')) {
                                                final hm = startStr.split(':');
                                                sh = int.tryParse(hm[0]) ?? 0;
                                                sm = int.tryParse(hm[1]) ?? 0;
                                              }
                                              final slotStart = DateTime(now.year, now.month, now.day, sh, sm);
                                              final isPast = now.isAfter(slotStart);
                                              final hasBooked = (widget.role == 'student') && BookingState.hasBookedToday();
                                              final enabled = (widget.role == 'student') && !isPast && !hasBooked;

                                              return InkWell(
                                                onTap: enabled ? () => _showBookingDialog(context, r, time) : null,
                                                borderRadius: BorderRadius.circular(12),
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                    gradient: enabled
                                                        ? LinearGradient(colors: [AppColors.primary.withOpacity(0.2), AppColors.accent.withOpacity(0.2)])
                                                        : null,
                                                    color: enabled ? null : AppColors.disabled.withOpacity(0.3),
                                                    borderRadius: BorderRadius.circular(12),
                                                    border: Border.all(color: enabled ? AppColors.primary : AppColors.disabled, width: enabled ? 1.5 : 1),
                                                    boxShadow: enabled
                                                        ? [BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 2))]
                                                        : null,
                                                  ),
                                                  child: Center(
                                                    child: Text(
                                                      time,
                                                      style: TextStyle(
                                                        fontSize: 13,
                                                        fontWeight: FontWeight.w500,
                                                        color: enabled ? AppColors.primary : AppColors.textSecondary,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
    );
  }
}

class _Error extends StatelessWidget {
  final String message;
  final Future<void> Function() onRetry;
  const _Error({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48, color: AppColors.error),
            const SizedBox(height: 12),
            Text('Failed to load rooms:\n$message', textAlign: TextAlign.center, style: const TextStyle(color: AppColors.textPrimary)),
            const SizedBox(height: 16),
            FilledButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}
