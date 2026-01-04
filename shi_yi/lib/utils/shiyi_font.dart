import 'package:flutter/material.dart';

// 拾衣坊 - 清新国风字体配置
class ShiyiFont {
  static const String family = "FreshHanfu";

  // 标题样式（站酷快乐体）
  static TextStyle titleStyle = const TextStyle(
    fontFamily: family,
    fontSize: 20,
    color: Color(0xFF4A4A48),
    letterSpacing: 2,
    fontWeight: FontWeight.w400,
  );

  // 正文样式（思源柔黑）
  static TextStyle bodyStyle = const TextStyle(
    fontFamily: family,
    fontSize: 16,
    color: Color(0xFF4A4A48),
  );

  // 小文字样式
  static TextStyle smallStyle = const TextStyle(
    fontSize: 12,
    color: Color(0xFF8A8A88),
  );
}
