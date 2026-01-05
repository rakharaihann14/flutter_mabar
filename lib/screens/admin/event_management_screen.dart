import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../services/api_service.dart';
import 'package:intl/intl.dart';

class EventManagementScreen extends StatefulWidget {
  const EventManagementScreen({super.key});

  @override
  State<EventManagementScreen> createState() => _EventManagementScreenState();
}

class _EventManagementScreenState extends State<EventManagementScreen> {
  List<dynamic> _events = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  Future<void> _loadEvents() async {
    setState(() => _isLoading = true);
    try {
      final response = await ApiService.get('/admin/events');
      if (response['success']) {
        setState(() {
          _events = response['data'];
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _deleteEvent(int id) async {
    try {
      await ApiService.delete('/admin/events/$id');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Event berhasil dihapus')),
        );
        _loadEvents();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }

  void _showEventDialog({Map<String, dynamic>? event}) {
    final titleController = TextEditingController(text: event?['title'] ?? '');
    final descController = TextEditingController(text: event?['description'] ?? '');
    final maxParticipantsController = TextEditingController(
      text: event?['max_participants']?.toString() ?? '100',
    );
    String status = event?['status'] ?? 'draft';
    DateTime? startDate = event?['start_date'] != null 
        ? DateTime.parse(event!['start_date']) 
        : DateTime.now();
    DateTime? endDate = event?['end_date'] != null 
        ? DateTime.parse(event!['end_date']) 
        : DateTime.now().add(const Duration(days: 7));

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(event == null ? 'Tambah Event' : 'Edit Event'),
          content: SingleChildScrollView(
            child: SizedBox(
              width: 400,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: titleController,
                    decoration: const InputDecoration(labelText: 'Judul Event'),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: descController,
                    maxLines: 3,
                    decoration: const InputDecoration(labelText: 'Deskripsi'),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: maxParticipantsController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Max Participants'),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: status,
                    decoration: const InputDecoration(labelText: 'Status'),
                    items: ['draft', 'open', 'closed', 'completed']
                        .map((s) => DropdownMenuItem(value: s, child: Text(s.toUpperCase())))
                        .toList(),
                    onChanged: (v) => setDialogState(() => status = v!),
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    title: const Text('Start Date'),
                    subtitle: Text(DateFormat('dd MMM yyyy HH:mm').format(startDate!)),
                    trailing: const Icon(Icons.calendar_today),
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: startDate!,
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (date != null) {
                        setDialogState(() => startDate = date);
                      }
                    },
                  ),
                  ListTile(
                    title: const Text('End Date'),
                    subtitle: Text(DateFormat('dd MMM yyyy HH:mm').format(endDate!)),
                    trailing: const Icon(Icons.calendar_today),
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: endDate!,
                        firstDate: startDate!,
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (date != null) {
                        setDialogState(() => endDate = date);
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () async {
                final data = {
                  'title': titleController.text,
                  'description': descController.text,
                  'max_participants': int.parse(maxParticipantsController.text),
                  'start_date': DateFormat('yyyy-MM-dd HH:mm:ss').format(startDate!),
                  'end_date': DateFormat('yyyy-MM-dd HH:mm:ss').format(endDate!),
                  'status': status,
                };
    
                try {
                  if (event == null) {
                    await ApiService.post('/admin/events', data);
                  } else {
                    await ApiService.put('/admin/events/${event['id']}', data);
                  }
                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Event berhasil ${event == null ? "ditambah" : "diupdate"}')),
                    );
                    _loadEvents();
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error: ${e.toString()}')),
                    );
                  }
                }
              },
              child: const Text('Simpan'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Event Management'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadEvents,
              child: _events.isEmpty
                  ? const Center(child: Text('Belum ada event'))
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _events.length,
                      itemBuilder: (context, index) {
                        final event = _events[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 16),
                          child: ListTile(
                            title: Text(event['title'] ?? ''),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(event['description'] ?? ''),
                                const SizedBox(height: 4),
                                Text('Status: ${event['status']?.toUpperCase()}'),
                                Text('Max: ${event['max_participants']} | Registered: ${event['registrations_count'] ?? 0}'),
                              ],
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit, color: AppTheme.primaryColor),
                                  onPressed: () => _showEventDialog(event: event),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, color: AppTheme.errorColor),
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        title: const Text('Hapus Event'),
                                        content: const Text('Yakin ingin menghapus event ini?'),
                                        actions: [
                                          TextButton(
                                            onPressed: () => Navigator.pop(context),
                                            child: const Text('Batal'),
                                          ),
                                          ElevatedButton(
                                            onPressed: () {
                                              Navigator.pop(context);
                                              _deleteEvent(event['id']);
                                            },
                                            child: const Text('Hapus'),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                            isThreeLine: true,
                          ),
                        );
                      },
                    ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showEventDialog(),
        icon: const Icon(Icons.add),
        label: const Text('Tambah Event'),
      ),
    );
  }
}
