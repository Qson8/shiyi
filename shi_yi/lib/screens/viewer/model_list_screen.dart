import 'package:flutter/material.dart';
import 'model_viewer_screen.dart';
import '../../utils/shiyi_color.dart';
import '../../utils/shiyi_font.dart';
import '../../utils/shiyi_decoration.dart';
import '../../utils/shiyi_icon.dart';
import '../../utils/shiyi_transition.dart';
import '../../services/model_repository.dart';
import '../../widgets/loading_indicator.dart';
import '../../widgets/empty_state.dart';

class ModelListScreen extends StatefulWidget {
  const ModelListScreen({Key? key}) : super(key: key);

  @override
  State<ModelListScreen> createState() => _ModelListScreenState();
}

class _ModelListScreenState extends State<ModelListScreen> {
  List<ModelItem> _models = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadModels();
  }

  Future<void> _loadModels() async {
    setState(() => _isLoading = true);
    final models = await ModelRepository.loadFromJson();
    if (mounted) {
      setState(() {
        _models = models;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ShiyiColor.bgColor,
      appBar: AppBar(
        title: Text(
          '拾衣 · 3D观览',
          style: ShiyiFont.titleStyle.copyWith(color: ShiyiColor.primaryColor),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: ShiyiIcon.backIcon,
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: LoadingIndicator())
          : _models.isEmpty
              ? EmptyState(
                  icon: Icons.view_in_ar,
                  title: '暂无3D模型',
                  message: '模型库为空',
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: _models.length,
                  itemBuilder: (context, index) {
                    final model = _models[index];
                    return GestureDetector(
                      onTap: () {
                        // 使用卷轴展开转场（适合3D展示页）
                        Navigator.push(
                          context,
                          ShiyiTransition.scrollUnfoldTransition(
                            ModelViewerScreen(
                              modelName: model.name,
                              modelPath: model.path,
                            ),
                          ),
                        );
                      },
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 12), // 充足留白
                        padding: const EdgeInsets.all(16),
                        decoration: ShiyiDecoration.cardDecoration,
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: ShiyiColor.primaryColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: ShiyiIcon.viewerIcon,
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    model.name,
                                    style: ShiyiFont.bodyStyle.copyWith(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: ShiyiColor.primaryColor.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          model.dynasty,
                                          style: ShiyiFont.smallStyle.copyWith(
                                            fontSize: 11,
                                            color: ShiyiColor.primaryColor,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        model.type,
                                        style: ShiyiFont.smallStyle.copyWith(
                                          fontSize: 12,
                                          color: ShiyiColor.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                  if (model.description.isNotEmpty) ...[
                                    const SizedBox(height: 6),
                                    Text(
                                      model.description,
                                      style: ShiyiFont.smallStyle.copyWith(
                                        fontSize: 12,
                                        color: ShiyiColor.textSecondary,
                                        height: 1.4,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            ShiyiIcon.nextIcon,
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
