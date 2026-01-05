import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../services/api_service.dart';
import 'package:intl/intl.dart';

class ScheduleManagementScreen extends StatefulWidget {
  const ScheduleManagementScreen({super.key});

  @override
  State<ScheduleManagementScreen> createState() => _ScheduleManagementScreenState();
}

class _ScheduleManagementScreenState extends State<ScheduleManagementScreen> {
  List<dynamic> _schedules = [];
  List<dynamic> _events = [];
 bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final eventsResp = await ApiService.get('/admin/events');
      final schedulesResp = await ApiService.get('/admin/schedules');
      
      if (eventsResp['success'] && schedulesResp['success']) {
        setState(() {
          _events = eventsResp['data'];
          _schedules = schedulesResp['data'];
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

  Future<void> _generateRoom(int eventId, int matchNumber) async {
    try {
      final response = await ApiService.post('/admin/schedules/generate-room', {
        'event_id': eventId,
        'match_number': matchNumber,
      });
      
      if (response['success']) {
        final schedule = response['data'];
        if (mounted) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Room Generated!'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Room ID: ${schedule['room_id']}', 
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  const SizedBox(height: 8),
                  Text('Password: ${schedule['room_password']}',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('OK'),
                ),
              ],
            ),
          );
          _loadData();
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }

  void _showGenerateDialog() {
    int? selectedEventId;
    final matchNumberController = TextEditingController(text: '1');

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Generate Room'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<int>(
                value: selectedEventId,
                decoration: const InputDecoration(labelText: 'Event'),
                items: _events
                    .map((e) => DropdownMenuItem<int>(
                          value: e['id'],
                          child: Text(e['title'] ?? ''),
                        ))
                    .toList(),
                onChanged: (v) => setDialogState(() => selectedEventId = v),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: matchNumberController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Match Number',
                  helperText: '1 match = 4 players',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                if (selectedEventId != null) {
                  Navigator.pop(context);
                  _generateRoom(
                    selectedEventId!,
                    int.parse(matchNumberController.text),
                  );
                }
              },
              child: const Text('Generate'),
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
        title: const Text('Schedule Management'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: _schedules.isEmpty
                  ? const Center(child: Text('Belum ada schedule'))
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _schedules.length,
                      itemBuilder: (context, index) {
                        final schedule = _schedules[index];
                        final event = schedule['event'];

                        return Card(
                          margin: const EdgeInsets.only(bottom: 16),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: AppTheme.primaryColor,
                              child: Text('${schedule['match_number']}'),
                            ),
                            title: Text(event?['title'] ?? 'Event'),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 8),
                                Text(
                                  'Room ID: ${schedule['room_id'] ?? '-'}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                Text(
                                  'Password: ${schedule['room_password'] ?? '-'}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                if (schedule['scheduled_at'] != null)
                                  Text(
                                    'Jadwal: ${DateFormat('dd MMM yyyy HH:mm').format(DateTime.parse(schedule['scheduled_at']))}',
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
        onPressed: _showGenerateDialog,
        icon: const Icon(Icons.add),
        label: const Text('Generate Room'),
      ),
    );
  }
}
