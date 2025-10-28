import 'package:flutter/material.dart';

class ManageRoomsPage extends StatefulWidget {
  const ManageRoomsPage({super.key});

  @override
  State<ManageRoomsPage> createState() => _ManageRoomsPageState();
}

class _ManageRoomsPageState extends State<ManageRoomsPage> {
  final List<Map<String, dynamic>> _rooms = [
    {'id': 1, 'name': 'Conference Room A', 'capacity': 20, 'floor': 1, 'status': 'free'},
    {'id': 2, 'name': 'Meeting Room B',  'capacity': 10, 'floor': 2, 'status': 'free'},
    {'id': 3, 'name': 'Seminar Room C',  'capacity': 50, 'floor': 3, 'status': 'reserved'},
    {'id': 4, 'name': 'Study Room D',    'capacity': 8,  'floor': 1, 'status': 'disabled'},
  ];

  Color _statusColor(String s) => switch (s) {
        'free' => Colors.green,
        'reserved' => Colors.red,
        'pending' => Colors.orange,
        'disabled' => Colors.grey,
        _ => Colors.grey,
      };

  Future<void> _addOrEditRoom({Map<String, dynamic>? room}) async {
    final isEdit = room != null;
    final nameCtrl  = TextEditingController(text: room?['name']?.toString() ?? '');
    final capCtrl   = TextEditingController(text: room?['capacity']?.toString() ?? '');
    final floorCtrl = TextEditingController(text: room?['floor']?.toString() ?? '');
    String status   = room?['status']?.toString() ?? 'free';

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(isEdit ? 'Edit Room' : 'Add Room'),
        content: SizedBox(
          width: 400,
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Room Name', prefixIcon: Icon(Icons.meeting_room))),
            const SizedBox(height: 8),
            TextField(controller: capCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Capacity', prefixIcon: Icon(Icons.people))),
            const SizedBox(height: 8),
            TextField(controller: floorCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Floor', prefixIcon: Icon(Icons.layers))),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: status,
              items: const [
                DropdownMenuItem(value: 'free', child: Text('Free')),
                DropdownMenuItem(value: 'pending', child: Text('Pending')),
                DropdownMenuItem(value: 'reserved', child: Text('Reserved')),
                DropdownMenuItem(value: 'disabled', child: Text('Disabled')),
              ],
              onChanged: (v) => status = v ?? 'free',
              decoration: const InputDecoration(labelText: 'Status (today)', prefixIcon: Icon(Icons.info_outline)),
            ),
          ]),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              final name = nameCtrl.text.trim();
              final cap  = int.tryParse(capCtrl.text.trim());
              final fl   = int.tryParse(floorCtrl.text.trim());
              if (name.isEmpty || cap == null || fl == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please fill all fields correctly.')),
                );
                return;
              }
              Navigator.pop<Map<String, dynamic>>(context, {'name': name, 'capacity': cap, 'floor': fl, 'status': status});
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );

    nameCtrl.dispose(); capCtrl.dispose(); floorCtrl.dispose();

    if (result != null) {
      setState(() {
        if (isEdit) {
          final idx = _rooms.indexWhere((r) => r['id'] == room['id']);
          if (idx != -1) _rooms[idx] = {'id': room['id'], ...result};
        } else {
          final maxId = _rooms.fold<int>(0, (p, e) => (e['id'] as int) > p ? e['id'] as int : p);
          _rooms.add({'id': maxId + 1, ...result});
        }
      });
    }
  }

  void _toggleDisable(Map<String, dynamic> room) {
    final current = room['status'] as String;
    if (current == 'free') {
      setState(() => room['status'] = 'disabled');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Room "${room['name']}" disabled.')));
    } else if (current == 'disabled') {
      setState(() => room['status'] = 'free');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Room "${room['name']}" enabled (free).')));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Only rooms with FREE status can be disabled.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MANAGE ROOMS'),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
        actions: [ IconButton(icon: const Icon(Icons.add), onPressed: () => _addOrEditRoom(), tooltip: 'Add Room') ],
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _rooms.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (_, i) {
          final r = _rooms[i];
          return Card(
            elevation: 3,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              leading: CircleAvatar(
                backgroundColor: _statusColor(r['status'] as String),
                child: const Icon(Icons.meeting_room, color: Colors.white),
              ),
              title: Text(r['name'] as String, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text('Floor ${r['floor']} • Capacity: ${r['capacity']} • Status: ${r['status']}'),
              ),
              trailing: Wrap(spacing: 8, children: [
                IconButton(icon: const Icon(Icons.edit), onPressed: () => _addOrEditRoom(room: r)),
                IconButton(
                  icon: Icon((r['status'] == 'disabled') ? Icons.lock_open : Icons.lock),
                  tooltip: (r['status'] == 'disabled') ? 'Enable (set FREE)' : 'Disable',
                  onPressed: () => _toggleDisable(r),
                ),
              ]),
            ),
          );
        },
      ),
    );
  }
}
