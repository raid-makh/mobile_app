import 'package:flutter/material.dart';
import '../../globals/globals.dart';
import '../../onboarding/onboarding.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SplashScreen extends StatefulWidget {
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    // Delay then check session and navigate
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Future.delayed(const Duration(seconds: 3));

      final supabase = Supabase.instance.client;
      final isLoggedIn = supabase.auth.currentSession != null;

      Navigator.pushReplacementNamed(
        context,
        isLoggedIn ? '/library' : '/onboarding',
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(12, 74, 255, 1),
      body: Column(
        children: [
          const Spacer(),
          Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset("assets/images/logo_1024x1024.jpg", scale: 6),
                Container(
                  margin: const EdgeInsets.all(5),
                  child: const Text(
                    "UnivDZ",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 40,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
        ],
      ),
    );
  }
}
