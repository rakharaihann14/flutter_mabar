import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../services/api_service.dart';
import '../auth/login_screen.dart';
import 'event_management_screen.dart';
import 'registration_management_screen.dart';
import 'broadcast_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  Map<String, dynamic>? _stats;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    setState(() => _isLoading = true);
    try {
      final response = await ApiService.get('/admin/dashboard');
      if (response['success']) {
        setState(() {
          _stats = response['data']['stats'];
          _isLoading = false;
        });
      }
    } catch (e) {
      // Fallback stats
      setState(() {
        _stats = {
          'total_events': 2,
          'active_events': 2,
          'total_players': 0,
          'total_registrations': 0,
          'pending_registrations': 0,
          'approved_registrations': 0,
        };
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await authProvider.logout();
              if (!context.mounted) return;
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (route) => false,
              );
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadStats,
              child: ListView(
                padding: const EdgeInsets.all(24),
                children: [
                  Text(
                    'Selamat Datang, Admin!',
                    style: Theme.of(context).textTheme.displayMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Dashboard MyAnomali Mabar ML',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 32),
                  
                  // Statistics Grid
                  Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    children: [
                      SizedBox(
                        width: MediaQuery.of(context).size.width > 600 ? (MediaQuery.of(context).size.width - 80) / 3 : (MediaQuery.of(context).size.width - 64) / 2,
                        child: _buildStatCard(
                          'Total Events',
                          '${_stats?['total_events'] ?? 0}',
                          Icons.event,
                          AppTheme.primaryColor,
                        ),
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width > 600 ? (MediaQuery.of(context).size.width - 80) / 3 : (MediaQuery.of(context).size.width - 64) / 2,
                        child: _buildStatCard(
                          'Event Aktif',
                          '${_stats?['active_events'] ?? 0}',
                          Icons.event_available,
                          AppTheme.successColor,
                        ),
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width > 600 ? (MediaQuery.of(context).size.width - 80) / 3 : (MediaQuery.of(context).size.width - 64) / 2,
                        child: _buildStatCard(
                          'Total Players',
                          '${_stats?['total_players'] ?? 0}',
                          Icons.people,
                          AppTheme.secondaryColor,
                        ),
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width > 600 ? (MediaQuery.of(context).size.width - 80) / 3 : (MediaQuery.of(context).size.width - 64) / 2,
                        child: _buildStatCard(
                          'Total Pendaftaran',
                          '${_stats?['total_registrations'] ?? 0}',
                          Icons.app_registration,
                          Colors.blue,
                        ),
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width > 600 ? (MediaQuery.of(context).size.width - 80) / 3 : (MediaQuery.of(context).size.width - 64) / 2,
                        child: _buildStatCard(
                          'Pending',
                          '${_stats?['pending_registrations'] ?? 0}',
                          Icons.pending_actions,
                          Colors.orange,
                        ),
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width > 600 ? (MediaQuery.of(context).size.width - 80) / 3 : (MediaQuery.of(context).size.width - 64) / 2,
                        child: _buildStatCard(
                          'Disetujui',
                          '${_stats?['approved_registrations'] ?? 0}',
                          Icons.check_circle,
                          AppTheme.successColor,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Quick Actions
                  Text(
                    'Fitur Admin',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  
                  Column(
                    children: [
                      _buildFeatureCard(
                        'Event Management',
                        'Create, edit, delete events',
                        Icons.event,
                        AppTheme.primaryColor,
                        () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const EventManagementScreen(),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildFeatureCard(
                        'Registration Management',
                        'Approve, reject, filter registrations',
                        Icons.people,
                        AppTheme.successColor,
                        () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const RegistrationManagementScreen(),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildFeatureCard(
                        'Broadcast Notification',
                        'Send messages to participants',
                        Icons.campaign,
                        Colors.purple,
                        () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const BroadcastScreen(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 24),
                const Spacer(),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: Theme.of(context).textTheme.bodyMedium,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureCard(
    String title,
    String description,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 32),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}
