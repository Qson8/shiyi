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

  // 根据汉服类型返回对应的图标
  static IconData getHanfuTypeIcon(String type) {
    switch (type) {
      case '上装':
        return Icons.checkroom_rounded;
      case '下装':
        return Icons.woman_rounded;
      case '配饰':
        return Icons.diamond_rounded;
      case '套装':
        return Icons.auto_awesome_rounded;
      default:
        return Icons.checkroom_rounded;
    }
  }

  // 根据汉服类型返回拟物化图标Widget
  static Widget getHanfuTypeIconWidget(String type, {double size = 48, Color? color}) {
    return Icon(
      getHanfuTypeIcon(type),
      size: size,
      color: color ?? const Color(0xFF91B493),
    );
  }
}
