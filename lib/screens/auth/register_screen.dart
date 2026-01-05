import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../player/home_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordConfirmController = TextEditingController();
  final _nicknameController = TextEditingController();
  final _mlIdController = TextEditingController();
  final _mlServerController = TextEditingController();
  
  String? _selectedRank;
  String? _selectedRole;

  final List<String> _ranks = [
    'Warrior',
    'Elite',
    'Master',
    'Grandmaster',
    'Epic',
    'Legend',
    'Mythic',
    'Mythical Glory',
    'Mythical Immortal'
  ];

  final List<String> _roles = ['Exp lane', 'Gold lane', 'Mid lane', 'Roamer', 'Jungler'];

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _passwordConfirmController.dispose();
    _nicknameController.dispose();
    _mlIdController.dispose();
    _mlServerController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    final data = {
      'name': _nameController.text.trim(),
      'email': _emailController.text.trim(),
      'password': _passwordController.text,
      'password_confirmation': _passwordConfirmController.text,
      'nickname': _nicknameController.text.trim(),
      'ml_id': _mlIdController.text.trim(),
      'ml_server': _mlServerController.text.trim(),
      'rank': _selectedRank!,
      'ml_role': _selectedRole!,
    };

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.register(data);

    if (!mounted) return;

    if (success) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
        (route) => false,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.errorMessage ?? 'Registration failed'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Daftar Akun')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Data Diri Section
                  Card(
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Data Diri',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _nameController,
                            decoration: const InputDecoration(
                              labelText: 'Nama Lengkap *',
                              prefixIcon: Icon(Icons.person_outlined),
                            ),
                            validator: (v) => v?.isEmpty ?? true ? 'Nama harus diisi' : null,
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: const InputDecoration(
                              labelText: 'Email *',
                              prefixIcon: Icon(Icons.email_outlined),
                            ),
                            validator: (v) {
                              if (v?.isEmpty ?? true) return 'Email harus diisi';
                              if (!v!.contains('@')) return 'Email tidak valid';
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _passwordController,
                            obscureText: true,
                            decoration: const InputDecoration(
                              labelText: 'Password *',
                              prefixIcon: Icon(Icons.lock_outlined),
                            ),
                            validator: (v) {
                              if (v?.isEmpty ?? true) return 'Password harus diisi';
                              if (v!.length < 6) return 'Password minimal 6 karakter';
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _passwordConfirmController,
                            obscureText: true,
                            decoration: const InputDecoration(
                              labelText: 'Konfirmasi Password *',
                              prefixIcon: Icon(Icons.lock_outlined),
                            ),
                            validator: (v) {
                              if (v?.isEmpty ?? true) return 'Konfirmasi password harus diisi';
                              if (v != _passwordController.text) return 'Password tidak sama';
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Data Mobile Legends Section
                  Card(
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Data Mobile Legends',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _nicknameController,
                            decoration: const InputDecoration(
                              labelText: 'Nickname ML *',
                              prefixIcon: Icon(Icons.games_outlined),
                            ),
                            validator: (v) => v?.isEmpty ?? true ? 'Nickname harus diisi' : null,
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _mlIdController,
                            decoration: const InputDecoration(
                              labelText: 'ID ML *',
                              prefixIcon: Icon(Icons.badge_outlined),
                            ),
                            validator: (v) => v?.isEmpty ?? true ? 'ID ML harus diisi' : null,
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _mlServerController,
                            decoration: const InputDecoration(
                              labelText: 'Server ML *',
                              prefixIcon: Icon(Icons.dns_outlined),
                            ),
                            validator: (v) => v?.isEmpty ?? true ? 'Server ML harus diisi' : null,
                          ),
                          const SizedBox(height: 16),
                          DropdownButtonFormField<String>(
                            value: _selectedRank,
                            decoration: const InputDecoration(
                              labelText: 'Rank *',
                              prefixIcon: Icon(Icons.military_tech_outlined),
                            ),
                            items: _ranks
                                .map((rank) => DropdownMenuItem(value: rank, child: Text(rank)))
                                .toList(),
                            onChanged: (value) => setState(() => _selectedRank = value),
                            validator: (v) => v == null ? 'Rank harus dipilih' : null,
                          ),
                          const SizedBox(height: 16),
                          DropdownButtonFormField<String>(
                            value: _selectedRole,
                            decoration: const InputDecoration(
                              labelText: 'Role *',
                              prefixIcon: Icon(Icons.people_outlined),
                            ),
                            items: _roles
                                .map((role) => DropdownMenuItem(value: role, child: Text(role)))
                                .toList(),
                            onChanged: (value) => setState(() => _selectedRole = value),
                            validator: (v) => v == null ? 'Role harus dipilih' : null,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  Consumer<AuthProvider>(
                    builder: (context, authProvider, _) {
                      if (authProvider.isLoading) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      return ElevatedButton(
                        onPressed: _register,
                        child: const Text('Daftar'),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
