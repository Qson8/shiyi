import 'package:flutter/material.dart';

// 拾衣坊 - 清新国风图标配置
class ShiyiIcon {
  // 返回图标
  static Widget backIcon = const Icon(
    Icons.arrow_back_ios,
    color: Color(0xFF91B493),
    size: 18,
  );

  // 详情箭头图标
  static Widget nextIcon = const Icon(
    Icons.chevron_right,
    color: Color(0xFF91B493),
    size: 20,
  );

  // 自定义汉服图标（使用现有图标）
  static Widget hanfuIcon = const Icon(
    Icons.checkroom_rounded, // 使用衣柜图标替代
    color: Color(0xFF91B493),
    size: 22,
  );

  // 3D图标
  static Widget viewerIcon = const Icon(
    Icons.view_in_ar_rounded,
    color: Color(0xFF91B493),
    size: 22,
  );

  // 知识图标
  static Widget knowledgeIcon = const Icon(
    Icons.library_books_rounded,
    color: Color(0xFF91B493),
    size: 22,
  );
}
