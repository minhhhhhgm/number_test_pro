import 'package:flutter/material.dart';

class AppColors {
  // Màu chủ đạo
  static const Color primaryBlue = Color(0xFF2196F3);
  static const Color darkBlue = Color(0xFF1565C0);

  // Màu nhấn (highlight, button)
  static const Color accentYellow = Color(0xFFFFCA28);
  static const Color accentOrange = Color(0xFFFF9800);

  // Nền
  static const Color background = Color(0xFFF1F3F4);
  static const Color darkBackground = Color(0xFF1E1E1E);

  // Màu text
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color white = Colors.white;

  // Màu xám cho border / phân cách
  static const Color borderGray = Color(0xFFBDBDBD);

  // Màu cho trạng thái đặc biệt
  static const Color successGreen = Color(0xFF4CAF50);
  static const Color errorRed = Color(0xFFF44336);

  static const Color colorBG = Color(0xFFfcf6ee);
  static const Color colorBlueGray = Color(0xFF64a3c5);



  // Gradient (nếu dùng)
  static const Gradient levelGradient = LinearGradient(
    colors: [primaryBlue, accentYellow],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
