import 'package:flutter/material.dart';
import 'core/constants/app_colors.dart';
import 'core/services/preferences_service.dart';
import 'features/map/map_screen.dart';
import 'features/onboarding/onboarding_screen.dart';

class FreteMapApp extends StatelessWidget {
  const FreteMapApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FreteMap',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
        useMaterial3: true,
      ),
      home: const _StartupRouter(),
    );
  }
}

class _StartupRouter extends StatelessWidget {
  const _StartupRouter();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: PreferencesService.hasOnboarded(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          // Splash mínimo mientras carga SharedPreferences
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        return snapshot.data! ? const MapScreen() : const OnboardingScreen();
      },
    );
  }
}
