import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../home/home.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Account Settings'),
        backgroundColor: Colors.blue,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.black38, width: 0.3),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SettingsItem(
                  title: 'Change Full Name',
                  subtitle: 'Edit your display name',
                  onTap: () => _showChangeNameDialog(),
                ),
                const Divider(height: 1),
                SettingsItem(
                  title: 'Change Password',
                  subtitle: '**********',
                  onTap: () {
                    Navigator.pushNamed(context, '/change-password');
                  },
                ),

                const Divider(height: 1),
                SettingsItem(
                  title: 'Logout',
                  subtitle: 'Sign out from your account',
                  onTap: () async {
                    final shouldLogout = await showDialog<bool>(
                      context: context,
                      builder:
                          (context) => AlertDialog(
                            title: const Text('Confirm Logout'),
                            content: const Text(
                              'Are you sure you want to log out?',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(context, true),
                                child: const Text('Logout'),
                              ),
                            ],
                          ),
                    );

                    if (shouldLogout == true) {
                      await Supabase.instance.client.auth.signOut();
                      if (!mounted) return;
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        '/login',
                        (route) => false,
                      );
                    }
                  },
                ),
                const Divider(height: 1),
                SettingsItem(
                  title: 'Privacy Policy',
                  subtitle: '',
                  onTap: () {
                    Navigator.pushNamed(context, '/privacy-policy');
                  },
                ),
                const Divider(height: 1),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: buildNavBar(context, '/settings'),
    );
  }

  void _showChangeNameDialog() {
    final TextEditingController nameController = TextEditingController();
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Change Full Name'),
            content: TextField(
              controller: nameController,
              decoration: const InputDecoration(
                hintText: 'Enter new full name',
              ),
            ),
            actions: [
              TextButton(
                onPressed: () async {
                  final fullName = nameController.text.trim();
                  if (fullName.isNotEmpty) {
                    await Supabase.instance.client.auth.updateUser(
                      UserAttributes(data: {'full_name': fullName}),
                    );
                    if (mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Full name updated.')),
                      );
                    }
                  }
                },
                child: const Text('Save'),
              ),
            ],
          ),
    );
  }

  void _showChangePasswordDialog() {
    final TextEditingController passwordController = TextEditingController();
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Change Password'),
            content: TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(hintText: 'Enter new password'),
            ),
            actions: [
              TextButton(
                onPressed: () async {
                  final password = passwordController.text.trim();
                  if (password.isNotEmpty) {
                    await Supabase.instance.client.auth.updateUser(
                      UserAttributes(password: password),
                    );
                    if (mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Password updated.')),
                      );
                    }
                  }
                },
                child: const Text('Save'),
              ),
            ],
          ),
    );
  }
}

class SettingsItem extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const SettingsItem({
    Key? key,
    required this.title,
    required this.subtitle,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Row(
          children: [
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
