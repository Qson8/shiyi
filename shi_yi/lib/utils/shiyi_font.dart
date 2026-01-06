import 'package:flutter/material.dart';

// 拾衣坊 - 清新国风字体配置
class ShiyiFont {
  static const String family = "FreshHanfu";

  // 字体大小
  static const double _baseTitleSize = 20.0;
  static const double _baseBodySize = 16.0;
  static const double _baseSmallSize = 12.0;

  // 初始化（保留方法以保持兼容性，但不再需要初始化字体大小）
  static void init() {
    // 不再需要初始化字体大小设置
  }

  // 标题样式（站酷快乐体）
  static const TextStyle titleStyle = TextStyle(
    fontFamily: family,
    fontSize: _baseTitleSize,
    color: Color(0xFF4A4A48),
    letterSpacing: 2,
    fontWeight: FontWeight.w400,
  );

  // 正文样式（思源柔黑）
  static const TextStyle bodyStyle = TextStyle(
    fontFamily: family,
    fontSize: _baseBodySize,
    color: Color(0xFF4A4A48),
  );

  // 小文字样式
  static const TextStyle smallStyle = TextStyle(
    fontSize: _baseSmallSize,
    color: Color(0xFF8A8A88),
  );
}
