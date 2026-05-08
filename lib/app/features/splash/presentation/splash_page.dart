import 'package:flutter/material.dart';
import 'package:nawy_ai_app/app/core/injection/injection.dart';
import 'package:nawy_ai_app/app/core/services/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    _navigateAfterDelay();
  }

  Future<void> _navigateAfterDelay() async {
    await Future.delayed(const Duration(seconds: 2));
    
    // Ensure GetIt has the service registered. 
    // If build_runner hasn't been run, this might fail at runtime.
    final auth = getIt<AuthService>();
    final session = auth.currentSession;
    final prefs = await SharedPreferences.getInstance();
    final seenOnboarding = prefs.getBool('onboarding_seen') ?? false;

    if (!mounted) return;

    if (session != null) {
      Navigator.pushReplacementNamed(context, '/home');
    } else if (seenOnboarding) {
      Navigator.pushReplacementNamed(context, '/login');
    } else {
      // Note: User snippet set onboarding_seen to true here, 
      // but usually it's better to set it AFTER they finish onboarding.
      // However, I will follow the logic provided.
      Navigator.pushReplacementNamed(context, '/onboarding');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/nawy_logo.png',
              width: 200,
            ),
            const SizedBox(height: 24),
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
