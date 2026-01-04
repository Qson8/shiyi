import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/knowledge_item.dart';
import '../../services/knowledge_repository.dart';
import '../../widgets/neumorphic_card.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/loading_indicator.dart';
import '../../utils/constants.dart';
import '../../utils/shiyi_color.dart';
import '../../utils/shiyi_font.dart';
import '../../utils/shiyi_icon.dart';
import '../../utils/shiyi_transition.dart';
import 'knowledge_detail_screen.dart';

class KnowledgeListScreen extends StatefulWidget {
  const KnowledgeListScreen({Key? key}) : super(key: key);

  @override
  State<KnowledgeListScreen> createState() => _KnowledgeListScreenState();
}

class _KnowledgeListScreenState extends State<KnowledgeListScreen> {
  List<KnowledgeItem> _items = [];
  List<KnowledgeItem> _filteredItems = [];
  bool _isLoading = true;
  String _selectedCategory = '全部';
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    // 使用Provider提供的共享Repository实例
    final repository = Provider.of<KnowledgeRepository>(context, listen: false);

    // 确保数据已加载（如果缓存为空，尝试从JSON加载）
    if (repository.getAll().isEmpty) {
      await repository.loadFromJson();
    }

    setState(() {
      _items = repository.getAll();
      // 去重：根据ID去重
      final seenIds = <String>{};
      _items = _items.where((item) {
        if (seenIds.contains(item.id)) {
          return false;
        }
        return seenIds.add(item.id);
      }).toList();
      _filterItems();
      _isLoading = false;
    });
  }

  void _filterItems() {
    setState(() {
      if (_selectedCategory == '全部' && _searchQuery.isEmpty) {
        _filteredItems = List.from(_items);
      } else {
        _filteredItems = _items.where((item) {
          final categoryMatch = _selectedCategory == '全部' || item.category == _selectedCategory;
          final searchMatch = _searchQuery.isEmpty ||
              item.title.contains(_searchQuery) ||
              item.content.contains(_searchQuery) ||
              item.tags.any((tag) => tag.contains(_searchQuery));
          return categoryMatch && searchMatch;
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: ShiyiColor.bgColor,
        body: const Center(child: LoadingIndicator()),
      );
    }

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
                    icon: Icon(Icons.search, color: ShiyiColor.primaryColor),
                    onPressed: _showSearchDialog,
                  ),
                ],
              ),
            ),

            // 筛选栏
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Text(
                    '分类:',
                    style: ShiyiFont.smallStyle.copyWith(color: ShiyiColor.textSecondary),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: ['全部', '服饰文化', '汉服知识', '穿着礼仪', '历史渊源'].map((category) {
                          final isSelected = category == _selectedCategory;
                          return Container(
                            margin: const EdgeInsets.only(right: 8),
                            child: FilterChip(
                              label: Text(
                                category,
                                style: ShiyiFont.smallStyle.copyWith(
                                  color: isSelected ? Colors.white : ShiyiColor.primaryColor,
                                ),
                              ),
                              selected: isSelected,
                              onSelected: (selected) {
                                setState(() {
                                  _selectedCategory = category;
                                  _filterItems();
                                });
                              },
                              backgroundColor: ShiyiColor.bgColor,
                              selectedColor: ShiyiColor.primaryColor,
                              checkmarkColor: Colors.white,
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // 列表
            Expanded(
              child: _filteredItems.isEmpty
                  ? EmptyState(
                      icon: Icons.menu_book,
                      title: '暂无内容',
                      message: _searchQuery.isNotEmpty ? '没有找到相关结果' : '知识库为空',
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(8),
                      itemCount: _filteredItems.length,
                      itemBuilder: (context, index) {
                        final item = _filteredItems[index];
                        return NeumorphicCard(
                          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                          padding: const EdgeInsets.all(18),
                          onTap: () {
                            Navigator.push(
                              context,
                              ShiyiTransition.freshSlideTransition(
                                KnowledgeDetailScreen(item: item),
                              ),
                            );
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
                                      color: ShiyiColor.primaryColor.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Icon(Icons.menu_book, color: ShiyiColor.primaryColor),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item.title,
                                          style: ShiyiFont.bodyStyle.copyWith(fontWeight: FontWeight.w500),
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
                                      item.isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                                      color: item.isFavorite ? Colors.red[400] : ShiyiColor.textSecondary,
                                      size: 22,
                                    ),
                                    onPressed: () async {
                                      final repository = Provider.of<KnowledgeRepository>(context, listen: false);
                                      await repository.toggleFavorite(item.id);
                                      _loadData();
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
                                        style: ShiyiFont.smallStyle.copyWith(color: ShiyiColor.textSecondary),
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

  void _showSearchDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white.withOpacity(0.9),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text(
          '搜索',
          style: ShiyiFont.bodyStyle.copyWith(fontWeight: FontWeight.w500),
        ),
        content: TextField(
          autofocus: true,
          style: ShiyiFont.bodyStyle,
          decoration: InputDecoration(
            hintText: '输入关键词搜索',
            hintStyle: ShiyiFont.smallStyle,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: ShiyiColor.borderColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: ShiyiColor.primaryColor),
            ),
            filled: true,
            fillColor: ShiyiColor.bgColor,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          onChanged: (value) {
            setState(() {
              _searchQuery = value;
              _filterItems();
            });
          },
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _searchQuery = '';
                _filterItems();
              });
              Navigator.pop(context);
            },
            child: Text(
              '清除',
              style: TextStyle(color: ShiyiColor.textSecondary),
            ),
          ),
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
