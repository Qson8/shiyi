import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/knowledge_item.dart';
import '../../services/knowledge_repository.dart';
import '../../widgets/neumorphic_card.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/loading_indicator.dart';
import '../../utils/shiyi_color.dart';
import '../../utils/shiyi_font.dart';
import '../../utils/shiyi_icon.dart';
import '../../utils/shiyi_transition.dart';
import 'knowledge_detail_screen.dart';

/// 我的收藏页面
class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({Key? key}) : super(key: key);

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  List<KnowledgeItem> _favoriteItems = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // 当从详情页返回时，重新加载收藏列表
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    if (!mounted) return;

    setState(() => _isLoading = true);

    final repository = Provider.of<KnowledgeRepository>(context, listen: false);
    await repository.loadFromJson();

    if (!mounted) return;

    setState(() {
      _favoriteItems = repository.getAll().where((item) => item.isFavorite).toList();
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ShiyiColor.bgColor,
      body: SafeArea(
        child: Column(
          children: [
            // 自定义顶部栏
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
                      '我的收藏',
                      style: ShiyiFont.titleStyle.copyWith(color: ShiyiColor.primaryColor),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    color: ShiyiColor.primaryColor,
                    onPressed: _loadFavorites,
                  ),
                ],
              ),
            ),

            // 收藏统计
            if (_favoriteItems.isNotEmpty)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: ShiyiColor.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: ShiyiColor.primaryColor.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.favorite,
                      color: Colors.red[400],
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '共收藏 ${_favoriteItems.length} 条',
                      style: ShiyiFont.bodyStyle.copyWith(
                        color: ShiyiColor.primaryColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

            // 列表
            Expanded(
              child: _isLoading
                  ? const Center(child: LoadingIndicator())
                  : _favoriteItems.isEmpty
                      ? EmptyState(
                          icon: Icons.favorite_border,
                          title: '暂无收藏',
                          message: '收藏的知识内容会显示在这里',
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(8),
                          itemCount: _favoriteItems.length,
                          itemBuilder: (context, index) {
                            final item = _favoriteItems[index];
                            return NeumorphicCard(
                              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                              padding: const EdgeInsets.all(18),
                              onTap: () async {
                                await Navigator.push(
                                  context,
                                  ShiyiTransition.freshSlideTransition(
                                    KnowledgeDetailScreen(item: item),
                                  ),
                                );
                                // 返回时重新加载，因为可能取消了收藏
                                _loadFavorites();
                              },
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          color: Colors.red[50],
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: Icon(
                                          Icons.favorite,
                                          color: Colors.red[400],
                                          size: 20,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              item.title,
                                              style: ShiyiFont.bodyStyle.copyWith(
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Container(
                                              padding: const EdgeInsets.symmetric(
                                                horizontal: 8,
                                                vertical: 2,
                                              ),
                                              decoration: BoxDecoration(
                                                color: ShiyiColor.primaryColor.withOpacity(0.1),
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              child: Text(
                                                item.category,
                                                style: ShiyiFont.smallStyle.copyWith(
                                                  color: ShiyiColor.primaryColor,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      IconButton(
                                        icon: Icon(
                                          Icons.favorite_rounded,
                                          color: Colors.red[400],
                                          size: 22,
                                        ),
                                        onPressed: () async {
                                          final repository = Provider.of<KnowledgeRepository>(context, listen: false);
                                          await repository.toggleFavorite(item.id);
                                          _loadFavorites();
                                        },
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    item.content,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: ShiyiFont.smallStyle.copyWith(
                                      color: ShiyiColor.textSecondary,
                                      height: 1.5,
                                    ),
                                  ),
                                  if (item.tags.isNotEmpty) ...[
                                    const SizedBox(height: 12),
                                    Wrap(
                                      spacing: 6,
                                      runSpacing: 6,
                                      children: item.tags.map((tag) {
                                        return Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: ShiyiColor.bgColor,
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: Text(
                                            tag,
                                            style: ShiyiFont.smallStyle.copyWith(
                                              color: ShiyiColor.textSecondary,
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                  ],
                                ],
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}

