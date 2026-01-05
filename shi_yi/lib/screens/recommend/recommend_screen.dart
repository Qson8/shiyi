import 'package:flutter/material.dart';
import '../../utils/shiyi_color.dart';
import '../../utils/shiyi_font.dart';
import '../../utils/shiyi_icon.dart';

/// 穿搭推荐页面（占位）
class RecommendScreen extends StatelessWidget {
  const RecommendScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ShiyiColor.bgColor,
      appBar: AppBar(
        title: Text(
          '穿搭推荐',
          style: ShiyiFont.titleStyle.copyWith(color: ShiyiColor.primaryColor),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: ShiyiIcon.backIcon,
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.style,
              size: 64,
              color: ShiyiColor.primaryColor.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              '穿搭推荐功能',
              style: ShiyiFont.titleStyle,
            ),
            const SizedBox(height: 8),
            Text(
              '功能开发中...',
              style: ShiyiFont.smallStyle,
            ),
          ],
        ),
      ),
    );
  }
}

