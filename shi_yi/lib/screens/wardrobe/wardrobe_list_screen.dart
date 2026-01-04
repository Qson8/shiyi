import 'package:flutter/material.dart';
import '../../models/hanfu_item.dart';
import '../../services/wardrobe_repository.dart';
import '../../widgets/neumorphic_card.dart';
import '../../widgets/empty_state.dart';
import '../../utils/constants.dart';
import '../../utils/theme.dart';
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
      appBar: AppBar(
        title: const Text('我的衣橱'),
        actions: [
          IconButton(
            icon: Icon(_isGridView ? Icons.view_list : Icons.view_module),
            onPressed: () {
              setState(() => _isGridView = !_isGridView);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // 筛选栏
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedDynasty,
                    decoration: const InputDecoration(
                      labelText: '朝代',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    items: ['全部', ...AppConstants.dynasties]
                        .map((dynasty) => DropdownMenuItem(
                              value: dynasty,
                              child: Text(dynasty),
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
                    decoration: const InputDecoration(
                      labelText: '类型',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    items: ['全部', ...AppConstants.hanfuTypes]
                        .map((type) => DropdownMenuItem(
                              value: type,
                              child: Text(type),
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
                    action: FloatingActionButton(
                      onPressed: () => _addItem(),
                      child: const Icon(Icons.add),
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
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addItem,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildListItem(BuildContext context, HanfuItem item) {
    return NeumorphicCard(
      onTap: () => _editItem(item),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // 占位图片 - 新拟态风格
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppTheme.backgroundColor,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(4, 4),
                ),
                BoxShadow(
                  color: Colors.white.withOpacity(0.9),
                  blurRadius: 8,
                  offset: const Offset(-4, -4),
                ),
              ],
            ),
            child: item.imagePaths.isNotEmpty
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.asset(
                      item.imagePaths.first,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          const Icon(Icons.checkroom, size: 40, color: AppTheme.textSecondary),
                    ),
                  )
                : const Icon(Icons.checkroom, size: 40, color: AppTheme.textSecondary),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${item.dynasty} · ${item.type}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                ),
                if (item.sizes.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    '尺码: ${item.sizes.keys.join(", ")}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                  ),
                ],
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: AppTheme.textSecondary),
            onPressed: () => _deleteItem(item),
          ),
        ],
      ),
    );
  }

  Widget _buildGridItem(BuildContext context, HanfuItem item) {
    return NeumorphicCard(
      onTap: () => _editItem(item),
      padding: EdgeInsets.zero,
      borderRadius: 16,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: AppTheme.backgroundColor,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
              ),
              child: item.imagePaths.isNotEmpty
                  ? ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(16),
                      ),
                      child: Image.asset(
                        item.imagePaths.first,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            const Center(
                              child: Icon(Icons.checkroom, size: 40, color: AppTheme.textSecondary),
                            ),
                      ),
                    )
                  : const Center(
                      child: Icon(Icons.checkroom, size: 40, color: AppTheme.textSecondary),
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
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '${item.dynasty} · ${item.type}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _addItem() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const WardrobeEditScreen(),
      ),
    );
    if (result == true) {
      _loadData();
    }
  }

  void _editItem(HanfuItem item) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WardrobeEditScreen(item: item),
      ),
    );
    if (result == true) {
      _loadData();
    }
  }

  void _deleteItem(HanfuItem item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text('确认删除'),
        content: Text('确定要删除"${item.name}"吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              '取消',
              style: TextStyle(color: AppTheme.textSecondary),
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

