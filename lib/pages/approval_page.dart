// lib/pages/approval_page.dart
import 'dart:convert';
import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../utils/app_colors.dart';
import '../utils/session.dart';
import '../widgets/app_scaffold.dart';

class ApprovalPage extends StatefulWidget {
  const ApprovalPage({super.key});

  @override
  State<ApprovalPage> createState() => _ApprovalPageState();
}

class _ApprovalPageState extends State<ApprovalPage> {
  // ----- API BASE URL -----
  String get _baseUrl {
    const fromEnv = String.fromEnvironment('API_BASE_URL', defaultValue: '');
    if (fromEnv.isNotEmpty) return fromEnv;
    if (Platform.isAndroid) return 'http://192.168.238.1:3001';
    return 'http://127.0.0.1:3001';
  }

  bool _loading = true;
  String? _error;
  List<Map<String, dynamic>> _pending = [];

  @override
  void initState() {
    super.initState();
    _loadPending();
  }

  Future<void> _loadPending() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final uri =
          Uri.parse('$_baseUrl/api/bookings/pending'); // GET pending list
      final res =
          await http.get(uri, headers: {'Accept': 'application/json'});

      if (res.statusCode != 200) {
        throw Exception('HTTP ${res.statusCode}: ${res.body}');
      }

      final body = jsonDecode(res.body);
      if (body is! Map || body['success'] != true) {
        throw Exception('Bad payload: $body');
      }

      final List data = body['data'] as List;
      setState(() {
        _pending = data.cast<Map<String, dynamic>>();
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  Future<void> _sendAction(int bookingId, bool approve) async {
    final uid = Session.userId;
    if (uid == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Missing lecturer userId in Session'),
        backgroundColor: AppColors.error,
      ));
      return;
    }

    final verb = approve ? 'approve' : 'reject';
    final uri =
        Uri.parse('$_baseUrl/api/bookings/$bookingId/$verb');

    final res = await http.put(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({'approved_by': uid}),
    );

    if (res.statusCode != 200) {
      throw Exception('HTTP ${res.statusCode}: ${res.body}');
    }

    final body = jsonDecode(res.body);
    if (body is! Map || body['success'] != true) {
      throw Exception('Bad payload: $body');
    }
  }

  Future<void> _actOn(int id, bool approve) async {
    final sm = ScaffoldMessenger.of(context);
    try {
      sm.showSnackBar(SnackBar(
        content: Text(approve ? 'Approving...' : 'Rejecting...'),
        duration: const Duration(seconds: 1),
      ));

      await _sendAction(id, approve);

      // อัปเดตใน list ให้เป็น approved / rejected และ reload ใหม่
      setState(() {
        _pending = _pending.where((e) => e['id'] != id).toList();
      });

      sm.showSnackBar(SnackBar(
        content: Text(approve ? 'Request approved' : 'Request rejected'),
        backgroundColor:
            approve ? AppColors.success : AppColors.error,
      ));

      // ดึงรายการล่าสุดอีกที (เผื่อมีคนอื่นจองเพิ่ม)
      _loadPending();
    } catch (e) {
      sm.showSnackBar(SnackBar(
        content: Text('Failed: $e'),
        backgroundColor: AppColors.error,
      ));
    }
  }

  Color _statusColor(String s) {
    switch (s) {
      case 'pending':
        return AppColors.warning;
      case 'approved':
        return AppColors.success;
      case 'rejected':
        return AppColors.error;
      default:
        return AppColors.disabled;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Booking Approvals',
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: _loadPending,
        ),
      ],
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.error_outline,
                            size: 48, color: AppColors.error),
                        const SizedBox(height: 12),
                        Text(
                          'Error: $_error',
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        FilledButton(
                          onPressed: _loadPending,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: _pending.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (_, i) {
                    final r = _pending[i];
                    final status = (r['status'] ?? 'pending').toString();
                    final chipColor = _statusColor(status);

                    return Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppColors.surface, AppColors.surfaceLight],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: AppColors.primary.withOpacity(0.3),
                            width: 1),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                r['room']?.toString() ?? 'Unknown Room',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 18,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Date: ${r['date']}  •  Time: ${r['time']}',
                                style: const TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 14),
                              ),
                              Text(
                                'Requested by: ${r['requestedBy']}',
                                style: const TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 14),
                              ),
                              const SizedBox(height: 12),
                              Row(children: [
                                Container(
                                  decoration: BoxDecoration(
                                    color: chipColor.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                        color: chipColor, width: 1),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 6),
                                  child: Text(
                                    status.toUpperCase(),
                                    style: TextStyle(
                                      color: chipColor,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                const Spacer(),
                                OutlinedButton.icon(
                                  onPressed: () =>
                                      _actOn(r['id'] as int, false),
                                  icon: const Icon(Icons.close_outlined,
                                      color: AppColors.error, size: 18),
                                  label: const Text('Reject',
                                      style: TextStyle(
                                          fontSize: 14,
                                          color: AppColors.error)),
                                  style: OutlinedButton.styleFrom(
                                    side: const BorderSide(
                                        color: AppColors.error, width: 1),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 8),
                                    minimumSize: Size.zero,
                                    shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(8),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                FilledButton.icon(
                                  onPressed: () =>
                                      _actOn(r['id'] as int, true),
                                  icon: const Icon(
                                      Icons.check_circle_outline,
                                      size: 18),
                                  label: const Text('Approve',
                                      style: TextStyle(fontSize: 14)),
                                  style: FilledButton.styleFrom(
                                    backgroundColor: AppColors.primary,
                                    foregroundColor: AppColors.background,
                                    elevation: 0,
                                    shadowColor: AppColors.primary
                                        .withOpacity(0.5),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 8),
                                    minimumSize: Size.zero,
                                    shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(8),
                                    ),
                                  ),
                                ),
                              ]),
                            ]),
                      ),
                    );
                  },
                ),
    );
  }
}
