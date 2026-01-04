import 'package:flutter/material.dart';
import '../../models/knowledge_item.dart';
import '../../services/knowledge_repository.dart';
import '../../utils/shiyi_color.dart';
import '../../utils/shiyi_font.dart';
import '../../utils/shiyi_icon.dart';
import '../../utils/shiyi_decoration.dart';

class KnowledgeDetailScreen extends StatelessWidget {
  final KnowledgeItem item;

  const KnowledgeDetailScreen({Key? key, required this.item}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final repository = KnowledgeRepository();

    return Scaffold(
      backgroundColor: ShiyiColor.bgColor,
      body: SafeArea(
        child: Column(
          children: [
            // 自定义顶部栏 - 清新国风设计
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  IconButton(
                    icon: ShiyiIcon.backIcon,
                    onPressed: () => Navigator.pop(context),
                  ),
                  Expanded(
                    child: Text(
                      '拾衣 · 知识',
                      style: ShiyiFont.titleStyle.copyWith(color: ShiyiColor.primaryColor),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      item.isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                      color: item.isFavorite ? Colors.red[400] : ShiyiColor.textSecondary,
                    ),
                    onPressed: () async {
                      await repository.toggleFavorite(item.id);
                      if (context.mounted) {
                        Navigator.pop(context);
                      }
                    },
                  ),
                ],
              ),
            ),

            // 主内容区
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 分类标签 - 清新国风设计
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: ShiyiColor.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: ShiyiColor.primaryColor.withOpacity(0.3)),
                      ),
                      child: Text(
                        item.category,
                        style: ShiyiFont.smallStyle.copyWith(
                          color: ShiyiColor.primaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    // 标题
                    Text(
                      item.title,
                      style: ShiyiFont.titleStyle.copyWith(fontSize: 20),
                    ),
                    const SizedBox(height: 20),
                    // 内容卡片 - 清新国风设计
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: ShiyiDecoration.cardDecoration,
                      child: Text(
                        item.content,
                        style: ShiyiFont.bodyStyle.copyWith(
                          height: 1.6,
                          color: ShiyiColor.textPrimary,
                        ),
                      ),
                    ),
                    // 标签
                    if (item.tags.isNotEmpty) ...[
                      const SizedBox(height: 24),
                      Text(
                        '标签',
                        style: ShiyiFont.bodyStyle.copyWith(fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: item.tags.map((tag) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: ShiyiColor.bgColor,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: ShiyiColor.borderColor),
                            ),
                            child: Text(
                              tag,
                              style: ShiyiFont.smallStyle.copyWith(color: ShiyiColor.textSecondary),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
