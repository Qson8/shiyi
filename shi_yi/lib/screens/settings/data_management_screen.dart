import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../utils/shiyi_color.dart';
import '../../utils/shiyi_font.dart';
import '../../services/settings_service.dart';
import '../../services/database_service.dart';
import '../../services/wardrobe_repository.dart';
import '../../services/knowledge_repository.dart';

/// 数据管理页面
class DataManagementScreen extends StatefulWidget {
  const DataManagementScreen({Key? key}) : super(key: key);

  @override
  State<DataManagementScreen> createState() => _DataManagementScreenState();
}

class _DataManagementScreenState extends State<DataManagementScreen> {
  int _databaseSize = 0;
  Map<String, dynamic> _cacheInfo = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDataInfo();
  }

  Future<void> _loadDataInfo() async {
    setState(() => _isLoading = true);
    final size = await SettingsService.getDatabaseSize();
    final cacheInfo = await SettingsService.getCacheInfo();
    setState(() {
      _databaseSize = size;
      _cacheInfo = cacheInfo;
      _isLoading = false;
    });
  }

  Future<void> _clearCache() async {
    final imageCacheSize = _cacheInfo['imageCache'] as int? ?? 0;
    final tempFileSize = _cacheInfo['tempFiles'] as int? ?? 0;
    final totalCacheSize = _cacheInfo['total'] as int? ?? 0;
    
    if (totalCacheSize == 0) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('暂无缓存可清理'),
            backgroundColor: Colors.orange,
          ),
        );
      }
      return;
    }

    final result = await showDialog<Map<String, bool>>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (dialogContext, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text('清理缓存', style: ShiyiFont.titleStyle),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '选择要清理的缓存类型：',
                  style: ShiyiFont.bodyStyle.copyWith(fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 16),
                if (imageCacheSize > 0)
                  CheckboxListTile(
                    title: Text('图片缓存', style: ShiyiFont.bodyStyle),
                    subtitle: Text(
                      SettingsService.formatFileSize(imageCacheSize),
                      style: ShiyiFont.smallStyle,
                    ),
                    value: true,
                    onChanged: (value) {},
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding: EdgeInsets.zero,
                  ),
                if (tempFileSize > 0)
                  CheckboxListTile(
                    title: Text('临时文件', style: ShiyiFont.bodyStyle),
                    subtitle: Text(
                      SettingsService.formatFileSize(tempFileSize),
                      style: ShiyiFont.smallStyle,
                    ),
                    value: true,
                    onChanged: (value) {},
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding: EdgeInsets.zero,
                  ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: ShiyiColor.bgColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '总计',
                        style: ShiyiFont.bodyStyle.copyWith(fontWeight: FontWeight.w500),
                      ),
                      Text(
                        SettingsService.formatFileSize(totalCacheSize),
                        style: ShiyiFont.bodyStyle.copyWith(
                          color: ShiyiColor.primaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '注意：此操作不会删除您的数据，只清理缓存文件。',
                  style: ShiyiFont.smallStyle.copyWith(
                    color: ShiyiColor.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, null),
              child: Text('取消', style: TextStyle(color: ShiyiColor.textSecondary)),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, {
                'clearImageCache': imageCacheSize > 0,
                'clearTempFiles': tempFileSize > 0,
              }),
              child: Text('确定清理', style: TextStyle(color: ShiyiColor.primaryColor)),
            ),
          ],
        ),
      ),
    );

    if (result != null && mounted) {
      // 显示清理进度
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => PopScope(
          canPop: false,
          child: AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 16),
                Text('正在清理缓存...', style: ShiyiFont.bodyStyle),
              ],
            ),
          ),
        ),
      );

      final clearResult = await SettingsService.clearCache(
        clearImageCache: result['clearImageCache'] ?? false,
        clearTempFiles: result['clearTempFiles'] ?? false,
      );

      if (mounted) {
        Navigator.pop(context); // 关闭进度对话框
        
        if (clearResult['success'] == true) {
          final clearedSize = clearResult['totalCleared'] as int;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('已清理 ${SettingsService.formatFileSize(clearedSize)} 缓存'),
              backgroundColor: ShiyiColor.primaryColor,
              duration: const Duration(seconds: 2),
            ),
          );
          // 刷新数据
          _loadDataInfo();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('清理失败: ${clearResult['error']}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final wardrobeRepo = WardrobeRepository();
    final knowledgeRepo = KnowledgeRepository();
    final wardrobeStats = wardrobeRepo.getStatistics();
    final knowledgeCount = knowledgeRepo.getAll().length;

    return Scaffold(
      backgroundColor: ShiyiColor.bgColor,
      appBar: AppBar(
        title: Text('数据存储', style: ShiyiFont.titleStyle),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: ShiyiColor.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                // 存储信息卡片
                _buildInfoCard(
                  '存储信息',
                  [
                    _buildInfoRow('数据库大小', SettingsService.formatFileSize(_databaseSize)),
                    _buildInfoRow('衣橱数量', '${wardrobeStats['total']} 件'),
                    _buildInfoRow('知识库数量', '$knowledgeCount 条'),
                  ],
                ),
                const SizedBox(height: 20),
                
                // 缓存信息卡片
                _buildInfoCard(
                  '缓存信息',
                  [
                    _buildInfoRow(
                      '图片缓存',
                      SettingsService.formatFileSize(_cacheInfo['imageCache'] as int? ?? 0),
                    ),
                    _buildInfoRow(
                      '临时文件',
                      SettingsService.formatFileSize(_cacheInfo['tempFiles'] as int? ?? 0),
                    ),
                    _buildInfoRow(
                      '缓存总计',
                      SettingsService.formatFileSize(_cacheInfo['total'] as int? ?? 0),
                      isHighlight: true,
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                
                // 数据统计卡片
                _buildInfoCard(
                  '数据统计',
                  [
                    _buildInfoRow('唐代', '${wardrobeStats['tang']} 件'),
                    _buildInfoRow('宋代', '${wardrobeStats['song']} 件'),
                    _buildInfoRow('明代', '${wardrobeStats['ming']} 件'),
                  ],
                ),
                const SizedBox(height: 20),

                // 操作按钮
                _buildActionButton(
                  icon: Icons.refresh,
                  title: '刷新信息',
                  onTap: _loadDataInfo,
                ),
                const SizedBox(height: 12),
                _buildActionButton(
                  icon: Icons.cleaning_services,
                  title: '清理缓存',
                  onTap: _clearCache,
                  isDestructive: false,
                ),
              ],
            ),
    );
  }

  Widget _buildInfoCard(String title, List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(20),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: ShiyiFont.titleStyle.copyWith(fontSize: 16)),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isHighlight = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: ShiyiFont.bodyStyle.copyWith(
              color: ShiyiColor.textSecondary,
            ),
          ),
          Text(
            value,
            style: ShiyiFont.bodyStyle.copyWith(
              fontWeight: FontWeight.w500,
              color: isHighlight ? ShiyiColor.primaryColor : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: ShiyiColor.borderColor, width: 0.5),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(icon, color: isDestructive ? Colors.red : ShiyiColor.primaryColor),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(title, style: ShiyiFont.bodyStyle),
                ),
                Icon(Icons.chevron_right, color: ShiyiColor.textSecondary.withOpacity(0.5)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

