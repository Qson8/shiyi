import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../utils/shiyi_color.dart';
import '../../utils/shiyi_font.dart';

/// 帮助与反馈页面
class HelpScreen extends StatelessWidget {
  const HelpScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ShiyiColor.bgColor,
      appBar: AppBar(
        title: Text('帮助与反馈', style: ShiyiFont.titleStyle),
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
          // 使用指南
          _buildSection(
            title: '使用指南',
            children: [
              _buildHelpItem(
                '如何添加汉服到衣橱？',
                '进入"衣橱"页面，点击底部的添加按钮，填写汉服信息（名称、朝代、类型、尺码等）并保存即可。',
              ),
              _buildHelpItem(
                '如何查看3D模型？',
                '在首页点击3D模型区域，或进入"更多3D模型"页面浏览所有模型。',
              ),
              _buildHelpItem(
                '如何备份数据？',
                '在设置页面进入"数据备份"，点击"导出数据"即可将数据保存为JSON格式。',
              ),
            ],
          ),
          const SizedBox(height: 24),

          // 常见问题
          _buildSection(
            title: '常见问题',
            children: [
              _buildHelpItem(
                '数据会丢失吗？',
                '所有数据都存储在本地，不会上传到服务器。建议定期备份数据。',
              ),
              _buildHelpItem(
                '3D模型加载慢怎么办？',
                '可以检查网络连接，或尝试刷新模型。',
              ),
            ],
          ),
          const SizedBox(height: 24),

          // 反馈
          _buildSection(
            title: '反馈',
            children: [
              _buildActionItem(
                icon: Icons.email,
                title: '反馈邮箱',
                subtitle: 'support@hanfucn.com',
                onTap: () async {
                  const String email = 'support@hanfucn.com';
                  final Uri emailUri = Uri(
                    scheme: 'mailto',
                    path: email,
                    query: 'subject=拾衣坊反馈&body=您好，\n\n我想反馈以下问题：\n\n',
                  );
                  
                  try {
                    // 尝试打开邮件应用
                    if (await canLaunchUrl(emailUri)) {
                      await launchUrl(emailUri);
                    } else {
                      // 无法打开邮件应用，复制邮件地址到剪贴板
                      await Clipboard.setData(ClipboardData(text: email));
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('邮件地址已复制到剪贴板：$email'),
                            backgroundColor: ShiyiColor.primaryColor,
                            duration: const Duration(seconds: 2),
                            action: SnackBarAction(
                              label: '确定',
                              textColor: Colors.white,
                              onPressed: () {},
                            ),
                          ),
                        );
                      }
                    }
                  } catch (e) {
                    // 发生错误，尝试复制邮件地址
                    try {
                      await Clipboard.setData(ClipboardData(text: email));
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('邮件地址已复制到剪贴板：$email'),
                            backgroundColor: ShiyiColor.primaryColor,
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      }
                    } catch (copyError) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('操作失败，请手动记录邮件地址：$email'),
                            backgroundColor: Colors.red,
                            duration: const Duration(seconds: 3),
                          ),
                        );
                      }
                    }
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSection({required String title, required List<Widget> children}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: ShiyiFont.bodyStyle.copyWith(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: ShiyiColor.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: ShiyiColor.borderColor, width: 0.5),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildHelpItem(String question, String answer) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: ShiyiColor.borderColor, width: 0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            question,
            style: ShiyiFont.bodyStyle.copyWith(
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            answer,
            style: ShiyiFont.bodyStyle.copyWith(
              fontSize: 13,
              color: ShiyiColor.textSecondary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(icon, color: ShiyiColor.primaryColor, size: 24),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: ShiyiFont.bodyStyle.copyWith(
                      fontWeight: FontWeight.w600,
                    )),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: ShiyiFont.smallStyle.copyWith(
                        color: ShiyiColor.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: ShiyiColor.textSecondary.withOpacity(0.5)),
            ],
          ),
        ),
      ),
    );
  }
}

