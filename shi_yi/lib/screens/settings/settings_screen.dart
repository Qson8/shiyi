import 'package:flutter/material.dart';
import '../../utils/shiyi_color.dart';
import '../../utils/shiyi_font.dart';
import '../../utils/shiyi_transition.dart';
import 'data_management_screen.dart';
import 'backup_screen.dart';
import 'help_screen.dart';
import 'privacy_screen.dart';

/// 设置页面
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ShiyiColor.bgColor,
      appBar: AppBar(
        title: Text(
          '设置',
          style: ShiyiFont.titleStyle.copyWith(
            color: ShiyiColor.textPrimary,
            fontWeight: FontWeight.w500,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: ShiyiColor.textPrimary,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        children: [
          // 关于应用
          _buildSectionTitle('关于应用'),
          _buildSettingItem(
            icon: Icons.info_outline,
            title: '关于拾衣坊',
            subtitle: '版本 1.0.0',
            onTap: () {
              _showAboutDialog(context);
            },
          ),
          const SizedBox(height: 24),
          
          // 数据管理
          _buildSectionTitle('数据管理'),
          _buildSettingItem(
            icon: Icons.storage,
            title: '数据存储',
            subtitle: '本地数据管理',
            onTap: () {
              Navigator.push(
                context,
                ShiyiTransition.freshSlideTransition(const DataManagementScreen()),
              );
            },
          ),
          _buildSettingItem(
            icon: Icons.backup,
            title: '数据备份',
            subtitle: '备份与恢复',
            onTap: () {
              Navigator.push(
                context,
                ShiyiTransition.freshSlideTransition(const BackupScreen()),
              );
            },
          ),
          const SizedBox(height: 24),
          
          // 其他
          _buildSectionTitle('其他'),
          _buildSettingItem(
            icon: Icons.help_outline,
            title: '帮助与反馈',
            subtitle: '使用帮助',
            onTap: () {
              Navigator.push(
                context,
                ShiyiTransition.freshSlideTransition(const HelpScreen()),
              );
            },
          ),
          _buildSettingItem(
            icon: Icons.privacy_tip,
            title: '隐私政策',
            subtitle: '了解隐私保护',
            onTap: () {
              Navigator.push(
                context,
                ShiyiTransition.freshSlideTransition(const PrivacyScreen()),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, top: 8),
      child: Text(
        title,
        style: ShiyiFont.bodyStyle.copyWith(
          fontSize: 13,
          color: ShiyiColor.textSecondary,
          fontWeight: FontWeight.w500,
          letterSpacing: 1,
        ),
      ),
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? trailing,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: ShiyiColor.borderColor,
          width: 0.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: ShiyiColor.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    icon,
                    color: ShiyiColor.primaryColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: ShiyiFont.bodyStyle.copyWith(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: ShiyiColor.textPrimary,
                        ),
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          subtitle,
                          style: ShiyiFont.smallStyle.copyWith(
                            color: ShiyiColor.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (trailing != null)
                  trailing
                else
                  Icon(
                    Icons.chevron_right,
                    color: ShiyiColor.textSecondary.withOpacity(0.5),
                    size: 20,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          '关于拾衣坊',
          style: ShiyiFont.titleStyle.copyWith(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '拾衣坊是一款专注于汉服文化的应用，提供汉服知识、3D展示、衣橱管理等功能。',
              style: ShiyiFont.bodyStyle.copyWith(
                fontSize: 14,
                height: 1.6,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              '版本：1.0.0',
              style: ShiyiFont.smallStyle.copyWith(
                color: ShiyiColor.textSecondary,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              '确定',
              style: TextStyle(color: ShiyiColor.primaryColor),
            ),
          ),
        ],
      ),
    );
  }
}

