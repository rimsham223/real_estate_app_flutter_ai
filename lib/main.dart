import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'app/core/injection/injection.dart';
import 'app/core/network/network_cubit.dart';
import 'app/core/theme/app_theme.dart';
import 'app/core/widgets/responsive_wrapper.dart';
import 'app/features/splash/presentation/splash_page.dart';
import 'app/features/onboarding/presentation/onboarding_page.dart';
import 'app/features/auth/presentation/login/login_page.dart';
import 'app/features/auth/presentation/otp/otp_page.dart';
import 'app/features/home/home_page.dart';
import 'app/features/property_search/presentation/property_search_page.dart';
import 'app/features/favorites/presentation/favourites_page.dart';
import 'app/features/ai_assistant/presentation/ai_assistant_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://qvbvyairnithdbewrmnm.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InF2YnZ5YWlybml0aGRiZXdybW5tIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzgwMjYzOTQsImV4cCI6MjA5MzYwMjM5NH0.469N44eH3P1G5kzYTOTG6cU2abbVvbj2RPlkByRkfZg',
  );

  await configureDependencies();
  runApp(
    BlocProvider(
      create: (context) => NetworkCubit(),
      child: const NawyAI(),
    ),
  );
}

class NawyAI extends StatelessWidget {
  const NawyAI({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Nawy AI',
      theme: AppTheme.lightTheme,
      builder: (context, child) => ResponsiveWrapper(child: child!),
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashPage(),
        '/onboarding': (context) => const OnboardingPage(),
        '/login': (context) => const LoginPage(),
        '/otp': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
          return OtpPage(
            email: args['email'],
            name: args['name'],
          );
        },
        '/home': (context) => const HomePage(),
        '/search': (context) => const PropertySearchPage(),
        '/favorites': (context) => const FavouritesPage(),
        '/assistant': (context) => const AiAssistantPage(),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}
