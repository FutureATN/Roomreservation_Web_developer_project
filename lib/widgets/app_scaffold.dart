// lib/widgets/app_scaffold.dart
import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../utils/session.dart';
import 'app_drawer.dart';

class AppScaffold extends StatelessWidget {
  final String title;
  final Widget body;
  final List<Widget>? actions;
  final Widget? floatingActionButton;

  const AppScaffold({
    super.key,
    required this.title,
    required this.body,
    this.actions,
    this.floatingActionButton,
  });

  IconData _roleIcon(String r) {
    switch (r) {
      case 'student': return Icons.school;
      case 'lecturer': return Icons.person_outline;
      case 'staff': return Icons.admin_panel_settings;
      default: return Icons.person;
    }
  }

  @override
  Widget build(BuildContext context) {
    final roleNow = (Session.role ?? 'student').toLowerCase();

    return Scaffold(
      backgroundColor: AppColors.background,
      // 👇 drawer exists on EVERY page
      drawer: AppDrawer(roleNow: roleNow),

      appBar: AppBar(
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        surfaceTintColor: Colors.transparent,

        // 👇 force hamburger even on deep routes
        automaticallyImplyLeading: false,
        leading: Builder(
          builder: (ctx) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(ctx).openDrawer(),
            tooltip: MaterialLocalizations.of(ctx).openAppDrawerTooltip,
          ),
        ),

        title: Row(
          children: [
            Text(title, style: const TextStyle(letterSpacing: 0.5, fontWeight: FontWeight.w400)),
            const SizedBox(width: 8),
            Icon(_roleIcon(roleNow), size: 20, color: AppColors.primary),
          ],
        ),
        actions: actions,
      ),

      body: SafeArea(child: body),
      floatingActionButton: floatingActionButton,
    );
  }
}
