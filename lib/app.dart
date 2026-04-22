import 'package:flutter/material.dart';
import 'core/constants/app_colors.dart';
import 'features/map/map_screen.dart';

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
      home: const MapScreen(),
    );
  }
}
