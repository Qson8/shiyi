import 'package:flutter/material.dart';
import '../../utils/shiyi_color.dart';
import '../../utils/shiyi_font.dart';

/// 隐私政策页面
class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ShiyiColor.bgColor,
      appBar: AppBar(
        title: Text('隐私政策', style: ShiyiFont.titleStyle),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: ShiyiColor.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: ShiyiColor.borderColor, width: 0.5),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '隐私政策',
                  style: ShiyiFont.titleStyle.copyWith(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 20),
                _buildSection(
                  '数据收集',
                  '拾衣坊是一款离线应用，所有数据都存储在您的设备本地。我们不会收集、上传或分享您的任何个人信息或使用数据。',
                ),
                const SizedBox(height: 20),
                _buildSection(
                  '数据存储',
                  '您的衣橱数据、收藏的知识内容等所有信息都存储在设备本地数据库中，不会上传到任何服务器。',
                ),
                const SizedBox(height: 20),
                _buildSection(
                  '数据安全',
                  '我们采用本地加密存储技术保护您的数据安全。建议您定期使用备份功能导出数据，以防设备损坏导致数据丢失。',
                ),
                const SizedBox(height: 20),
                _buildSection(
                  '第三方服务',
                  '应用使用Flutter框架和Hive数据库等开源技术，这些技术不会收集您的个人信息。',
                ),
                const SizedBox(height: 20),
                _buildSection(
                  '权限说明',
                  '应用可能需要访问存储权限以保存和读取数据文件，这些权限仅用于本地数据管理，不会用于其他目的。',
                ),
                const SizedBox(height: 20),
                _buildSection(
                  '更新说明',
                  '本隐私政策可能会随应用更新而调整，我们会及时通知您相关变更。',
                ),
                const SizedBox(height: 20),
                Text(
                  '最后更新：2026年01月05日',
                  style: ShiyiFont.smallStyle.copyWith(
                    color: ShiyiColor.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: ShiyiFont.bodyStyle.copyWith(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          content,
          style: ShiyiFont.bodyStyle.copyWith(
            fontSize: 14,
            color: ShiyiColor.textSecondary,
            height: 1.6,
          ),
        ),
      ],
    );
  }
}

