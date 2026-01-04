import 'package:flutter/material.dart';
import 'shiyi_color.dart';
import 'shiyi_font.dart';
import 'shiyi_decoration.dart';
import 'shiyi_icon.dart';

class AppTheme {
  // 使用清新国风配色
  static const Color primaryColor = ShiyiColor.primaryColor;
  static const Color backgroundColor = ShiyiColor.bgColor;
  static const Color surfaceColor = Colors.white;
  static const Color textPrimary = ShiyiColor.textPrimary;
  static const Color textSecondary = ShiyiColor.textSecondary;

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: false, // 使用自定义设计
      scaffoldBackgroundColor: backgroundColor,
      colorScheme: ColorScheme.light(
        primary: primaryColor,
        secondary: primaryColor.withOpacity(0.8),
        surface: surfaceColor,
        background: backgroundColor,
        onPrimary: Colors.white,
        onSurface: textPrimary,
        onBackground: textPrimary,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent, // 清新风格：透明背景
        foregroundColor: textPrimary,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: primaryColor),
        titleTextStyle: ShiyiFont.titleStyle.copyWith(fontSize: 18),
      ),
      cardTheme: CardTheme(
        color: surfaceColor.withOpacity(0.8), // 半透明
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12), // 清新圆角
        ),
        shadowColor: const Color(0x1F000000), // Colors.black.withOpacity(0.12)
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12), // 清新圆角
          borderSide: const BorderSide(color: ShiyiColor.borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 16,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor.withOpacity(0.9),
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8), // 清新圆角
          ),
        ),
      ),
      textTheme: TextTheme(
        headlineSmall: ShiyiFont.titleStyle.copyWith(fontSize: 22),
        titleMedium: ShiyiFont.bodyStyle.copyWith(fontWeight: FontWeight.w600),
        bodyMedium: ShiyiFont.bodyStyle,
        bodySmall: ShiyiFont.smallStyle,
      ),
    );
  }
}

