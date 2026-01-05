import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../services/api_service.dart';
import '../../providers/auth_provider.dart';
import '../auth/login_screen.dart';
import 'my_registrations_screen.dart';
import 'notification_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<dynamic> _events = [];
  int _unreadNotifCount = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadEvents();
    _loadNotificationCount();
  }

  Future<void> _loadEvents() async {
    setState(() => _isLoading = true);
    try {
      final response = await ApiService.getEvents();
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

  Future<void> _loadNotificationCount() async {
    try {
      final response = await ApiService.getNotifications();
      if (response['success']) {
        final data = response['data'];
        if (data is List) {
          final notifications = data;
          setState(() {
            _unreadNotifCount = notifications.where((n) => n['is_read'] == 0 || n['is_read'] == false).length;
          });
        }
      }
    } catch (e) {
      // Silent fail
    }
  }

  Future<void> _registerEvent(int eventId) async {
    try {
      final response = await ApiService.registerEvent(eventId);
      if (response['success']) {
        final data = response['data'];
        if (!mounted) return;
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Pendaftaran Berhasil!'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Kamu berhasil mendaftar!'),
                const SizedBox(height: 16),
                Text(
                  'Antrian: ${data['queue_number']}',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                Text(
                  'Match: ${data['match_number']}',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
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
        _loadEvents();
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceAll('Exception: ', '')),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Event Mabar ML'),
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined),
                onPressed: () async {
                  await Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const NotificationScreen()),
                  );
                  _loadNotificationCount();
                },
              ),
              if (_unreadNotifCount > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: AppTheme.errorColor,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      _unreadNotifCount > 9 ? '9+' : '$_unreadNotifCount',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await authProvider.logout();
              if (!mounted) return;
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (route) => false,
              );
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadEvents,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _events.isEmpty
                ? const Center(child: Text('Belum ada event tersedia'))
                : ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                    backgroundColor: AppTheme.primaryColor,
                                    child: Text(
                                      (user?['name'] ?? 'U')[0].toUpperCase(),
                                      style: const TextStyle(color: Colors.white),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          user?['name'] ?? '-',
                                          style: Theme.of(context).textTheme.titleMedium,
                                        ),
                                        Text(
                                          user?['nickname'] ?? '-',
                                          style: Theme.of(context).textTheme.bodyMedium,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const Divider(height: 24),
                              Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      children: [
                                        const Text('Rank'),
                                        const SizedBox(height: 4),
                                        Text(
                                          user?['rank'] ?? '-',
                                          style: const TextStyle(fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                    child: Column(
                                      children: [
                                        const Text('Role'),
                                        const SizedBox(height: 4),
                                        Text(
                                          user?['ml_role'] ?? '-',
                                          style: const TextStyle(fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Event Tersedia',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16),
                      ..._events.map((event) => _buildEventCard(event)),
                    ],
                  ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: 0,
        onDestinationSelected: (index) {
          if (index == 1) {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const MyRegistrationsScreen()),
            );
          }
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.list_alt_outlined),
            selectedIcon: Icon(Icons.list_alt),
            label: 'Pendaftaran Saya',
          ),
        ],
      ),
    );
  }

  Widget _buildEventCard(dynamic event) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              event['title'] ?? '',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              event['description'] ?? '',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 8),
            if (event['status'] == 'closed')
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.errorColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'CLOSED',
                  style: TextStyle(
                    color: AppTheme.errorColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.people_outline, size: 16, color: AppTheme.textSecondary),
                const SizedBox(width: 4),
                Text(
                  '${event['approved_count']}/${event['max_participants']} terdaftar',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(width: 16),
                Icon(Icons.event_seat, size: 16, color: AppTheme.successColor),
                const SizedBox(width: 4),
                Text(
                  '${event['available_slots']} slot tersedia',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.successColor,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: (event['user_registered'] == true ||
                        event['status'] != 'open' ||
                        event['available_slots'] <= 0)
                    ? null
                    : () => _registerEvent(event['id']),
                child: Text(
                  event['user_registered'] == true
                      ? 'Anda Sudah Mendaftar'
                      : event['status'] == 'closed'
                          ? 'Event Ditutup'
                          : event['available_slots'] > 0
                              ? 'Daftar Sekarang'
                              : 'Event Penuh',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
