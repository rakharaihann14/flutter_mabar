import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants/api_endpoints.dart';
import '../../services/api_service.dart';

class RegistrationManagementScreen extends StatefulWidget {
  const RegistrationManagementScreen({super.key});

  @override
  State<RegistrationManagementScreen> createState() => _RegistrationManagementScreenState();
}

class _RegistrationManagementScreenState extends State<RegistrationManagementScreen> {
  List<dynamic> _registrations = [];
  bool _isLoading = true;
  String? _filterStatus;
  String? _filterRank;
  String? _filterRole;

  @override
  void initState() {
    super.initState();
    _loadRegistrations();
  }

  Future<void> _loadRegistrations() async {
    setState(() => _isLoading = true);
    try {
      String query = '';
      if (_filterStatus != null) query += '?status=$_filterStatus';
      if (_filterRank != null) {
        query += query.isEmpty ? '?' : '&';
        query += 'rank=$_filterRank';
      }
      if (_filterRole != null) {
        query += query.isEmpty ? '?' : '&';
        query += 'ml_role=$_filterRole';
      }

      final response = await ApiService.get('/admin/registrations$query');
      if (response['success']) {
        final data = response['data'];
        setState(() {
          _registrations = data is List ? data : [];
          _isLoading = false;
        });
      } else {
        setState(() {
          _registrations = [];
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _registrations = [];
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _approveRegistration(int id) async {
    try {
      await ApiService.put('/admin/registrations/$id/approve', {});
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pendaftaran disetujui'), backgroundColor: AppTheme.successColor),
        );
        _loadRegistrations();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _rejectRegistration(int id) async {
    try {
      await ApiService.put('/admin/registrations/$id/reject', {});
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pendaftaran ditolak'), backgroundColor: AppTheme.errorColor),
        );
        _loadRegistrations();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _deleteRegistration(int id) async {
    try {
      await ApiService.delete('/admin/registrations/$id');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pendaftaran dihapus'), backgroundColor: AppTheme.errorColor),
        );
        _loadRegistrations();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }

  void _showEditStatusDialog(int regId, String currentStatus) {
    String selectedStatus = currentStatus;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Edit Status'),
          content: DropdownButtonFormField<String>(
            value: selectedStatus,
            decoration: const InputDecoration(labelText: 'Status'),
            items: const [
              DropdownMenuItem(value: 'approved', child: Text('Approved')),
              DropdownMenuItem(value: 'rejected', child: Text('Rejected')),
            ],
            onChanged: (v) => setDialogState(() => selectedStatus = v!),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                try {
                  await ApiService.put('/admin/registrations/$regId/status', {
                    'status': selectedStatus,
                  });
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Status berhasil diubah'),
                        backgroundColor: AppTheme.successColor,
                      ),
                    );
                    _loadRegistrations();
                  }
                } catch (e) {
                  if (mounted) {
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

  Future<void> _exportToCSV() async {
    try {
      setState(() => _isLoading = true);
      
      final response = await ApiService.get('/admin/registrations/export');
      
      if (response['success']) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Export berhasil! Data telah di-export.'),
              backgroundColor: AppTheme.successColor,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Export gagal: ${e.toString()}'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showFilters() {
    showDialog(
      context: context,
      builder: (context) {
        String? tempStatus = _filterStatus;
        String? tempRank = _filterRank;
        String? tempRole = _filterRole;

        return StatefulBuilder(
          builder: (context, setDialogState) => AlertDialog(
            title: const Text('Filter Pendaftaran'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  value: tempStatus,
                  decoration: const InputDecoration(labelText: 'Status'),
                  items: [
                    const DropdownMenuItem(value: null, child: Text('Semua')),
                    const DropdownMenuItem(value: 'pending', child: Text('Pending')),
                    const DropdownMenuItem(value: 'approved', child: Text('Approved')),
                    const DropdownMenuItem(value: 'rejected', child: Text('Rejected')),
                  ],
                  onChanged: (v) => setDialogState(() => tempStatus = v),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: tempRank,
                  decoration: const InputDecoration(labelText: 'Rank'),
                  items: [
                    const DropdownMenuItem(value: null, child: Text('Semua')),
                    const DropdownMenuItem(value: 'Warrior', child: Text('Warrior')),
                    const DropdownMenuItem(value: 'Elite', child: Text('Elite')),
                    const DropdownMenuItem(value: 'Master', child: Text('Master')),
                    const DropdownMenuItem(value: 'Grandmaster', child: Text('Grandmaster')),
                    const DropdownMenuItem(value: 'Epic', child: Text('Epic')),
                    const DropdownMenuItem(value: 'Legend', child: Text('Legend')),
                    const DropdownMenuItem(value: 'Mythic', child: Text('Mythic')),
                  ],
                  onChanged: (v) => setDialogState(() => tempRank = v),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: tempRole,
                  decoration: const InputDecoration(labelText: 'Role'),
                  items: [
                    const DropdownMenuItem(value: null, child: Text('Semua')),
                    const DropdownMenuItem(value: 'Tank', child: Text('Tank')),
                    const DropdownMenuItem(value: 'Roamer', child: Text('Roamer')),
                    const DropdownMenuItem(value: 'Mid', child: Text('Mid')),
                    const DropdownMenuItem(value: 'Gold', child: Text('Gold')),
                    const DropdownMenuItem(value: 'Jungler', child: Text('Jungler')),
                  ],
                  onChanged: (v) => setDialogState(() => tempRole = v),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  setState(() {
                    _filterStatus = null;
                    _filterRank = null;
                    _filterRole = null;
                  });
                  Navigator.pop(context);
                  _loadRegistrations();
                },
                child: const Text('Reset'),
              ),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _filterStatus = tempStatus;
                    _filterRank = tempRank;
                    _filterRole = tempRole;
                  });
                  Navigator.pop(context);
                  _loadRegistrations();
                },
                child: const Text('Terapkan'),
              ),
            ],
          ),
        );
      },
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'approved': return AppTheme.successColor;
      case 'rejected': return AppTheme.errorColor;
      default: return AppTheme.secondaryColor;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registration Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilters,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadRegistrations,
              child: _registrations.isEmpty
                  ? const Center(child: Text('Belum ada pendaftaran'))
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _registrations.length,
                      itemBuilder: (context, index) {
                        final reg = _registrations[index];
                        final user = reg['user'] ?? {};
                        final event = reg['event'] ?? {};
                        final userName = user['name']?.toString() ?? 'Unknown';
                        final userEmail = user['email']?.toString() ?? '-';
                        final userNickname = user['nickname']?.toString() ?? '-';
                        final userMlId = user['ml_id']?.toString() ?? '-';
                        final userMlServer = user['ml_server']?.toString() ?? '-';
                        final userRank = user['rank']?.toString() ?? '-';
                        final userRole = user['ml_role']?.toString() ?? '-';
                        final userReason = user['reason']?.toString();
                        final eventTitle = event['title']?.toString() ?? 'Unknown Event';
                        final regStatus = reg['status']?.toString() ?? 'pending';
                        final regId = reg['id'];
                        final queueNumber = reg['queue_number']?.toString() ?? '-';
                        final matchNumber = reg['match_number']?.toString() ?? '-';

                        return Card(
                          margin: const EdgeInsets.only(bottom: 16),
                          child: ExpansionTile(
                            leading: CircleAvatar(
                              backgroundColor: _getStatusColor(regStatus),
                              child: Text(
                                userName.isNotEmpty ? userName[0].toUpperCase() : 'U',
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                            title: Text(userName),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Event: $eventTitle'),
                                Text('Queue: $queueNumber | Match: $matchNumber'),
                              ],
                            ),
                            trailing: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: _getStatusColor(regStatus),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                regStatus.toUpperCase(),
                                style: const TextStyle(color: Colors.white, fontSize: 12),
                              ),
                            ),
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Email: $userEmail'),
                                    Text('Nickname: $userNickname'),
                                    Text('ML ID: $userMlId ($userMlServer)'),
                                    Text('Rank: $userRank'),
                                    Text('Role: $userRole'),
                                    if (userReason != null && userReason.isNotEmpty)
                                      Text('Alasan: $userReason'),
                                    const SizedBox(height: 16),
                                    Row(
                                      children: [
                                        if (regStatus == 'pending')
                                          Expanded(
                                            child: ElevatedButton.icon(
                                              onPressed: () => _approveRegistration(regId),
                                              icon: const Icon(Icons.check),
                                              label: const Text('Setujui'),
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: AppTheme.successColor,
                                              ),
                                            ),
                                          ),
                                        if (regStatus == 'pending')
                                          const SizedBox(width: 8),
                                        if (regStatus == 'pending')
                                          Expanded(
                                            child: ElevatedButton.icon(
                                              onPressed: () => _rejectRegistration(regId),
                                              icon: const Icon(Icons.close),
                                              label: const Text('Tolak'),
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: AppTheme.errorColor,
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: OutlinedButton.icon(
                                            onPressed: () => _showEditStatusDialog(regId, regStatus),
                                            icon: const Icon(Icons.edit),
                                            label: const Text('Edit Status'),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: OutlinedButton.icon(
                                            onPressed: () {
                                              showDialog(
                                                context: context,
                                                builder: (context) => AlertDialog(
                                                  title: const Text('Hapus Pendaftaran'),
                                                  content: const Text('Yakin ingin menghapus pendaftaran ini dari antrian?'),
                                                  actions: [
                                                    TextButton(
                                                      onPressed: () => Navigator.pop(context),
                                                      child: const Text('Batal'),
                                                    ),
                                                    ElevatedButton(
                                                      onPressed: () {
                                                        Navigator.pop(context);
                                                        _deleteRegistration(regId);
                                                      },
                                                      style: ElevatedButton.styleFrom(
                                                        backgroundColor: AppTheme.errorColor,
                                                      ),
                                                      child: const Text('Hapus'),
                                                    ),
                                                  ],
                                                ),
                                              );
                                            },
                                            icon: const Icon(Icons.delete, color: AppTheme.errorColor),
                                            label: const Text('Hapus', style: TextStyle(color: AppTheme.errorColor)),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
    );
  }
}
