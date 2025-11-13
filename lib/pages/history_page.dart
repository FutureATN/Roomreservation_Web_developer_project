// lib/pages/history.dart
import 'dart:convert';
import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../widgets/app_scaffold.dart';
import '../utils/session.dart';
import '../utils/app_colors.dart';

class HistoryPage extends StatefulWidget {
  /// 'student' | 'lecturer' | 'staff'
  final String role;
  const HistoryPage({super.key, required this.role});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  // ====== BASE URL (เหมือนหน้าอื่น) ======
  String get _baseUrl {
    const fromEnv = String.fromEnvironment('API_BASE_URL', defaultValue: '');
    if (fromEnv.isNotEmpty) return fromEnv;
    if (Platform.isAndroid) return 'http://192.168.238.1:3001'; // emulator IP
    return 'http://127.0.0.1:3001';
  }

  bool _loading = true;
  String? _error;
  List<Map<String, String?>> _items = [];

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final userId = Session.userId;
      final role = (Session.role ?? widget.role).toLowerCase();

      // build query params
      final params = <String, String>{'role': role};
      if (userId != null) params['userId'] = userId.toString();

      final uri = Uri.parse('$_baseUrl/api/history').replace(
        queryParameters: params,
      );

      final res = await http.get(uri, headers: {'Accept': 'application/json'});
      if (res.statusCode != 200) {
        throw Exception('HTTP ${res.statusCode}: ${res.body}');
      }

      final body = json.decode(res.body);
      if (body is! Map || body['success'] != true) {
        throw Exception('Bad payload: $body');
      }

      final List data = body['data'] as List;

      setState(() {
        _items = data.map<Map<String, String?>>((e) {
          final status = (e['status'] ?? '').toString().toLowerCase();
          return {
            'room'     : e['room']?.toString(),
            'date'     : e['date']?.toString(),
            'time'     : e['time']?.toString(),
            'bookedBy' : e['booked_by']?.toString(),
            'status'   : status,
          };
        }).toList();
        _loading = false;
      });
    } catch (err) {
      setState(() {
        _error = err.toString();
        _loading = false;
      });
    }
  }

  Color _statusColor(String? s) {
    switch (s) {
      case 'approved':
        return AppColors.success;
      case 'rejected':
        return AppColors.error;
      case 'pending':
        return AppColors.warning;
      default:
        return AppColors.disabled;
    }
  }

  String _statusLabel(String? s) {
    switch (s) {
      case 'approved':
        return 'APPROVED';
      case 'rejected':
        return 'REJECTED';
      case 'pending':
        return 'PENDING';
      default:
        return 'UNKNOWN';
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'History',
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? _ErrorView(message: _error!, onRetry: _loadHistory)
              : RefreshIndicator(
                  onRefresh: _loadHistory,
                  child: _items.isEmpty
                      ? ListView(
                          children: const [
                            SizedBox(height: 120),
                            Center(
                              child: Text(
                                'No history to show.',
                                style: TextStyle(color: AppColors.textSecondary),
                              ),
                            ),
                          ],
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.all(16),
                          itemCount: _items.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final h = _items[index];
                            final status = h['status'] ?? 'unknown';
                            final color = _statusColor(status);

                            return Container(
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [AppColors.surface, AppColors.surfaceLight],
                                ),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: AppColors.primary.withOpacity(0.3),
                                  width: 1,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.primary.withOpacity(0.1),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: ListTile(
                                contentPadding: const EdgeInsets.all(16),
                                leading: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: color.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    status == 'approved'
                                        ? Icons.check_circle_outline
                                        : (status == 'rejected'
                                            ? Icons.cancel_outlined
                                            : Icons.history_outlined),
                                    color: color,
                                    size: 24,
                                  ),
                                ),
                                title: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        h['room'] ?? 'Unknown Room',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w500,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: color.withOpacity(0.15),
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(color: color, width: 1),
                                      ),
                                      child: Text(
                                        _statusLabel(status),
                                        style: TextStyle(
                                          color: color,
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                subtitle: Padding(
                                  padding: const EdgeInsets.only(top: 6),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Date: ${h['date'] ?? "-"}   •   Time: ${h['time'] ?? "-"}',
                                        style: const TextStyle(
                                          color: AppColors.textSecondary,
                                          fontSize: 13,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        'Booked by: ${h['bookedBy'] ?? "-"}',
                                        style: const TextStyle(
                                          color: AppColors.textSecondary,
                                          fontSize: 13,
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
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final Future<void> Function() onRetry;
  const _ErrorView({required this.message, required this.onRetry});

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
            Text(
              'Error loading history:\n$message',
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textPrimary),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: onRetry,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
