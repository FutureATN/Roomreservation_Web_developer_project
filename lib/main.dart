import 'package:flutter/material.dart';
import 'pages/login_page.dart';

void main() {
  runApp(const RoomReservationApp());
}

class RoomReservationApp extends StatelessWidget {
  const RoomReservationApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Room Reservation System',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.blue,
      ),
      home: const LoginPage(),
    );
  }
}
