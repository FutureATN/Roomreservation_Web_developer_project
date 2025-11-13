// lib/pages/request_status_page.dart
import 'dart:convert';
import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../widgets/app_scaffold.dart';

import '../utils/app_colors.dart';
import '../utils/session.dart'; // ต้องมี Session.userId

class RequestStatusPage extends StatefulWidget {
  const RequestStatusPage({super.key});

  @override
  State<RequestStatusPage> createState() => _RequestStatusPageState();
}

class _RequestStatusPageState extends State<RequestStatusPage> {
  List<Map<String, dynamic>> _requests = [];
  bool _loading = true;
  String? _error;

static const String _baseUrl = 'http://192.168.238.1:3001';

  @override
  void initState() {
    super.initState();
    _loadRequests();
  }

  Future<void> _loadRequests() async {
    setState(() { _loading = true; _error = null; });
    try {
      final userId = Session.userId; // เซ็ตจากหน้า Login แล้ว
      if (userId == null) throw Exception('userId is null (not logged in)');

      final uri = Uri.parse('$_baseUrl/api/requests')
          .replace(queryParameters: {'userId': userId.toString()});

      final res = await http.get(uri, headers: {'Accept': 'application/json'});
      if (res.statusCode != 200) {
        throw Exception('HTTP ${res.statusCode}: ${res.body}');
      }
      final body = jsonDecode(res.body);
      if (body is! Map || body['success'] != true) {
        throw Exception('Bad payload: $body');
      }

      final List data = body['data'] as List; // pending rows only
      setState(() {
        _requests = data.cast<Map<String, dynamic>>();
        _loading = false;
      });
    } catch (e) {
      setState(() { _error = e.toString(); _loading = false; });
    }
  }

  Color _color(String s) => switch (s) {
        'approved' => AppColors.success,
        'pending'  => AppColors.warning,
        'rejected' => AppColors.error,
        _ => AppColors.disabled,
      };

  IconData _icon(String s) => switch (s) {
        'approved' => Icons.check_circle_outline,
        'pending'  => Icons.pending_outlined,
        'rejected' => Icons.cancel_outlined,
        _ => Icons.help_outline,
      };

  @override
  Widget build(BuildContext context) {
 return AppScaffold(
      title: 'My Requests',
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text('Error: $_error'))
              : RefreshIndicator(
                  onRefresh: _loadRequests,
                  child: _requests.isEmpty
                      ? ListView(
                          children: [SizedBox(height: 120), Center(child: Text('No pending requests.'))],
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.all(16),
                          itemCount: _requests.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 12),
                          itemBuilder: (_, i) {
                            final r = _requests[i];
                            final status = (r['status'] ?? 'pending').toString(); // pending เท่านั้น
                            final roomName = (r['room'] ?? 'Room #${r['room_id']}').toString();
                            final date = (r['booking_date'] ?? '').toString();
                            final time = (r['time_slot'] ?? '').toString();

                            return Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(colors: [AppColors.surface, AppColors.surfaceLight]),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: AppColors.primary.withOpacity(0.3), width: 1),
                                boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.1), blurRadius: 8, offset: Offset(0, 2))],
                              ),
                              child: ListTile(
                                contentPadding: const EdgeInsets.all(16),
                                leading: Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: _color(status).withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Icon(_icon(status), color: _color(status), size: 24),
                                ),
                                title: Text(roomName,
                                  style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 18, color: AppColors.textPrimary)),
                                subtitle: Padding(
                                  padding: const EdgeInsets.only(top: 6),
                                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                    Text('Date: $date   Time: $time',
                                        style: const TextStyle(color: AppColors.textSecondary, fontSize: 14)),
                                    const SizedBox(height: 4),
                                    Container(
                                      margin: const EdgeInsets.only(top: 4),
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: _color(status).withOpacity(0.15),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(color: _color(status), width: 1),
                                      ),
                                      child: Text(status.toUpperCase(),
                                          style: TextStyle(color: _color(status), fontWeight: FontWeight.w500, fontSize: 12)),
                                    ),
                                  ]),
                                ),
                              ),
                            );
                          },
                        ),
                ),
    );
  }
}
