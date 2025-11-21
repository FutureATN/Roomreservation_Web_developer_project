// lib/pages/manage_rooms_page.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../utils/app_colors.dart';
import '../widgets/app_scaffold.dart';
// lib/Core/api_config.dart
class ApiConfig {
  static const String baseUrl = 'http://192.168.238.1:3001/api';
}


class ManageRoomsPage extends StatefulWidget {
  const ManageRoomsPage({super.key});

  @override
  State<ManageRoomsPage> createState() => _ManageRoomsPageState();
}

class _ManageRoomsPageState extends State<ManageRoomsPage> {

  
  // Now comes from API instead of hard-coded list
  final List<Map<String, dynamic>> _rooms = [];
  bool _loading = false;

  Color _statusColor(String s) => switch (s) {
        'free' => AppColors.success,
        'reserved' => AppColors.error,
        'pending' => AppColors.warning,
        'disabled' => AppColors.disabled,
        _ => AppColors.disabled,
      };

  @override
  void initState() {
    super.initState();
    _fetchRooms();
  }

  Future<void> _fetchRooms() async {
    setState(() => _loading = true);
    try {
      final uri = Uri.parse('${ApiConfig.baseUrl}/rooms');
      final res = await http.get(uri);

      if (res.statusCode == 200) {
        final List<dynamic> data = jsonDecode(res.body);
        setState(() {
          _rooms
            ..clear()
            ..addAll(data.map((e) {
              final m = e as Map<String, dynamic>;
              return {
                'id': m['id'],
                'name': m['name'],
                'capacity': m['capacity'],
                'floor': m['floor'],
                'status': m['status'] ?? 'free',
              };
            }));
        });
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to load rooms (${res.statusCode})')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading rooms: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _addOrEditRoom({Map<String, dynamic>? room}) async {
    final isEdit = room != null;
    final nameCtrl =
        TextEditingController(text: room?['name']?.toString() ?? '');
    final capCtrl =
        TextEditingController(text: room?['capacity']?.toString() ?? '');
    final floorCtrl =
        TextEditingController(text: room?['floor']?.toString() ?? '');
    String status = room?['status']?.toString() ?? 'free';

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(isEdit ? 'Edit Room' : 'Add Room'),
        content: SizedBox(
          width: 400,
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(
                labelText: 'Room Name',
                prefixIcon: Icon(Icons.meeting_room),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: capCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Capacity',
                prefixIcon: Icon(Icons.people),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: floorCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Floor',
                prefixIcon: Icon(Icons.layers),
              ),
            ),
            const SizedBox(height: 8),
          ]),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              final name = nameCtrl.text.trim();
              final cap = int.tryParse(capCtrl.text.trim());
              final fl = int.tryParse(floorCtrl.text.trim());
              if (name.isEmpty || cap == null || fl == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please fill all fields correctly.')),
                );
                return;
              }
              Navigator.pop<Map<String, dynamic>>(
                context,
                {
                  'name': name,
                  'capacity': cap,
                  'floor': fl,
                  'status': status,
                },
              );
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );

    nameCtrl.dispose();
    capCtrl.dispose();
    floorCtrl.dispose();

    if (result != null) {
      // Save to server (create or update)
      try {
        if (isEdit) {
          final int id = room!['id'] as int;
          final uri = Uri.parse('${ApiConfig.baseUrl}/rooms/$id');
          final res = await http.put(
            uri,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(result),
          );

          if (res.statusCode == 200) {
            setState(() {
              final idx = _rooms.indexWhere((r) => r['id'] == id);
              if (idx != -1) {
                _rooms[idx] = {'id': id, ...result};
              }
            });
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Room "${result['name']}" updated.')),
              );
            }
          } else {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Failed to update room (${res.statusCode})',
                  ),
                ),
              );
            }
          }
        } else {
          final uri = Uri.parse('${ApiConfig.baseUrl}/rooms');
          final res = await http.post(
            uri,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(result),
          );

          if (res.statusCode == 200 || res.statusCode == 201) {
            final body = jsonDecode(res.body) as Map<String, dynamic>;
            final newId = body['id'] ?? body['insertId'];
            setState(() {
              _rooms.add({'id': newId, ...result});
            });
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Room "${result['name']}" created.')),
              );
            }
          } else {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Failed to create room (${res.statusCode})',
                  ),
                ),
              );
            }
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Network error: $e')),
          );
        }
      }
    }
  }

  void _toggleDisable(Map<String, dynamic> room) async {
    final current = room['status'] as String;
    if (current != 'free' && current != 'disabled') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Only rooms with FREE status can be disabled.'),
        ),
      );
      return;
    }

    final newStatus = current == 'free' ? 'disabled' : 'free';
    final id = room['id'] as int?;

    if (id == null) return;

    try {
      final uri = Uri.parse('${ApiConfig.baseUrl}/rooms/$id');
      final payload = {
        'name': room['name'],
        'capacity': room['capacity'],
        'floor': room['floor'],
        'status': newStatus,
      };
      final res = await http.put(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload),
      );

      if (res.statusCode == 200) {
        setState(() {
          room['status'] = newStatus;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              newStatus == 'disabled'
                  ? 'Room "${room['name']}" disabled.'
                  : 'Room "${room['name']}" enabled (free).',
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update status (${res.statusCode})'),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Network error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Manage Rooms',
      actions: [
        IconButton(
          icon: const Icon(Icons.add_circle_outline, color: AppColors.primary),
          onPressed: () => _addOrEditRoom(),
          tooltip: 'Add Room',
        )
      ],
      body: _loading && _rooms.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: _rooms.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (_, i) {
                final r = _rooms[i];
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
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: _statusColor(r['status'] as String).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.meeting_room_outlined,
                        color: _statusColor(r['status'] as String),
                        size: 24,
                      ),
                    ),
                    title: Text(
                      r['name'] as String,
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 16,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        'Floor ${r['floor']} • Capacity: ${r['capacity']} • Status: ${r['status']}',
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    trailing: Wrap(
                      spacing: 4,
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.edit_outlined,
                            color: AppColors.primary,
                            size: 20,
                          ),
                          onPressed: () => _addOrEditRoom(room: r),
                        ),
                        IconButton(
                          icon: Icon(
                            (r['status'] == 'disabled')
                                ? Icons.lock_open_outlined
                                : Icons.lock_outline,
                            color: AppColors.textSecondary,
                            size: 20,
                          ),
                          tooltip: (r['status'] == 'disabled')
                              ? 'Enable (set FREE)'
                              : 'Disable',
                          onPressed: () => _toggleDisable(r),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
