import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import '../../utils/shiyi_color.dart';
import '../../utils/shiyi_font.dart';
import '../../services/settings_service.dart';

/// 数据备份页面
class BackupScreen extends StatefulWidget {
  const BackupScreen({Key? key}) : super(key: key);

  @override
  State<BackupScreen> createState() => _BackupScreenState();
}

class _BackupScreenState extends State<BackupScreen> {
  bool _isExporting = false;
  bool _isImporting = false;

  Future<void> _exportData() async {
    setState(() => _isExporting = true);
    
    try {
      final jsonData = await SettingsService.exportData();
      if (jsonData == null) {
        if (mounted) {
          _showError('导出失败，请重试');
        }
        return;
      }

      // 保存到文件
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/shiyi_backup_${DateTime.now().millisecondsSinceEpoch}.json');
      await file.writeAsString(jsonData);

      // 复制到剪贴板
      await Clipboard.setData(ClipboardData(text: jsonData));

      if (mounted) {
        _showSuccess('数据已导出并复制到剪贴板\n文件路径: ${file.path}');
      }
    } catch (e) {
      if (mounted) {
        _showError('导出失败: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isExporting = false);
      }
    }
  }

  Future<void> _importData() async {
    // 从剪贴板读取
    final clipboardData = await Clipboard.getData(Clipboard.kTextPlain);
    if (clipboardData?.text == null || clipboardData!.text!.isEmpty) {
      _showError('剪贴板中没有数据');
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('导入数据', style: ShiyiFont.titleStyle),
        content: const Text('导入数据将合并到现有数据中，是否继续？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('取消', style: TextStyle(color: ShiyiColor.textSecondary)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('确定', style: TextStyle(color: ShiyiColor.primaryColor)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isImporting = true);

    try {
      final result = await SettingsService.importData(clipboardData.text!);
      if (mounted) {
        if (result['success'] == true) {
          _showSuccess(
            '导入成功！\n衣橱: ${result['wardrobeCount']} 件\n知识库: ${result['knowledgeCount']} 条',
          );
        } else {
          _showError('导入失败: ${result['error']}');
        }
      }
    } catch (e) {
      if (mounted) {
        _showError('导入失败: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isImporting = false);
      }
    }
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: ShiyiColor.primaryColor,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ShiyiColor.bgColor,
      appBar: AppBar(
        title: Text('数据备份', style: ShiyiFont.titleStyle),
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
          // 说明卡片
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: ShiyiColor.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: ShiyiColor.primaryColor.withOpacity(0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.info_outline, color: ShiyiColor.primaryColor, size: 20),
                    const SizedBox(width: 8),
                    Text('使用说明', style: ShiyiFont.bodyStyle.copyWith(
                      fontWeight: FontWeight.w600,
                      color: ShiyiColor.primaryColor,
                    )),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  '• 导出：将数据导出为JSON格式并复制到剪贴板\n'
                  '• 导入：从剪贴板读取JSON数据并导入\n'
                  '• 建议定期备份数据，以防丢失',
                  style: ShiyiFont.bodyStyle.copyWith(fontSize: 13),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // 导出按钮
          _buildActionCard(
            icon: Icons.upload,
            title: '导出数据',
            subtitle: '将数据导出为JSON格式',
            onTap: _exportData,
            isLoading: _isExporting,
            color: ShiyiColor.primaryColor,
          ),
          const SizedBox(height: 16),

          // 导入按钮
          _buildActionCard(
            icon: Icons.download,
            title: '导入数据',
            subtitle: '从剪贴板导入JSON数据',
            onTap: _importData,
            isLoading: _isImporting,
            color: Colors.blue,
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required bool isLoading,
    required Color color,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: ShiyiColor.borderColor, width: 0.5),
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
          onTap: isLoading ? null : onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: isLoading
                      ? SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(color),
                          ),
                        )
                      : Icon(icon, color: color, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: ShiyiFont.bodyStyle.copyWith(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
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
                if (!isLoading)
                  Icon(Icons.chevron_right, color: ShiyiColor.textSecondary.withOpacity(0.5)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

