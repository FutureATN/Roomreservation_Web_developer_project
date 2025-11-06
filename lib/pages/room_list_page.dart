import 'package:flutter/material.dart';
import '../utils/date_utils.dart';
import '../utils/booking_state.dart';
import '../utils/app_colors.dart';

class RoomListPage extends StatefulWidget {
  final String role;
  const RoomListPage({super.key, required this.role});

  @override
  State<RoomListPage> createState() => _RoomListPageState();
}

class _RoomListPageState extends State<RoomListPage> {
  final PageController _pageController = PageController(viewportFraction: 0.92);
  int _currentPage = 0;

  final List<Map<String, dynamic>> rooms = const [
    {'id': 1, 'name': 'Conference Room A', 'capacity': 20, 'floor': 1},
    {'id': 2, 'name': 'Meeting Room B', 'capacity': 10, 'floor': 2},
    {'id': 3, 'name': 'Seminar Room C', 'capacity': 50, 'floor': 3},
    {'id': 4, 'name': 'Study Room D', 'capacity': 8, 'floor': 1},
  ];

  @override
  void initState() {
    super.initState();
    _pageController.addListener(() {
      int next = _pageController.page!.round();
      if (_currentPage != next) {
        setState(() => _currentPage = next);
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  List<Map<String, String>> get _timeSlots => const [
        {'time': '8:00-10:00', 'status': 'free'},
        {'time': '10:00-12:00', 'status': 'free'},
        {'time': '13:00-15:00', 'status': 'free'},
        {'time': '15:00-17:00', 'status': 'free'},
      ];

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
          style: TextStyle(
            fontWeight: FontWeight.w300,
            fontSize: 24,
            letterSpacing: 0.5,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20, color: AppColors.textSecondary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // Date info banner
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
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
            child: Row(
              children: [
                Icon(Icons.calendar_today_outlined, color: AppColors.primary, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    todayStr,
                    style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w400),
                  ),
                ),
              ],
            ),
          ),
          
          // Page indicator
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
                final cap = r['capacity'] is int ? r['capacity'] as int : int.tryParse('${r['capacity']}') ?? 0;

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
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.15),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Room header
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [AppColors.primary.withOpacity(0.2), AppColors.accent.withOpacity(0.2)],
                          ),
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(20),
                            topRight: Radius.circular(20),
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColors.surface,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(Icons.meeting_room_outlined, color: AppColors.primary, size: 28),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    name,
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w500,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Floor $floor • $cap people',
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
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
                                    final start = time.split('-').first;
                                    int sh = 0, sm = 0;
                                    if (start.contains(':')) {
                                      final hm = start.split(':');
                                      sh = int.tryParse(hm[0]) ?? 0;
                                      sm = int.tryParse(hm[1]) ?? 0;
                                    }
                                    final slotStart = DateTime(now.year, now.month, now.day, sh, sm);
                                    final isPast = now.isAfter(slotStart);
                                    final hasBooked = isStudent && BookingState.hasBookedToday();
                                    final enabled = isStudent && !isPast && !hasBooked;

                                    return InkWell(
                                      onTap: enabled ? () => _showBookingDialog(context, r, time) : null,
                                      borderRadius: BorderRadius.circular(12),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          gradient: enabled
                                              ? LinearGradient(
                                                  colors: [AppColors.primary.withOpacity(0.2), AppColors.accent.withOpacity(0.2)],
                                                )
                                              : null,
                                          color: enabled ? null : AppColors.disabled.withOpacity(0.3),
                                          borderRadius: BorderRadius.circular(12),
                                          border: Border.all(
                                            color: enabled ? AppColors.primary : AppColors.disabled,
                                            width: enabled ? 1.5 : 1,
                                          ),
                                          boxShadow: enabled
                                              ? [
                                                  BoxShadow(
                                                    color: AppColors.primary.withOpacity(0.3),
                                                    blurRadius: 8,
                                                    offset: const Offset(0, 2),
                                                  ),
                                                ]
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
            _buildDialogRow(Icons.meeting_room_outlined, 'Room', room['name'].toString()),
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
            onPressed: () {
              BookingState.markBookedNow();
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Booking submitted successfully'),
                  backgroundColor: AppColors.primary,
                ),
              );
              setState(() {});
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
}
