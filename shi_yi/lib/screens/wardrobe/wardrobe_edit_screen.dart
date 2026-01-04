import 'package:flutter/material.dart';
import '../../models/hanfu_item.dart';
import '../../services/wardrobe_repository.dart';
import '../../utils/constants.dart';
import '../../utils/theme.dart';

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
      // 收集尺码数据
      _sizes.clear();
      for (final entry in _sizeControllers.entries) {
        final value = entry.value.text.trim();
        if (value.isNotEmpty) {
          final doubleValue = double.tryParse(value);
          if (doubleValue != null) {
            _sizes[entry.key] = doubleValue;
          }
        }
      }

      final item = widget.item?.copyWith(
            name: _nameController.text.trim(),
            dynasty: _selectedDynasty,
            type: _selectedType,
            sizes: _sizes,
            notes: _notesController.text.trim(),
          ) ??
          HanfuItem(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            name: _nameController.text.trim(),
            dynasty: _selectedDynasty,
            type: _selectedType,
            sizes: _sizes,
            notes: _notesController.text.trim(),
            createdAt: DateTime.now(),
          );

      await _repository.save(item);
      if (mounted) {
        Navigator.pop(context, true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.item == null ? '添加汉服' : '编辑汉服'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
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
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return '请输入名称';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            // 朝代
            DropdownButtonFormField<String>(
              value: _selectedDynasty,
              decoration: InputDecoration(
                labelText: '朝代',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.white,
              ),
              items: AppConstants.dynasties
                  .map((dynasty) => DropdownMenuItem(
                        value: dynasty,
                        child: Text(dynasty),
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() => _selectedDynasty = value!);
              },
            ),
            const SizedBox(height: 16),
            // 类型
            DropdownButtonFormField<String>(
              value: _selectedType,
              decoration: InputDecoration(
                labelText: '类型',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.white,
              ),
              items: AppConstants.hanfuTypes
                  .map((type) => DropdownMenuItem(
                        value: type,
                        child: Text(type),
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() => _selectedType = value!);
              },
            ),
            const SizedBox(height: 24),
            // 尺码记录
            Text(
              '尺码记录（单位：cm）',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            ...AppConstants.sizeFields.map((field) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: TextFormField(
                  controller: _sizeControllers[field],
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: field,
                    hintText: '请输入$field',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    suffixText: 'cm',
                  ),
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
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 32),
            // 保存按钮
            ElevatedButton(
              onPressed: _save,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
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
    );
  }
}
