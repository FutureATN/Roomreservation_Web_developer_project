import 'package:flutter/material.dart';
import 'register_page.dart';
import 'dashboard_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  String _selectedRole = 'student';

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // ---- role helpers (you already had these; left here and used below)
  final List<String> _roles = const ['student', 'staff', 'lecturer'];

  IconData _roleIcon(String r) {
    switch (r) {
      case 'student':
        return Icons.school;
      case 'staff':
        return Icons.admin_panel_settings;
      case 'lecturer':
        return Icons.menu_book;
      default:
        return Icons.person;
    }
  }

  Color _roleColor(String r) {
    switch (r) {
      case 'student':
        return Colors.teal;
      case 'staff':
        return Colors.deepOrange;
      case 'lecturer':
        return Colors.indigo;
      default:
        return Colors.blueGrey;
    }
  }

  String _roleLabel(String r) => r[0].toUpperCase() + r.substring(1);

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.blue.shade400, Colors.blue.shade700],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Card(
              margin: const EdgeInsets.all(20),
              elevation: 8,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              child: Container(
                padding: const EdgeInsets.all(30),
                width: 400,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.meeting_room, size: 80, color: Colors.blue),
                    const SizedBox(height: 20),
                    Text(
                      'Room Reservation',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade800,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // === Animated role icon (changes with selection) ===
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 250),
                      transitionBuilder: (child, anim) => ScaleTransition(
                        scale: anim,
                        child: FadeTransition(opacity: anim, child: child),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // === Dropdown with icons in items + dynamic prefix icon ===
                    DropdownButtonFormField<String>(
                      value: _selectedRole,
                      decoration: InputDecoration(
                        labelText: 'Login As',
                        prefixIcon: Icon(_roleIcon(_selectedRole), color: _roleColor(_selectedRole)),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      items: _roles.map((r) {
                        return DropdownMenuItem<String>(
                          value: r,
                          child: Row(
                            children: [
                              Icon(_roleIcon(r), color: _roleColor(r)),
                              const SizedBox(width: 10),
                              Text(_roleLabel(r)),
                            ],
                          ),
                        );
                      }).toList(),
                      // Keeps icon+text visible in the closed field too
                      selectedItemBuilder: (context) => _roles.map((r) {
                        return Row(
                          children: [
                            const SizedBox(width: 10),
                            Text(_roleLabel(r)),
                          ],
                        );
                      }).toList(),
                      onChanged: (v) => setState(() => _selectedRole = v ?? 'student'),
                    ),

                    const SizedBox(height: 20),
                    TextField(
                      controller: _usernameController,
                      decoration: InputDecoration(
                        labelText: 'Username',
                        prefixIcon: const Icon(Icons.account_circle),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        prefixIcon: const Icon(Icons.lock),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                    const SizedBox(height: 30),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: FilledButton(
                        style: FilledButton.styleFrom(
                          backgroundColor: scheme.primary,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (_) => DashboardPage(role: _selectedRole)),
                          );
                        },
                        child: const Text('Login', style: TextStyle(fontSize: 18)),
                      ),
                    ),
                    if (_selectedRole == 'student') ...[
                      const SizedBox(height: 15),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const RegisterPage()),
                          );
                        },
                        child: const Text('Don\'t have an account? Register'),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
