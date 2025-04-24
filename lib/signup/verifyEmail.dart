import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class VerifyEmailScreen extends StatelessWidget {
  final String email;

  const VerifyEmailScreen({super.key, required this.email});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Verify Your Email")),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("A verification email has been sent."),
            const SizedBox(height: 16),
            Text("Please verify your email: $email"),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () async {
                final session = Supabase.instance.client.auth.currentSession;
                final user = Supabase.instance.client.auth.currentUser;

                await Supabase.instance.client.auth.refreshSession();

                if (user?.emailConfirmedAt != null) {
                  Navigator.pushReplacementNamed(context, '/login');
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Email not verified yet')),
                  );
                }
              },
              child: const Text("Continue"),
            ),
          ],
        ),
      ),
    );
  }
}
