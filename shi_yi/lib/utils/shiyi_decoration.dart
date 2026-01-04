import 'package:flutter/material.dart';

// 拾衣坊 - 清新国风装饰器配置
class ShiyiDecoration {
  // 卡片装饰（通用）
  static BoxDecoration cardDecoration = BoxDecoration(
    color: Colors.white.withOpacity(0.8), // 半透明白色
    borderRadius: BorderRadius.circular(12),
    border: Border.all(color: const Color(0xFFEAEAE8)),
    boxShadow: const [
      BoxShadow(
        color: Color(0x1F000000), // Colors.black.withOpacity(0.12)
        blurRadius: 3,
        offset: Offset(0, 1),
        spreadRadius: 0,
      )
    ],
  );

  // 按钮装饰
  static BoxDecoration buttonDecoration = BoxDecoration(
    color: const Color(0xFF91B493).withOpacity(0.9),
    borderRadius: BorderRadius.circular(8),
  );
}
