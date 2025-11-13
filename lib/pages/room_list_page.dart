// lib/pages/room_list_page.dart
import 'dart:convert';
import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../widgets/app_scaffold.dart';
import '../utils/session.dart';
import '../utils/date_utils.dart';
import '../utils/booking_state.dart';
import '../utils/app_colors.dart';

class RoomListPage extends StatefulWidget {
  final String role; // 'student' | 'lecturer' | 'staff'
  const RoomListPage({super.key, required this.role});

  @override
  State<RoomListPage> createState() => _RoomListPageState();
}

class _RoomListPageState extends State<RoomListPage> {
  // roomId|timeSlot -> 'pending' | 'approved'
  final Map<String, String> _slotStatus = {};

  // -------- BASE URL (เลือกอัตโนมัติ) --------
  String get _baseUrl {
    const fromEnv = String.fromEnvironment('API_BASE_URL', defaultValue: '');
    if (fromEnv.isNotEmpty) return fromEnv;
    if (Platform.isAndroid) return 'http://192.168.238.1:3001'; // emulator
    return 'http://127.0.0.1:3001';
  }

  final PageController _pageController = PageController(viewportFraction: 0.92);
  int _currentPage = 0;

  List<Map<String, dynamic>> rooms = [];
  bool _isLoading = true;
  String? _error;

  // ✅ สถานะ “วันนี้จองไปแล้วหรือยัง” จากฝั่งเซิร์ฟเวอร์
  bool _hasBookedTodayServer = false;

  @override
  void initState() {
    super.initState();
    _initPage();
    _pageController.addListener(() {
      final p = _pageController.page;
      if (p != null) {
        final next = p.round();
        if (_currentPage != next) setState(() => _currentPage = next);
      }
    });
  }

  Future<void> _initPage() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      await Future.wait([
        _refreshBookedTodayFlag(),
        _loadRooms(),
        _loadAvailability(), // 👈 โหลดสถานะห้องที่ถูกจองแล้ว
      ]);
      setState(() => _isLoading = false);
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // ---------- helpers ----------
  String _todayIso() {
    final now = DateTime.now();
    final mm = now.month.toString().padLeft(2, '0');
    final dd = now.day.toString().padLeft(2, '0');
    return '${now.year}-$mm-$dd';
  }

