import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'utils/theme.dart';
import 'services/database_service.dart';
import 'services/knowledge_repository.dart';
import 'services/wardrobe_repository.dart';
import 'screens/home/home_screen.dart';
import 'screens/home/animation_test_screen.dart';
import 'screens/knowledge/knowledge_list_screen.dart';
import 'screens/wardrobe/wardrobe_list_screen.dart';
import 'screens/viewer/model_list_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 初始化数据库
  await DatabaseService.init();
  
  // 从JSON文件加载知识库数据（强制重载以清除旧数据）
  final knowledgeRepo = KnowledgeRepository();
  await knowledgeRepo.loadFromJson(forceReload: true);
  
  runApp(const MyApp());
}

final _router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/knowledge',
      builder: (context, state) => const KnowledgeListScreen(),
    ),
    GoRoute(
      path: '/wardrobe',
      builder: (context, state) => const WardrobeListScreen(),
    ),
    GoRoute(
      path: '/viewer',
      builder: (context, state) => const ModelListScreen(),
    ),
    GoRoute(
      path: '/animation-test',
      builder: (context, state) => const AnimationTestScreen(),
    ),
  ],
);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<KnowledgeRepository>(
          create: (_) => KnowledgeRepository(),
        ),
        Provider<WardrobeRepository>(
          create: (_) => WardrobeRepository(),
        ),
      ],
      child: MaterialApp.router(
        title: '拾衣坊',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        routerConfig: _router,
      ),
    );
  }
}
