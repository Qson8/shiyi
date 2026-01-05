import 'package:flutter/material.dart';
import '../../utils/shiyi_color.dart';
import '../../utils/shiyi_font.dart';
import '../../utils/shiyi_icon.dart';

/// 纹样定制页面（占位）
class CustomScreen extends StatelessWidget {
  const CustomScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ShiyiColor.bgColor,
      appBar: AppBar(
        title: Text(
          '纹样定制',
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
              Icons.edit,
              size: 64,
              color: ShiyiColor.primaryColor.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              '纹样定制功能',
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

