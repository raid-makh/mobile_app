import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Privacy Policy')),
      body: const Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SectionTitle('1. Introduction'),
              SectionText(
                'This Privacy Policy explains how we collect, use, and protect your information when you use our mobile app designed to preview study materials from Algerian universities.',
              ),

              SectionTitle('2. Information We Collect'),
              SectionText(
                '- Name and email address\n- Study materials uploaded by you\n- Saved study materials\n- Login and signup activity (via Facebook SDK)',
              ),

              SectionTitle('3. How We Collect Information'),
              SectionText(
                'We collect data when you sign up, upload materials, or interact with the app. We also use Supabase and Facebook SDK for backend and analytics.',
              ),

              SectionTitle('4. Use of Your Information'),
              SectionText(
                'We use your data to create accounts, manage materials, analyze app usage, and improve our service.',
              ),

              SectionTitle('5. Sharing of Information'),
              SectionText(
                'We do not sell your data. We share it only with:\n- Supabase (backend services)\n- Facebook SDK (login/signup tracking)\n- Authorities if legally required.',
              ),

              SectionTitle('6. Data Security'),
              SectionText(
                'We use industry-standard measures to protect your data, but no method is completely secure.',
              ),

              SectionTitle('7. Your Rights'),
              SectionText(
                'You may access, update, or delete your information. You may also request account deletion.',
              ),

              SectionTitle('8. Children\'s Privacy'),
              SectionText(
                'This app is not for children under 13. We do not knowingly collect their data.',
              ),

              SectionTitle('9. Changes to This Policy'),
              SectionText(
                'We may update this policy. You will be notified via app updates or messages.',
              ),

              SectionTitle('10. Contact Us'),
              SectionText('For questions, contact us at: ropro392@email.com'),
            ],
          ),
        ),
      ),
    );
  }
}

class SectionTitle extends StatelessWidget {
  final String title;
  const SectionTitle(this.title, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
      child: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
      ),
    );
  }
}

class SectionText extends StatelessWidget {
  final String text;
  const SectionText(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Text(text, style: const TextStyle(fontSize: 16));
  }
}
