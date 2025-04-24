import 'package:flutter/material.dart';
import 'splash_screen/splash_screen.dart';
import './login/login.dart';
import './library/library.dart';
import 'search/search.dart';
import 'search/models/study_material.dart';
import './profile/settings.dart';
import 'signup/signup.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'signup/verifyEmail.dart';
import 'profile/change_password.dart';
import 'library/documents/MyDocuments.dart';
import 'onboarding/onboarding.dart';
import 'privacy_policy/privacy_policy.dart';
import 'package:facebook_app_events/facebook_app_events.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // <--- Add this line
  await Supabase.initialize(
    url: "https://ivgqlybgaovkkovjpkmv.supabase.co",
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Iml2Z3FseWJnYW92a2tvdmpwa212Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDM1MTgyMDgsImV4cCI6MjA1OTA5NDIwOH0.WYe7Am1QLW0zExHhdn9L3U7J5WbDMNuDMeyDNi4KvPw',
  );
  FacebookAppEvents facebookAppEvents = FacebookAppEvents();

  print("⏳ Initializing mappings...");
  await StudyMaterial.initMappings();
  print("✅ Mappings ready. Starting app.");
  print("University mappings: ${StudyMaterial.universityMapping}");
  print("Module mappings: ${StudyMaterial.moduleMapping}");
  runApp(const MyApp());
  /*await dotenv.load();

  String supabaseUrl = "https://ivgqlybgaovkkovjpkmv.supabase.co";
  String supabaseKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Iml2Z3FseWJnYW92a2tvdmpwa212Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDM1MTgyMDgsImV4cCI6MjA1OTA5NDIwOH0.WYe7Am1QLW0zExHhdn9L3U7J5WbDMNuDMeyDNi4KvPw";
  await Supabase.initialize(url: supabaseUrl, anonKey: supabaseKey);*/
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: SplashScreen(),
      debugShowCheckedModeBanner: false,
      routes: {
        "/login": (context) => LoginScreen(),
        "/onboarding": (context) => OnboardingScreen(),
        '/library': (context) => LibraryScreen(),
        '/search': (context) => StudyMaterialsScreen(),
        '/privacy-policy': (context) => const PrivacyPolicyScreen(),
        '/settings': (context) => SettingsScreen(),
        '/signup': (context) => SignUpScreen(),
        "/documents": (context) => DocumentsScreen(),
        '/change-password': (context) => ChangePasswordScreen(),
        '/verify-email': (context) {
          final email = ModalRoute.of(context)!.settings.arguments as String;
          return VerifyEmailScreen(email: email);
        },
      },
    );
  }
}