  // ---------- API: check “booked today?” (server) ----------
  Future<void> _refreshBookedTodayFlag() async {
    final uid = Session.userId;
    if (uid == null) {
      _hasBookedTodayServer = false;
      return;
    }
    final uri = Uri.parse('$_baseUrl/api/bookings/today')
        .replace(queryParameters: {'userId': '$uid', 'date': _todayIso()});

    try {
      final res = await http.get(uri, headers: {'Accept': 'application/json'});
      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);
        final booked = (body is Map && body['success'] == true)
            ? (body['booked'] == true)
            : false;

        setState(() {
          _hasBookedTodayServer = booked;
        });

        if (booked) {
          BookingState.markBookedNow();
        }
      } else {
        setState(() => _hasBookedTodayServer = BookingState.hasBookedToday());
      }
    } catch (_) {
      setState(() => _hasBookedTodayServer = BookingState.hasBookedToday());
    }
  }

  // ---------- API: availability (ห้องที่ถูกจองแล้ว) ----------
  Future<void> _loadAvailability() async {
    final uri = Uri.parse('$_baseUrl/api/availability')
        .replace(queryParameters: {'date': _todayIso()});

    try {
      final res = await http.get(uri, headers: {'Accept': 'application/json'});
      if (res.statusCode != 200) {
        throw Exception('HTTP ${res.statusCode}: ${res.body}');
      }
      final body = jsonDecode(res.body);
      if (body is! Map || body['success'] != true) {
        throw Exception('Bad payload: $body');
      }

      final List data = body['data'] as List;
      final Map<String, String> map = {};
      for (final raw in data) {
        final m = raw as Map<String, dynamic>;
        final roomId = m['room_id'];
        final time = m['time_slot'] ?? m['time'];
        if (roomId == null || time == null) continue;
        final key = '${roomId.toString()}|${time.toString()}';
        map[key] = (m['status'] ?? '').toString(); // pending / approved
      }

      setState(() {
        _slotStatus
          ..clear()
          ..addAll(map);
      });
    } catch (e) {
      debugPrint('loadAvailability error: $e');
    }
  }

  // ---------- API: rooms ----------
  Future<void> _loadRooms() async {
    final data = await _fetchRooms();
    setState(() => rooms = data);
  }

  Future<List<Map<String, dynamic>>> _fetchRooms() async {
    try {
      final uri = Uri.parse('$_baseUrl/api/rooms');
      final response =
          await http.get(uri, headers: {'Accept': 'application/json'});

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        if (decoded is List) {
          return decoded.cast<Map<String, dynamic>>();
        } else if (decoded is Map && decoded['data'] is List) {
          return (decoded['data'] as List).cast<Map<String, dynamic>>();
        } else {
          throw Exception('Unexpected /api/rooms payload: ${response.body}');
        }
      }

      // fallback
      return const [
        {'id': 1, 'name': 'Conference Room A', 'capacity': 20, 'floor': 1},
        {'id': 2, 'name': 'Meeting Room B', 'capacity': 10, 'floor': 2},
        {'id': 3, 'name': 'Seminar Room C', 'capacity': 50, 'floor': 3},
        {'id': 4, 'name': 'Study Room D', 'capacity': 8, 'floor': 1},
      ];
    } catch (_) {
      return const [
        {'id': 1, 'name': 'Conference Room A', 'capacity': 20, 'floor': 1},
        {'id': 2, 'name': 'Meeting Room B', 'capacity': 10, 'floor': 2},
        {'id': 3, 'name': 'Seminar Room C', 'capacity': 50, 'floor': 3},
        {'id': 4, 'name': 'Study Room D', 'capacity': 8, 'floor': 1},
      ];
    }
  }

  // ---------- API: create booking ----------
  Future<void> _submitBooking({
    required int userId,
    required int roomId,
    required String timeSlot,
  }) async {
    final uri = Uri.parse('$_baseUrl/api/bookings');
    final res = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
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
      final msg = (body is Map && body['message'] != null)
          ? body['message'].toString()
          : 'Bad payload: $body';
      throw Exception(msg);
    }
  }

  // ---------- timeslots ----------
  List<Map<String, String>> get _timeSlots => const [
        {'time': '1:00-3:00', 'status': 'free'},
        {'time': '4:00-5:00', 'status': 'free'},
        {'time': '13:00-15:00', 'status': 'free'},
        {'time': '18:00-21:00', 'status': 'free'},
      ];

  // ---------- dialog ----------
  void _showBookingDialog(
      BuildContext context, Map<String, dynamic> room, String timeSlot) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.check_circle_outline,
                color: AppColors.primary, size: 24),
            const SizedBox(width: 12),
            const Text('Confirm Booking',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDialogRow(
                Icons.meeting_room_outlined, 'Room', '${room['name']}'),
            const SizedBox(height: 12),
            _buildDialogRow(
                Icons.calendar_today_outlined, 'Date', formatTodayLong()),
            const SizedBox(height: 12),
            _buildDialogRow(
                Icons.access_time_outlined, 'Time', timeSlot),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel',
                style: TextStyle(color: AppColors.textSecondary)),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              elevation: 0,
              shape:
                  RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () async {
              Navigator.of(context).pop();
              final snack = ScaffoldMessenger.of(context);

              final userId = Session.userId;
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
                snack.showSnackBar(
                    const SnackBar(content: Text('Submitting booking...')));
                await _submitBooking(
                    userId: userId, roomId: roomId, timeSlot: timeSlot);

                // sync ทั้ง server และ client
                BookingState.markBookedNow();
                setState(() => _hasBookedTodayServer = true);
                await _loadAvailability(); // 👈 โหลดสถานะใหม่หลังจอง

                snack.showSnackBar(const SnackBar(
                  content: Text('Booking submitted successfully'),
                  backgroundColor: AppColors.primary,
                ));
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
        Text('$label: ',
            style: const TextStyle(
                fontWeight: FontWeight.w500, fontSize: 14)),
        Expanded(
          child: Text(
            value,
            style:
                const TextStyle(fontSize: 14, color: AppColors.textSecondary),
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
    final roleNow = (Session.role ?? widget.role).toLowerCase();
    final isStudent = roleNow == 'student';

    return AppScaffold(
      title: 'Browse Rooms',
      actions: [
        IconButton(
          tooltip: 'Refresh booking rule',
          onPressed: () async {
            await _refreshBookedTodayFlag();
            await _loadAvailability();
          },
          icon: const Icon(Icons.refresh),
        ),
      ],
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? _Error(message: _error!, onRetry: _initPage)
              : Column(
                  children: [
                    // date & rule banner
                    Container(
                      margin: const EdgeInsets.all(16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                            colors: [AppColors.surface, AppColors.surfaceLight]),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: AppColors.primary.withOpacity(0.3),
                            width: 1),
                        boxShadow: [
                          BoxShadow(
                              color:
                                  AppColors.primary.withOpacity(0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 2))
                        ],
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_today_outlined,
                              color: AppColors.primary, size: 20),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(todayStr,
                                    style: const TextStyle(
                                        color: AppColors.textPrimary,
                                        fontWeight: FontWeight.w400)),
                                if (isStudent && _hasBookedTodayServer)
                                  const Padding(
                                    padding: EdgeInsets.only(top: 6),
                                    child: Text(
                                      'You have already made a booking today.',
                                      style: TextStyle(
                                          color: AppColors.warning,
                                          fontSize: 12),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: () async {
                              await _refreshBookedTodayFlag();
                              await _loadAvailability();
                            },
                            icon: const Icon(Icons.sync),
                            tooltip: 'Sync from server',
                          )
                        ],
                      ),
                    ),

                    // page indicators
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(rooms.length, (index) {
                        return Container(
                          margin:
                              const EdgeInsets.symmetric(horizontal: 4),
                          width: _currentPage == index ? 24 : 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: _currentPage == index
                                ? AppColors.primary
                                : AppColors.primaryLight,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 16),

                    // room cards
                    Expanded(
                      child: PageView.builder(
                        controller: _pageController,
                        itemCount: rooms.length,
                        itemBuilder: (context, index) {
                          final r = rooms[index];
                          final name =
                              (r['name'] ?? 'Unknown Room').toString();
                          final floor = r['floor'] is int
                              ? r['floor'] as int
                              : int.tryParse('${r['floor']}') ?? 0;
                          final cap = r['capacity'] is int
                              ? r['capacity'] as int
                              : int.tryParse('${r['capacity']}') ?? 0;
                          final roomId = r['id'] is int
                              ? r['id'] as int
                              : int.tryParse('${r['id']}') ?? 0;

                          return Container(
                            margin: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 8),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  AppColors.surface,
                                  AppColors.surfaceLight
                                ],
                              ),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                  color:
                                      AppColors.primary.withOpacity(0.3),
                                  width: 1),
                              boxShadow: [
                                BoxShadow(
                                    color: AppColors.primary
                                        .withOpacity(0.15),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4))
                              ],
                            ),
                            child: Column(
                              children: [
                                // header
                                Container(
                                  padding: const EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                        colors: [
                                          AppColors.primary
                                              .withOpacity(0.2),
                                          AppColors.accent
                                              .withOpacity(0.2)
                                        ]),
                                    borderRadius: const BorderRadius.only(
                                        topLeft: Radius.circular(20),
                                        topRight: Radius.circular(20)),
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                            color: AppColors.surface,
                                            borderRadius:
                                                BorderRadius.circular(12)),
                                        child: const Icon(
                                            Icons.meeting_room_outlined,
                                            color: AppColors.primary,
                                            size: 28),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(name,
                                                style: const TextStyle(
                                                    fontSize: 20,
                                                    fontWeight:
                                                        FontWeight.w500,
                                                    color: AppColors
                                                        .textPrimary)),
                                            const SizedBox(height: 4),
                                            Text(
                                                'Floor $floor • $cap people',
                                                style: const TextStyle(
                                                    fontSize: 13,
                                                    color: AppColors
                                                        .textSecondary)),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                // time slots
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.all(20),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Available Time Slots',
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                            color: AppColors.textPrimary,
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                        const SizedBox(height: 16),
                                        Expanded(
                                          child: GridView.builder(
                                            physics:
                                                const NeverScrollableScrollPhysics(),
                                            gridDelegate:
                                                const SliverGridDelegateWithFixedCrossAxisCount(
                                              crossAxisCount: 2,
                                              mainAxisSpacing: 12,
                                              crossAxisSpacing: 12,
                                              childAspectRatio: 2.5,
                                            ),
                                            itemCount: _timeSlots.length,
                                            itemBuilder: (context, i) {
                                              final slot = _timeSlots[i];
                                              final time =
                                                  (slot['time'] ?? '')
                                                      .toString();

                                              // parse time range
                                              final now = DateTime.now();
                                              final parts =
                                                  time.split('-');
                                              int sh = 0, sm = 0;
                                              int eh = 23, em = 59;
                                              if (parts.isNotEmpty &&
                                                  parts.first
                                                      .contains(':')) {
                                                final hm = parts.first
                                                    .split(':');
                                                sh = int.tryParse(
                                                        hm[0]) ??
                                                    0;
                                                sm = int.tryParse(
                                                        hm[1]) ??
                                                    0;
                                              }
                                              if (parts.length > 1 &&
                                                  parts[1]
                                                      .contains(':')) {
                                                final hm = parts[1]
                                                    .split(':');
                                                eh = int.tryParse(
                                                        hm[0]) ??
                                                    23;
                                                em = int.tryParse(
                                                        hm[1]) ??
                                                    59;
                                              }
                                              final slotStart =
                                                  DateTime(
                                                      now.year,
                                                      now.month,
                                                      now.day,
                                                      sh,
                                                      sm);
                                              final slotEnd = DateTime(
                                                  now.year,
                                                  now.month,
                                                  now.day,
                                                  eh,
                                                  em);

                                              final isPast =
                                                  now.isAfter(slotEnd);

                                              // status from server
                                              final key =
                                                  '${roomId.toString()}|$time';
                                              final serverStatus =
                                                  _slotStatus[key];
                                              final isBookedSlot =
                                                  serverStatus ==
                                                          'pending' ||
                                                      serverStatus ==
                                                          'approved';

                                              // can user tap?
                                              final enabled =
                                                  (roleNow ==
                                                          'student') &&
                                                      !isPast &&
                                                      !_hasBookedTodayServer &&
                                                      !isBookedSlot;

                                              // สี + label
                                              String statusLabel;
                                              Color borderColor;
                                              Color textColor;
                                              Gradient? gradient;

                                              if (isBookedSlot) {
                                                statusLabel =
                                                    serverStatus ==
                                                            'approved'
                                                        ? 'RESERVED'
                                                        : 'PENDING';
                                                borderColor = serverStatus ==
                                                        'approved'
                                                    ? AppColors.error
                                                    : AppColors.warning;
                                                textColor =
                                                    borderColor;
                                              } else if (isPast) {
                                                statusLabel = 'PAST';
                                                borderColor =
                                                    AppColors.disabled;
                                                textColor = AppColors
                                                    .textSecondary;
                                              } else {
                                                statusLabel = 'FREE';
                                                if (enabled) {
                                                  borderColor =
                                                      AppColors
                                                          .primary;
                                                  textColor =
                                                      AppColors
                                                          .primary;
                                                  gradient =
                                                      LinearGradient(
                                                    colors: [
                                                      AppColors.primary
                                                          .withOpacity(
                                                              0.2),
                                                      AppColors.accent
                                                          .withOpacity(
                                                              0.2),
                                                    ],
                                                  );
                                                } else {
                                                  borderColor =
                                                      AppColors
                                                          .disabled;
                                                  textColor = AppColors
                                                      .textSecondary;
                                                }
                                              }

                                              return InkWell(
                                                onTap: enabled
                                                    ? () =>
                                                        _showBookingDialog(
                                                            context,
                                                            r,
                                                            time)
                                                    : null,
                                                borderRadius:
                                                    BorderRadius
                                                        .circular(12),
                                                child: Container(
                                                  decoration:
                                                      BoxDecoration(
                                                    gradient:
                                                        gradient,
                                                    color: gradient ==
                                                            null
                                                        ? AppColors
                                                            .surfaceLight
                                                        : null,
                                                    borderRadius:
                                                        BorderRadius
                                                            .circular(
                                                                12),
                                                    border: Border.all(
                                                        color:
                                                            borderColor,
                                                        width: enabled
                                                            ? 1.5
                                                            : 1),
                                                    boxShadow: enabled
                                                        ? [
                                                            BoxShadow(
                                                              color: AppColors
                                                                  .primary
                                                                  .withOpacity(
                                                                      0.3),
                                                              blurRadius:
                                                                  8,
                                                              offset:
                                                                  const Offset(
                                                                      0,
                                                                      2),
                                                            )
                                                          ]
                                                        : null,
                                                  ),
                                                  child: Center(
                                                    child: Column(
                                                      mainAxisSize:
                                                          MainAxisSize
                                                              .min,
                                                      children: [
                                                        Text(
                                                          time,
                                                          style:
                                                              TextStyle(
                                                            fontSize:
                                                                13,
                                                            fontWeight:
                                                                FontWeight
                                                                    .w600,
                                                            color:
                                                                textColor,
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                            height:
                                                                4),
                                                        Text(
                                                          statusLabel,
                                                          style:
                                                              TextStyle(
                                                            fontSize:
                                                                11,
                                                            fontWeight:
                                                                FontWeight
                                                                    .w500,
                                                            color:
                                                                textColor.withOpacity(
                                                                    0.9),
                                                          ),
                                                        ),
                                                      ],
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
            const Icon(Icons.error_outline,
                size: 48, color: AppColors.error),
            const SizedBox(height: 12),
            Text(
              'Failed to load:\n$message',
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textPrimary),
            ),
            const SizedBox(height: 16),
            FilledButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}
