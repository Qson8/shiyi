import 'package:flutter/material.dart';
import 'model_viewer_screen.dart';
import '../../utils/shiyi_color.dart';
import '../../utils/shiyi_font.dart';
import '../../utils/shiyi_decoration.dart';
import '../../utils/shiyi_icon.dart';
import '../../utils/shiyi_transition.dart';

class ModelListScreen extends StatelessWidget {
  const ModelListScreen({Key? key}) : super(key: key);

  // 模型列表数据
  final List<Map<String, String>> models = const [
    {
      'id': 'hanfu-test',
      'name': '汉服测试模型',
      'dynasty': '测试',
      'type': '测试形制',
    },
  ];

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
      body: models.isEmpty
          ? Center(
              child: Text(
                '暂无3D模型',
                style: ShiyiFont.bodyStyle.copyWith(color: ShiyiColor.textSecondary),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: models.length,
              itemBuilder: (context, index) {
                final model = models[index];
                return GestureDetector(
                  onTap: () {
                    // 使用卷轴展开转场（适合3D展示页）
                    Navigator.push(
                      context,
                      ShiyiTransition.scrollUnfoldTransition(
                        ModelViewerScreen(
                          modelName: model['name'] ?? '模型',
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
                                model['name'] ?? '模型',
                                style: ShiyiFont.bodyStyle.copyWith(fontWeight: FontWeight.w500),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${model['dynasty']} - ${model['type']}',
                                style: ShiyiFont.smallStyle,
                              ),
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
