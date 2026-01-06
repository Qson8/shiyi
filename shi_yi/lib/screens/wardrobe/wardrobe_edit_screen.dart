import 'package:flutter/material.dart';
import '../../models/hanfu_item.dart';
import '../../services/wardrobe_repository.dart';
import '../../utils/constants.dart';
import '../../utils/shiyi_color.dart';
import '../../utils/shiyi_font.dart';
import '../../utils/shiyi_icon.dart';

class WardrobeEditScreen extends StatefulWidget {
  final HanfuItem? item;

  const WardrobeEditScreen({Key? key, this.item}) : super(key: key);

  @override
  State<WardrobeEditScreen> createState() => _WardrobeEditScreenState();
}

class _WardrobeEditScreenState extends State<WardrobeEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _notesController = TextEditingController();
  final _repository = WardrobeRepository();
  
  String _selectedDynasty = AppConstants.dynasties.first;
  String _selectedType = AppConstants.hanfuTypes.first;
  Map<String, double> _sizes = {};
  final Map<String, TextEditingController> _sizeControllers = {};

  @override
  void initState() {
    super.initState();
    if (widget.item != null) {
      _nameController.text = widget.item!.name;
      _notesController.text = widget.item!.notes ?? '';
      _selectedDynasty = widget.item!.dynasty;
      _selectedType = widget.item!.type;
      _sizes = Map<String, double>.from(widget.item!.sizes);
      for (final field in AppConstants.sizeFields) {
        _sizeControllers[field] = TextEditingController(
          text: _sizes[field]?.toString() ?? '',
        );
      }
    } else {
      for (final field in AppConstants.sizeFields) {
        _sizeControllers[field] = TextEditingController();
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _notesController.dispose();
    for (final controller in _sizeControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    if (_formKey.currentState!.validate()) {
      // 验证数据
      if (!_validateData()) {
        return;
      }

      // 收集尺码数据
      _sizes.clear();
      for (final entry in _sizeControllers.entries) {
        final value = entry.value.text.trim();
        if (value.isNotEmpty) {
          final doubleValue = double.tryParse(value);
          if (doubleValue != null && doubleValue > 0 && doubleValue <= 500) {
            _sizes[entry.key] = doubleValue;
          }
        }
      }

      final itemId = widget.item?.id ?? DateTime.now().millisecondsSinceEpoch.toString();

      final item = widget.item?.copyWith(
            name: _nameController.text.trim(),
            dynasty: _selectedDynasty,
            type: _selectedType,
            sizes: _sizes,
            notes: _notesController.text.trim(),
            imagePaths: const [], // 不再使用图片
          ) ??
          HanfuItem(
            id: itemId,
            name: _nameController.text.trim(),
            dynasty: _selectedDynasty,
            type: _selectedType,
            sizes: _sizes,
            notes: _notesController.text.trim(),
            imagePaths: const [], // 不再使用图片
            createdAt: DateTime.now(),
          );

      await _repository.save(item);
      if (mounted) {
        Navigator.pop(context, true);
      }
    }
  }

  bool _validateData() {
    // 验证名称长度
    final name = _nameController.text.trim();
    if (name.length > 50) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('名称不能超过50个字符')),
      );
      return false;
    }

    // 验证备注长度
    final notes = _notesController.text.trim();
    if (notes.length > 500) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('备注不能超过500个字符')),
      );
      return false;
    }

    // 验证尺码范围
    for (final entry in _sizeControllers.entries) {
      final value = entry.value.text.trim();
      if (value.isNotEmpty) {
        final doubleValue = double.tryParse(value);
        if (doubleValue == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${entry.key}格式不正确')),
          );
          return false;
        }
        if (doubleValue <= 0 || doubleValue > 500) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${entry.key}必须在0-500之间')),
          );
          return false;
        }
      }
    }

    return true;
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
                      widget.item == null ? '拾衣 · 添加' : '拾衣 · 编辑',
                      style: ShiyiFont.titleStyle.copyWith(color: ShiyiColor.primaryColor),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  if (widget.item != null)
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: _deleteItem,
                    )
                  else
                    const SizedBox(width: 48),
                ],
              ),
            ),

            // 主内容区
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      // 名称
                      TextFormField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          labelText: '名称',
                          hintText: '请输入汉服名称',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                        maxLength: 50,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return '请输入汉服名称';
                          }
                          if (value.length > 50) {
                            return '名称不能超过50个字符';
                          }
                          return null;
                        },
                        buildCounter: (context, {required currentLength, required isFocused, maxLength}) {
                          return Text(
                            '$currentLength/$maxLength',
                            style: ShiyiFont.smallStyle.copyWith(
                              color: ShiyiColor.textSecondary,
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 16),

                      // 朝代
                      TextFormField(
                        controller: TextEditingController(text: _selectedDynasty),
                        readOnly: true,
                        decoration: InputDecoration(
                          labelText: '朝代',
                          suffixIcon: const Icon(Icons.arrow_drop_down),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                        onTap: () async {
                          final result = await showDialog<String>(
                            context: context,
                            builder: (context) => SimpleDialog(
                              title: const Text('选择朝代'),
                              children: AppConstants.dynasties.map((dynasty) {
                                return SimpleDialogOption(
                                  onPressed: () => Navigator.pop(context, dynasty),
                                  child: Text(dynasty),
                                );
                              }).toList(),
                            ),
                          );
                          if (result != null) {
                            setState(() => _selectedDynasty = result);
                          }
                        },
                      ),
                      const SizedBox(height: 16),

                      // 类型
                      TextFormField(
                        controller: TextEditingController(text: _selectedType),
                        readOnly: true,
                        decoration: InputDecoration(
                          labelText: '类型',
                          suffixIcon: const Icon(Icons.arrow_drop_down),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                        onTap: () async {
                          final result = await showDialog<String>(
                            context: context,
                            builder: (context) => SimpleDialog(
                              title: const Text('选择类型'),
                              children: AppConstants.hanfuTypes.map((type) {
                                return SimpleDialogOption(
                                  onPressed: () => Navigator.pop(context, type),
                                  child: Text(type),
                                );
                              }).toList(),
                            ),
                          );
                          if (result != null) {
                            setState(() => _selectedType = result);
                          }
                        },
                      ),
                      const SizedBox(height: 24),

                      // 尺码信息
                      Text(
                        '尺码信息',
                        style: ShiyiFont.bodyStyle.copyWith(fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 16),

                      ...AppConstants.sizeFields.map((field) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: TextFormField(
                            controller: _sizeControllers[field],
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            decoration: InputDecoration(
                              labelText: field,
                              hintText: '请输入$field（0-500）',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide.none,
                              ),
                              filled: true,
                              fillColor: Colors.white,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            ),
                            validator: (value) {
                              if (value != null && value.isNotEmpty) {
                                final numValue = double.tryParse(value);
                                if (numValue == null) {
                                  return '请输入有效数字';
                                }
                                if (numValue <= 0 || numValue > 500) {
                                  return '范围：0-500';
                                }
                              }
                              return null;
                            },
                          ),
                        );
                      }),

                      const SizedBox(height: 16),

                      // 备注
                      TextFormField(
                        controller: _notesController,
                        decoration: InputDecoration(
                          labelText: '备注',
                          hintText: '其他信息（可选）',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                        maxLines: 3,
                        maxLength: 500,
                        buildCounter: (context, {required currentLength, required isFocused, maxLength}) {
                          return Text(
                            '$currentLength/$maxLength',
                            style: ShiyiFont.smallStyle.copyWith(
                              color: ShiyiColor.textSecondary,
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 32),

                      // 保存按钮
                      ElevatedButton(
                        onPressed: _save,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: ShiyiColor.primaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Text(
                          '保存',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _deleteItem() async {
    final confirmed = await showDialog<bool>(
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
          '确定要删除"${widget.item?.name ?? ''}"吗？',
          style: ShiyiFont.smallStyle,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              '取消',
              style: TextStyle(color: ShiyiColor.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              '删除',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true && widget.item != null) {
      await _repository.delete(widget.item!.id);
      if (mounted) {
        Navigator.pop(context, true);
      }
    }
  }
}
