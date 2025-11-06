// lib/pages/history.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../utils/session.dart';     // expects: Session.userId, Session.username
import '../utils/app_colors.dart';  // your color palette

class HistoryPage extends StatefulWidget {
  /// 'student' | 'lecturer' | 'staff'
  final String role;
  const HistoryPage({super.key, required this.role});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  // ====== CONFIG ======
  // Android emulator → use 10.0.2.2. If testing on real device, use your PC LAN IP.
  static const String _baseUrl = 'http://192.168.238.1:3001';

  // ====== STATE ======
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
      final userId = Session.userId; // set after login
      final role = widget.role;

      // Build query: staff → all; others → filter by userId
      final params = <String, String>{'role': role};
      if (userId != null) params['userId'] = userId.toString();

      final uri = Uri.parse('$_baseUrl/api/history')
          .replace(queryParameters: params);

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
          final statusText = _normalizeStatus(e['status'], e['status_text']);
          return {
            'room'      : e['room']?.toString(),
            'date'      : e['date']?.toString(),
            'time'      : (e['time'] ?? e['time_slot'])?.toString(),
            'bookedBy'  : (e['booked_by'] ?? e['username'])?.toString(),
            'approvedBy': e['approved_by']?.toString(),
            'status'    : statusText,
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

  /// Map either int status (0/1/2) or backend-provided status_text
  /// → 'pending' | 'reserved' | 'rejected' | 'unknown'
  String _normalizeStatus(dynamic status, dynamic statusText) {
    if (statusText != null && statusText.toString().isNotEmpty) {
      return statusText.toString();
    }
    if (status is int) {
      switch (status) {
        case 0: return 'pending';
        case 1: return 'reserved';
        case 2: return 'rejected';
        default: return 'unknown';
      }
    }
    // If status comes as string
    final asInt = int.tryParse('${status ?? ''}');
    if (asInt != null) return _normalizeStatus(asInt, null);
    return 'unknown';
  }

  Color _statusColor(String? s) {
    switch (s) {
      case 'reserved': return AppColors.success;
      case 'pending':  return AppColors.warning;
      case 'rejected': return AppColors.error;
      default:         return AppColors.disabled;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('History'),
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? _ErrorView(message: _error!, onRetry: _loadHistory)
              : RefreshIndicator(
                  onRefresh: _loadHistory,
                  child: _items.isEmpty
                      ? ListView(
                          children: [
                            SizedBox(height: 120),
                            Center(child: Text('No history to show.')),
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

                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
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
                                    color: _statusColor(status).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    Icons.history_outlined,
                                    color: _statusColor(status),
                                    size: 24,
                                  ),
                                ),
                                title: Text(
                                  '${h['room'] ?? 'Unknown Room'} • ${status.toUpperCase()}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                subtitle: Padding(
                                  padding: const EdgeInsets.only(top: 6),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Date: ${h['date'] ?? "-"}   •  Time: ${h['time'] ?? "-"}'),
                                      Text('Booked by: ${h['bookedBy'] ?? "-"}'),
                                      Text('Approved by: ${h['approvedBy'] ?? "-"}'),
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
