import 'package:flutter/material.dart';
import '../utils/date_utils.dart';
import '../utils/booking_state.dart';

class BookingConfirmPage extends StatelessWidget {
  final Map<String, dynamic> room;
  final String timeSlot;
  const BookingConfirmPage({super.key, required this.room, required this.timeSlot});

  @override
  Widget build(BuildContext context) {
    final todayStr = formatTodayLong();
    return Scaffold(
      appBar: AppBar(
        title: const Text('CONFIRM BOOKING'),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Booking Details',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blue.shade800)),
                const Divider(height: 30),
                _row(Icons.meeting_room, 'Room', room['name'].toString()),
                _row(Icons.calendar_today, 'Date', todayStr),
                _row(Icons.access_time, 'Time', timeSlot),
                _row(Icons.people, 'Capacity', '${room['capacity']} people'),
                _row(Icons.location_on, 'Floor', 'Floor ${room['floor']}'),
              ]),
            ),
          ),
          const SizedBox(height: 20),
          Card(
            color: Colors.orange.shade50,
            child: Padding(
              padding: const EdgeInsets.all(15),
              child: Row(children: [
                const Icon(Icons.info_outline, color: Colors.orange),
                const SizedBox(width: 10),
                Expanded(
                  child: Text('Your booking will be pending until approved by a lecturer.',
                      style: TextStyle(color: Colors.orange.shade900)),
                ),
              ]),
            ),
          ),
          const Spacer(),
          SizedBox(
            width: double.infinity, height: 50,
            child: FilledButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    title: Row(children: const [
                      Icon(Icons.check_circle, color: Colors.green, size: 30),
                      SizedBox(width: 10),
                      Text('Booking Submitted'),
                    ]),
                    content: const Text(
                      'Your booking request has been submitted successfully and is now pending approval.',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          BookingState.markBookedNow();
                          Navigator.of(context).pop(); // dialog
                          Navigator.of(context).pop(); // confirm page
                          Navigator.of(context).pop(); // detail page
                        },
                        child: const Text('OK'),
                      ),
                    ],
                  ),
                );
              },
              child: const Text('Confirm Booking', style: TextStyle(fontSize: 18)),
            ),
          ),
        ]),
      ),
    );
  }

  Widget _row(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(children: [
        Icon(icon, color: Colors.blue, size: 24),
        const SizedBox(width: 15),
        Text('$label: ', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        Expanded(child: Text(value, style: const TextStyle(fontSize: 16))),
      ]),
    );
  }
}
