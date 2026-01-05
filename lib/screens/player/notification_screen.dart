import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../services/api_service.dart';
import 'package:intl/intl.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  List<dynamic> _notifications = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    setState(() => _isLoading = true);
    try {
      final response = await ApiService.getNotifications();
      if (response['success']) {
        // Handle both array and object responses
        final data = response['data'];
        if (data is List) {
          setState(() {
            _notifications = data;
            _isLoading = false;
          });
        } else {
          setState(() {
            _notifications = [];
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      setState(() {
        _notifications = [];
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _markAsRead(int id) async {
    try {
      await ApiService.markAsRead(id);
      _loadNotifications();
    } catch (e) {
      // Silent fail
    }
  }

  Future<void> _markAllAsRead() async {
    try {
      final response = await ApiService.get('/notifications/read-all');
      if (response['success']) {
        _loadNotifications();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }

  Color _getNotifColor(String type) {
    switch (type) {
      case 'success':
        return AppTheme.successColor;
      case 'error':
        return AppTheme.errorColor;
      case 'warning':
        return AppTheme.secondaryColor;
      default:
        return AppTheme.primaryColor;
    }
  }

  IconData _getNotifIcon(String type) {
    switch (type) {
      case 'success':
        return Icons.check_circle;
      case 'error':
        return Icons.error;
      case 'warning':
        return Icons.warning;
      default:
        return Icons.info;
    }
  }

  @override
  Widget build(BuildContext context) {
    final unreadCount = _notifications.where((n) => n['is_read'] == 0 || n['is_read'] == false).length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifikasi'),
        actions: [
          if (unreadCount > 0)
            TextButton(
              onPressed: _markAllAsRead,
              child: const Text('Tandai Semua Dibaca'),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadNotifications,
              child: _notifications.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.notifications_none, size: 80, color: Colors.grey),
                          SizedBox(height: 16),
                          Text('Belum ada notifikasi', style: TextStyle(color: Colors.grey)),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _notifications.length,
                      itemBuilder: (context, index) {
                        final notif = _notifications[index];
                        final isRead = notif['is_read'] == 1 || notif['is_read'] == true;
                        final type = notif['type'] ?? 'info';

                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          color: isRead ? null : AppTheme.primaryColor.withOpacity(0.05),
                          child: InkWell(
                            onTap: () {
                              if (!isRead) {
                                _markAsRead(notif['id']);
                              }
                            },
                            borderRadius: BorderRadius.circular(16),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: _getNotifColor(type).withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Icon(
                                      _getNotifIcon(type),
                                      color: _getNotifColor(type),
                                      size: 24,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                notif['title'] ?? '',
                                                style: TextStyle(
                                                  fontWeight: isRead ? FontWeight.normal : FontWeight.bold,
                                                  fontSize: 16,
                                                ),
                                              ),
                                            ),
                                            if (!isRead)
                                              Container(
                                                width: 8,
                                                height: 8,
                                                decoration: const BoxDecoration(
                                                  color: AppTheme.primaryColor,
                                                  shape: BoxShape.circle,
                                                ),
                                              ),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          notif['message'] ?? '',
                                          style: Theme.of(context).textTheme.bodyMedium,
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          notif['created_at'] != null
                                              ? DateFormat('dd MMM yyyy, HH:mm')
                                                  .format(DateTime.parse(notif['created_at']))
                                              : '',
                                          style: Theme.of(context).textTheme.bodySmall,
                                        ),
                                      ],
                                    ),
                                  ),
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
