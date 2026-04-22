import 'package:flutter/material.dart';

abstract final class AppColors {
  static const primary = Color(0xFF1565C0);
  static const available = Color(0xFF43A047);
  static const assigned = Color(0xFFFB8C00);
  static const completed = Color(0xFF757575);
  static const error = Color(0xFFD32F2F);

  static Color forStatus(String status) => switch (status) {
        'available' => available,
        'assigned' => assigned,
        'completed' => completed,
        _ => Colors.blueGrey,
      };
}
