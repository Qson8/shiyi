import 'package:hive_flutter/hive_flutter.dart';
import '../models/knowledge_item.dart';
import '../models/hanfu_item.dart';

class DatabaseService {
  static Future<void> init() async {
    await Hive.initFlutter();
    
    // 注册适配器
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(KnowledgeItemAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(HanfuItemAdapter());
    }
    
    // 打开Box
    await Hive.openBox<KnowledgeItem>('knowledge');
    await Hive.openBox<HanfuItem>('wardrobe');
  }

  static Box<KnowledgeItem> get knowledgeBox => 
      Hive.box<KnowledgeItem>('knowledge');
  
  static Box<HanfuItem> get wardrobeBox => 
      Hive.box<HanfuItem>('wardrobe');
}

