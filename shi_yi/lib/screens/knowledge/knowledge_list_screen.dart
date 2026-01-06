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
import '../../widgets/highlight_text.dart';
import 'knowledge_detail_screen.dart';
import 'favorites_screen.dart';

class KnowledgeListScreen extends StatefulWidget {
  const KnowledgeListScreen({Key? key}) : super(key: key);

  @override
  State<KnowledgeListScreen> createState() => _KnowledgeListScreenState();
}

class _KnowledgeListScreenState extends State<KnowledgeListScreen> {
  List<KnowledgeItem> _items = [];
  List<KnowledgeItem> _filteredItems = [];
  bool _isLoading = false; // 改为false，页面结构保持稳定
  String _selectedCategory = '全部';
  String _searchQuery = '';
  List<String> _categories = ['全部']; // 动态分类列表

  @override
  void initState() {
    super.initState();
    // 立即加载数据，与"我的衣橱"保持一致
    _loadData();
  }

  Future<void> _loadData() async {
    if (!mounted) return;
    
    // 先尝试从缓存加载，如果缓存有数据立即显示
    final repository = Provider.of<KnowledgeRepository>(context, listen: false);
    final cachedItems = repository.getAll();
    
    if (cachedItems.isNotEmpty) {
      // 缓存有数据，立即显示，不显示加载状态
      if (mounted) {
        setState(() {
          _items = cachedItems;
          // 去重：根据ID去重
          final seenIds = <String>{};
          _items = _items.where((item) {
            if (seenIds.contains(item.id)) {
              return false;
            }
            return seenIds.add(item.id);
          }).toList();
          // 从数据中提取所有分类
          _updateCategories();
          _filterItems();
        });
      }
    } else {
      // 缓存为空，显示加载状态并加载数据
      if (mounted) {
        setState(() => _isLoading = true);
      }
      
      // 从JSON加载数据
      await repository.loadFromJson();
      
      if (!mounted) return;
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
        // 从数据中提取所有分类
        _updateCategories();
        _filterItems();
        _isLoading = false;
      });
    }
  }

  // 从数据中提取所有分类
  void _updateCategories() {
    final categories = <String>{'全部'};
    for (var item in _items) {
      if (item.category.isNotEmpty) {
        categories.add(item.category);
      }
    }
    _categories = categories.toList()..sort((a, b) {
      if (a == '全部') return -1;
      if (b == '全部') return 1;
      return a.compareTo(b);
    });
  }

  void _filterItems() {
    setState(() {
      if (_selectedCategory == '全部' && _searchQuery.isEmpty) {
        _filteredItems = List.from(_items);
      } else {
        _filteredItems = _items.where((item) {
          // 分类匹配
          final categoryMatch = _selectedCategory == '全部' || item.category == _selectedCategory;
          
          // 搜索匹配（改进的搜索逻辑）
          bool searchMatch = true;
          if (_searchQuery.isNotEmpty) {
            final query = _searchQuery.trim().toLowerCase();
            // 支持多关键词搜索（空格分隔）
            final keywords = query.split(' ').where((k) => k.isNotEmpty).toList();
            
            if (keywords.isNotEmpty) {
              // 所有关键词都要匹配（AND逻辑）
              searchMatch = keywords.every((keyword) {
                return item.title.toLowerCase().contains(keyword) ||
                    item.content.toLowerCase().contains(keyword) ||
                    item.category.toLowerCase().contains(keyword) ||
                    item.tags.any((tag) => tag.toLowerCase().contains(keyword));
              });
            }
          }
          
          return categoryMatch && searchMatch;
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
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
                    child: _searchQuery.isEmpty
                        ? Text(
                            '拾衣 · 知识',
                            style: ShiyiFont.titleStyle.copyWith(color: ShiyiColor.primaryColor),
                            textAlign: TextAlign.center,
                          )
                        : GestureDetector(
                            onTap: _showSearchDialog,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.search,
                                  color: ShiyiColor.primaryColor,
                                  size: 18,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    _searchQuery,
                                    style: ShiyiFont.bodyStyle.copyWith(
                                      color: ShiyiColor.primaryColor,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                GestureDetector(
                                  onTap: _clearSearch,
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      color: ShiyiColor.primaryColor.withOpacity(0.1),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      Icons.close,
                                      color: ShiyiColor.primaryColor,
                                      size: 16,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.favorite,
                      color: ShiyiColor.primaryColor,
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        ShiyiTransition.freshSlideTransition(const FavoritesScreen()),
                      ).then((_) => _loadData());
                    },
                  ),
                  IconButton(
                    icon: Icon(
                      _searchQuery.isEmpty ? Icons.search : Icons.edit,
                      color: ShiyiColor.primaryColor,
                    ),
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
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: _categories.map((category) {
                          final isSelected = category == _selectedCategory;
                          return Container(
                            margin: const EdgeInsets.only(right: 8),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () {
                                  setState(() {
                                    _selectedCategory = category;
                                    _filterItems();
                                  });
                                },
                                borderRadius: BorderRadius.circular(20),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? ShiyiColor.primaryColor
                                        : ShiyiColor.bgColor,
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: isSelected
                                          ? ShiyiColor.primaryColor
                                          : ShiyiColor.borderColor,
                                      width: 0.5,
                                    ),
                                  ),
                                  child: Text(
                                    category,
                                    style: ShiyiFont.smallStyle.copyWith(
                                      color: isSelected ? Colors.white : ShiyiColor.primaryColor,
                                      fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // 列表 - 保持页面结构稳定，只在内容区域显示加载状态
            Expanded(
              child: _isLoading
                  ? const Center(child: LoadingIndicator())
                  : _filteredItems.isEmpty
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
                                            HighlightText(
                                              text: item.title,
                                              highlight: _searchQuery,
                                              style: ShiyiFont.bodyStyle.copyWith(fontWeight: FontWeight.w500),
                                              highlightStyle: ShiyiFont.bodyStyle.copyWith(
                                                fontWeight: FontWeight.w600,
                                                backgroundColor: Colors.yellow.withOpacity(0.4),
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
                                              child: HighlightText(
                                                text: item.category,
                                                highlight: _searchQuery,
                                                style: ShiyiFont.smallStyle.copyWith(
                                                  color: ShiyiColor.primaryColor,
                                                ),
                                                highlightStyle: ShiyiFont.smallStyle.copyWith(
                                                  color: ShiyiColor.primaryColor,
                                                  backgroundColor: Colors.yellow.withOpacity(0.4),
                                                  fontWeight: FontWeight.bold,
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
                                  HighlightText(
                                    text: item.content,
                                    highlight: _searchQuery,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: ShiyiFont.smallStyle.copyWith(
                                      color: ShiyiColor.textSecondary,
                                      height: 1.5,
                                    ),
                                    highlightStyle: ShiyiFont.smallStyle.copyWith(
                                      color: ShiyiColor.textSecondary,
                                      backgroundColor: Colors.yellow.withOpacity(0.4),
                                      fontWeight: FontWeight.bold,
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

  void _clearSearch() {
    setState(() {
      _searchQuery = '';
      _filterItems();
    });
  }

  void _showSearchDialog() {
    final TextEditingController controller = TextEditingController(text: _searchQuery);
    
    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: Colors.white.withOpacity(0.95),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Icon(Icons.search, color: ShiyiColor.primaryColor, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '搜索知识库',
                  style: ShiyiFont.bodyStyle.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ),
              if (_searchQuery.isNotEmpty)
                IconButton(
                  icon: Icon(Icons.close, color: ShiyiColor.textSecondary, size: 20),
                  onPressed: () {
                    controller.clear();
                    setDialogState(() {});
                    setState(() {
                      _searchQuery = '';
                      _filterItems();
                    });
                  },
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: controller,
                autofocus: true,
                style: ShiyiFont.bodyStyle,
                decoration: InputDecoration(
                  hintText: '输入关键词搜索（支持多个关键词，空格分隔）',
                  hintStyle: ShiyiFont.smallStyle.copyWith(
                    color: ShiyiColor.textSecondary.withOpacity(0.7),
                  ),
                  prefixIcon: Icon(Icons.search, color: ShiyiColor.primaryColor),
                  suffixIcon: controller.text.isNotEmpty
                      ? IconButton(
                          icon: Icon(Icons.clear, color: ShiyiColor.textSecondary),
                          onPressed: () {
                            controller.clear();
                            setDialogState(() {});
                            setState(() {
                              _searchQuery = '';
                              _filterItems();
                            });
                          },
                        )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: ShiyiColor.borderColor),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: ShiyiColor.primaryColor, width: 2),
                  ),
                  filled: true,
                  fillColor: ShiyiColor.bgColor,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                onChanged: (value) {
                  setDialogState(() {});
                  setState(() {
                    _searchQuery = value;
                    _filterItems();
                  });
                },
                onSubmitted: (value) {
                  Navigator.pop(context);
                },
              ),
              if (_searchQuery.isNotEmpty) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: ShiyiColor.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: ShiyiColor.primaryColor,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '找到 ${_filteredItems.length} 条结果',
                          style: ShiyiFont.smallStyle.copyWith(
                            color: ShiyiColor.primaryColor,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                controller.clear();
                setState(() {
                  _searchQuery = '';
                  _filterItems();
                });
                Navigator.pop(context);
              },
              child: Text(
                '清除',
                style: TextStyle(
                  color: _searchQuery.isEmpty
                      ? ShiyiColor.textSecondary.withOpacity(0.5)
                      : ShiyiColor.textSecondary,
                ),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                '完成',
                style: TextStyle(
                  color: ShiyiColor.primaryColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    ).then((_) {
      controller.dispose();
    });
  }
}
