import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../services/api_service.dart';

class BroadcastScreen extends StatefulWidget {
  const BroadcastScreen({super.key});

  @override
  State<BroadcastScreen> createState() => _BroadcastScreenState();
}

class _BroadcastScreenState extends State<BroadcastScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _messageController = TextEditingController();
  int? _selectedEventId;
  String? _filterStatus;
  List<dynamic> _events = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _loadEvents() async {
    try {
      final response = await ApiService.get('/admin/events');
      if (response['success']) {
        setState(() => _events = response['data']);
      }
    } catch (e) {
      // Silent fail
    }
  }

  Future<void> _sendBroadcast() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final data = {
        'title': _titleController.text,
        'message': _messageController.text,
        if (_selectedEventId != null) 'event_id': _selectedEventId,
        if (_filterStatus != null) 'filter_status': _filterStatus,
      };

      final response = await ApiService.post('/admin/registrations/broadcast', data);

      if (!mounted) return;

      if (response['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response['message']),
            backgroundColor: AppTheme.successColor,
          ),
        );
        _titleController.clear();
        _messageController.clear();
        setState(() {
          _selectedEventId = null;
          _filterStatus = null;
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceAll('Exception: ', '')),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Broadcast Notification'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(
                  Icons.campaign,
                  size: 64,
                  color: AppTheme.primaryColor,
                ),
                const SizedBox(height: 24),
                Text(
                  'Kirim Notifikasi',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.displayMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  'Kirim notifikasi ke peserta (semua atau filtered)',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 32),
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Judul Notifikasi',
                    prefixIcon: Icon(Icons.title),
                  ),
                  validator: (v) => v?.isEmpty ?? true ? 'Judul harus diisi' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _messageController,
                  maxLines: 5,
                  decoration: const InputDecoration(
                    labelText: 'Pesan',
                    prefixIcon: Icon(Icons.message),
                    alignLabelWithHint: true,
                  ),
                  validator: (v) => v?.isEmpty ?? true ? 'Pesan harus diisi' : null,
                ),
                const SizedBox(height: 32),
                Text(
                  'Filter Penerima (Opsional)',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<int>(
                  value: _selectedEventId,
                  decoration: const InputDecoration(
                    labelText: 'Filter by Event',
                    prefixIcon: Icon(Icons.event),
                  ),
                  items: [
                    const DropdownMenuItem<int>(
                      value: null,
                      child: Text('Semua Event'),
                    ),
                    ..._events.map((e) => DropdownMenuItem<int>(
                          value: e['id'],
                          child: Text(e['title'] ?? ''),
                        )),
                  ],
                  onChanged: (v) => setState(() => _selectedEventId = v),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _filterStatus,
                  decoration: const InputDecoration(
                    labelText: 'Filter by Status',
                    prefixIcon: Icon(Icons.filter_alt),
                  ),
                  items: const [
                    DropdownMenuItem<String>(
                      value: null,
                      child: Text('Semua Status'),
                    ),
                    DropdownMenuItem(value: 'pending', child: Text('Pending')),
                    DropdownMenuItem(value: 'approved', child: Text('Approved')),
                    DropdownMenuItem(value: 'rejected', child: Text('Rejected')),
                  ],
                  onChanged: (v) => setState(() => _filterStatus = v),
                ),
                const SizedBox(height: 32),
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ElevatedButton.icon(
                        onPressed: _sendBroadcast,
                        icon: const Icon(Icons.send),
                        label: const Text('Kirim Broadcast'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 20),
                        ),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
