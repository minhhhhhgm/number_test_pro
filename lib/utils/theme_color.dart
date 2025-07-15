import 'package:flutter/material.dart';

class ThemeColor {
  final Color background;
  final Color text;
  final Color border;
  final Color button;

  ThemeColor({
    required this.background,
    required this.text,
    required this.border,
    required this.button,
  });
}

final List<ThemeColor> themeColors = [
  ThemeColor( // Green
    background: Color(0xFFE8F5E9),
    text: Color(0xFF2E7D32),
    border: Color(0xFF81C784),
    button: Color(0xFF388E3C),
  ),
  ThemeColor( // Orange
    background: Color(0xFFFFF3E0),
    text: Color(0xFFEF6C00),
    border: Color(0xFFFFB74D),
    button: Color(0xFFFB8C00),
  ),
  ThemeColor( // Blue
    background: Color(0xFFE3F2FD),
    text: Color(0xFF1565C0),
    border: Color(0xFF64B5F6),
    button: Color(0xFF1976D2),
  ),
  ThemeColor( // Purple
    background: Color(0xFFF3E5F5),
    text: Color(0xFF6A1B9A),
    border: Color(0xFFBA68C8),
    button: Color(0xFF8E24AA),
  ),
  ThemeColor( // Pink
    background: Color(0xFFFFEBEE),
    text: Color(0xFFC62828),
    border: Color(0xFFEF9A9A),
    button: Color(0xFFE53935),
  ),
  ThemeColor( // Lime
    background: Color(0xFFF0F4C3),
    text: Color(0xFF9E9D24),
    border: Color(0xFFDCE775),
    button: Color(0xFFAFB42B),
  ),
  ThemeColor( // Teal
    background: Color(0xFFE0F2F1),
    text: Color(0xFF00796B),
    border: Color(0xFF80CBC4),
    button: Color(0xFF00897B),
  ),
  ThemeColor( // Cyan
    background: Color(0xFFE0F7FA),
    text: Color(0xFF00838F),
    border: Color(0xFF80DEEA),
    button: Color(0xFF00ACC1),
  ),
  ThemeColor( // Light Yellow
    background: Color(0xFFFFFDE7),
    text: Color(0xFFF9A825),
    border: Color(0xFFFFF176),
    button: Color(0xFFFDD835),
  ),
  ThemeColor( // Beige
    background: Color(0xFFFFF8E1),
    text: Color(0xFF795548),
    border: Color(0xFFFFECB3),
    button: Color(0xFFFFB300),
  ),
  ThemeColor( // Light Coral
    background: Color(0xFFFFEDEE),
    text: Color(0xFFD32F2F),
    border: Color(0xFFFFCDD2),
    button: Color(0xFFE57373),
  ),
  ThemeColor( // Lavender
    background: Color(0xFFF5EFFF),
    text: Color(0xFF512DA8),
    border: Color(0xFFD1C4E9),
    button: Color(0xFF9575CD),
  ),
  ThemeColor( // Mint
    background: Color(0xFFE6FFF7),
    text: Color(0xFF00695C),
    border: Color(0xFFB2DFDB),
    button: Color(0xFF26A69A),
  ),
  ThemeColor( // Peach
    background: Color(0xFFFFF0E0),
    text: Color(0xFFEF6C00),
    border: Color(0xFFFFCCBC),
    button: Color(0xFFFF8A65),
  ),
  ThemeColor( // Sky Blue
    background: Color(0xFFEDF7FF),
    text: Color(0xFF0277BD),
    border: Color(0xFF81D4FA),
    button: Color(0xFF039BE5),
  ),
  ThemeColor( // Soft Violet
    background: Color(0xFFF3F0FF),
    text: Color(0xFF5E35B1),
    border: Color(0xFFB39DDB),
    button: Color(0xFF7E57C2),
  ),
  ThemeColor( // Pastel Green
    background: Color(0xFFF1F8E9),
    text: Color(0xFF33691E),
    border: Color(0xFFAED581),
    button: Color(0xFF689F38),
  ),
  ThemeColor( // Light Gray
    background: Color(0xFFF5F5F5),
    text: Color(0xFF424242),
    border: Color(0xFFBDBDBD),
    button: Color(0xFF757575),
  ),
  ThemeColor( // Salmon
    background: Color(0xFFFFEBE5),
    text: Color(0xFFE64A19),
    border: Color(0xFFFFAB91),
    button: Color(0xFFEF5350),
  ),
  ThemeColor( // Soft Blue Gray
    background: Color(0xFFECEFF1),
    text: Color(0xFF37474F),
    border: Color(0xFFB0BEC5),
    button: Color(0xFF607D8B),
  ),
];
