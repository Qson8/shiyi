import 'package:flutter/material.dart';
import '../../models/hanfu_item.dart';
import '../../services/wardrobe_repository.dart';
import '../../widgets/neumorphic_card.dart';
import '../../widgets/empty_state.dart';
import '../../utils/constants.dart';
import '../../utils/shiyi_color.dart';
import '../../utils/shiyi_font.dart';
import '../../utils/shiyi_icon.dart';
import '../../utils/shiyi_transition.dart';
import 'wardrobe_edit_screen.dart';

class WardrobeListScreen extends StatefulWidget {
  const WardrobeListScreen({Key? key}) : super(key: key);

  @override
  State<WardrobeListScreen> createState() => _WardrobeListScreenState();
}

class _WardrobeListScreenState extends State<WardrobeListScreen> {
  final WardrobeRepository _repository = WardrobeRepository();
  List<HanfuItem> _items = [];
  List<HanfuItem> _filteredItems = [];
  String _selectedDynasty = '全部';
  String _selectedType = '全部';
  bool _isGridView = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    setState(() {
      _items = _repository.getAll();
      _filterItems();
    });
  }

  void _filterItems() {
    setState(() {
      _filteredItems = _items.where((item) {
        final matchesDynasty = _selectedDynasty == '全部' || 
            item.dynasty == _selectedDynasty;
        final matchesType = _selectedType == '全部' || 
            item.type == _selectedType;
        return matchesDynasty && matchesType;
      }).toList();
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
                    child: Text(
                      '拾衣 · 衣橱',
                      style: ShiyiFont.titleStyle.copyWith(color: ShiyiColor.primaryColor),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      _isGridView ? Icons.view_list : Icons.view_module,
                      color: ShiyiColor.primaryColor,
                    ),
                    onPressed: () {
                      setState(() => _isGridView = !_isGridView);
                    },
                  ),
                ],
              ),
            ),

            // 筛选栏
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _selectedDynasty,
                      decoration: InputDecoration(
                        labelText: '朝代',
                        labelStyle: ShiyiFont.smallStyle,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: ShiyiColor.borderColor),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: ShiyiColor.primaryColor),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.8),
                      ),
                      style: ShiyiFont.bodyStyle,
                      items: ['全部', ...AppConstants.dynasties]
                          .map((dynasty) => DropdownMenuItem(
                                value: dynasty,
                                child: Text(dynasty, style: ShiyiFont.bodyStyle),
                              ))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedDynasty = value ?? '全部';
                          _filterItems();
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _selectedType,
                      decoration: InputDecoration(
                        labelText: '类型',
                        labelStyle: ShiyiFont.smallStyle,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: ShiyiColor.borderColor),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: ShiyiColor.primaryColor),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.8),
                      ),
                      style: ShiyiFont.bodyStyle,
                      items: ['全部', ...AppConstants.hanfuTypes]
                          .map((type) => DropdownMenuItem(
                                value: type,
                                child: Text(type, style: ShiyiFont.bodyStyle),
                              ))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedType = value ?? '全部';
                          _filterItems();
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),
            // 列表
            Expanded(
              child: _filteredItems.isEmpty
                  ? EmptyState(
                      icon: Icons.checkroom,
                      title: '衣橱为空',
                      message: '点击右下角按钮添加你的第一件汉服',
                      action: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: ShiyiColor.primaryColor.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.add, color: Colors.white),
                          onPressed: () => _addItem(),
                        ),
                      ),
                    )
                  : _isGridView
                      ? GridView.builder(
                          padding: const EdgeInsets.all(8),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 8,
                            mainAxisSpacing: 8,
                            childAspectRatio: 0.75,
                          ),
                          itemCount: _filteredItems.length,
                          itemBuilder: (context, index) {
                            final item = _filteredItems[index];
                            return _buildGridItem(context, item);
                          },
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(8),
                          itemCount: _filteredItems.length,
                          itemBuilder: (context, index) {
                            final item = _filteredItems[index];
                            return _buildListItem(context, item);
                          },
                        ),
            ),

            // 底部添加按钮 - 清新国风设计
            Container(
              padding: const EdgeInsets.all(16),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: ShiyiColor.primaryColor.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: IconButton(
                  icon: const Icon(Icons.add, color: Colors.white),
                  onPressed: () => _addItem(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListItem(BuildContext context, HanfuItem item) {
    return GestureDetector(
      onTap: () => _editItem(item),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.8),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: ShiyiColor.borderColor),
        ),
        child: Row(
          children: [
            // 占位图片 - 清新国风风格
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: ShiyiColor.bgColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: ShiyiColor.borderColor),
              ),
              child: item.imagePaths.isNotEmpty
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.asset(
                        item.imagePaths.first,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            Icon(Icons.checkroom, size: 40, color: ShiyiColor.textSecondary),
                      ),
                    )
                  : Icon(Icons.checkroom, size: 40, color: ShiyiColor.textSecondary),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: ShiyiFont.bodyStyle.copyWith(fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${item.dynasty} · ${item.type}',
                    style: ShiyiFont.smallStyle.copyWith(color: ShiyiColor.textSecondary),
                  ),
                  if (item.sizes.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      '尺码: ${item.sizes.keys.join(", ")}',
                      style: ShiyiFont.smallStyle.copyWith(color: ShiyiColor.textSecondary),
                    ),
                  ],
                ],
              ),
            ),
            IconButton(
              icon: Icon(Icons.delete_outline, color: ShiyiColor.textSecondary),
              onPressed: () => _deleteItem(item),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGridItem(BuildContext context, HanfuItem item) {
    return GestureDetector(
      onTap: () => _editItem(item),
      child: Container(
        margin: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.8),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: ShiyiColor.borderColor),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: ShiyiColor.bgColor,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(12),
                  ),
                ),
                child: item.imagePaths.isNotEmpty
                    ? ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(12),
                        ),
                        child: Image.asset(
                          item.imagePaths.first,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Center(
                                child: Icon(Icons.checkroom, size: 40, color: ShiyiColor.textSecondary),
                              ),
                        ),
                      )
                    : Center(
                        child: Icon(Icons.checkroom, size: 40, color: ShiyiColor.textSecondary),
                      ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: ShiyiFont.bodyStyle.copyWith(
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${item.dynasty} · ${item.type}',
                    style: ShiyiFont.smallStyle.copyWith(color: ShiyiColor.textSecondary),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _addItem() async {
    final result = await Navigator.push(
      context,
      ShiyiTransition.freshSlideTransition(const WardrobeEditScreen()),
    );
    if (result == true) {
      _loadData();
    }
  }

  void _editItem(HanfuItem item) async {
    final result = await Navigator.push(
      context,
      ShiyiTransition.freshSlideTransition(WardrobeEditScreen(item: item)),
    );
    if (result == true) {
      _loadData();
    }
  }

  void _deleteItem(HanfuItem item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white.withOpacity(0.9),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text(
          '确认删除',
          style: ShiyiFont.bodyStyle.copyWith(fontWeight: FontWeight.w500),
        ),
        content: Text(
          '确定要删除"${item.name}"吗？',
          style: ShiyiFont.smallStyle,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              '取消',
              style: TextStyle(color: ShiyiColor.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () async {
              await _repository.delete(item.id);
              Navigator.pop(context);
              _loadData();
            },
            child: const Text(
              '删除',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}

