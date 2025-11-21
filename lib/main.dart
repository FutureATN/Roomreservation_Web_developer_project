import 'package:flutter/material.dart';
import 'utils/session.dart';              // <-- add this
import 'pages/login_page.dart';
import 'pages/dashboard_page.dart';      // <-- for staff/lecturer
import 'pages/room_list_page.dart';      // <-- for student

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1) Load saved session (if any) from SharedPreferences
  await Session.load();

  runApp(const RoomReservationApp());
}

class RoomReservationApp extends StatelessWidget {
  const RoomReservationApp({super.key});

  @override
  Widget build(BuildContext context) {
    // 2) Decide start page based on session
    Widget startPage;

    if (Session.isLoggedIn && Session.role != null && Session.role!.isNotEmpty) {
      final role = Session.role!.toLowerCase();

      if (role == 'student') {
        // Students go directly to room list
        startPage = RoomListPage(role: role);
      } else {
        // Staff / Lecturer go to dashboard
        startPage = DashboardPage(role: role);
      }
    } else {
      // No valid session → show login
      startPage = const LoginPage();
    }

    return MaterialApp(
      title: 'Room Reservation System',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.blue,
      ),
      home: startPage,
    );
  }
}
