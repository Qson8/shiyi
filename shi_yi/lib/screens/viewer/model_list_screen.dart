import 'package:flutter/material.dart';
import 'model_viewer_screen.dart';
import '../../utils/theme.dart';
import '../../widgets/neumorphic_card.dart';

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
      appBar: AppBar(
        title: const Text('3D模型展示'),
      ),
      body: models.isEmpty
          ? Center(
              child: Text(
                '暂无3D模型',
                style: TextStyle(color: AppTheme.textSecondary),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: models.length,
              itemBuilder: (context, index) {
                final model = models[index];
                return NeumorphicCard(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(20),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ModelViewerScreen(
                          modelName: model['name'] ?? '模型',
                        ),
                      ),
                    );
                  },
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(
                          Icons.view_in_ar_rounded,
                          size: 32,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              model['name'] ?? '模型',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${model['dynasty']} - ${model['type']}',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 16,
                        color: Colors.grey[400],
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
