import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

/// 图片服务 - 处理图片选择、保存、管理
class ImageService {
  static final ImagePicker _picker = ImagePicker();

  /// 从相册选择图片
  static Future<File?> pickImageFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85, // 压缩质量
        maxWidth: 1920, // 最大宽度
        maxHeight: 1920, // 最大高度
      );
      
      if (image != null) {
        return File(image.path);
      }
      return null;
    } catch (e) {
      print('选择图片失败: $e');
      return null;
    }
  }

  /// 从相机拍摄图片
  static Future<File?> pickImageFromCamera() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
        maxWidth: 1920,
        maxHeight: 1920,
      );
      
      if (image != null) {
        return File(image.path);
      }
      return null;
    } catch (e) {
      print('拍摄图片失败: $e');
      return null;
    }
  }

  /// 保存图片到应用目录并返回相对路径
  static Future<String?> saveImageToAppDirectory(File imageFile, String itemId) async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final imagesDir = Directory('${appDir.path}/wardrobe_images');
      
      if (!await imagesDir.exists()) {
        await imagesDir.create(recursive: true);
      }
      
      final fileName = '${itemId}_${DateTime.now().millisecondsSinceEpoch}${path.extension(imageFile.path)}';
      final savedFile = await imageFile.copy('${imagesDir.path}/$fileName');
      
      // 返回相对路径，用于存储
      return 'wardrobe_images/$fileName';
    } catch (e) {
      print('保存图片失败: $e');
      return null;
    }
  }

  /// 从应用目录加载图片
  static Future<File?> loadImageFromAppDirectory(String relativePath) async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final imageFile = File('${appDir.path}/$relativePath');
      
      if (await imageFile.exists()) {
        return imageFile;
      }
      return null;
    } catch (e) {
      print('加载图片失败: $e');
      return null;
    }
  }

  /// 删除图片
  static Future<bool> deleteImage(String relativePath) async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final imageFile = File('${appDir.path}/$relativePath');
      
      if (await imageFile.exists()) {
        await imageFile.delete();
        return true;
      }
      return false;
    } catch (e) {
      print('删除图片失败: $e');
      return false;
    }
  }

  /// 显示图片选择对话框
  static Future<File?> showImagePickerDialog(BuildContext context) async {
    return showModalBottomSheet<File>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('从相册选择'),
                onTap: () async {
                  Navigator.pop(context);
                  final file = await pickImageFromGallery();
                  if (file != null && context.mounted) {
                    Navigator.pop(context, file);
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('拍照'),
                onTap: () async {
                  Navigator.pop(context);
                  final file = await pickImageFromCamera();
                  if (file != null && context.mounted) {
                    Navigator.pop(context, file);
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.cancel),
                title: const Text('取消'),
                onTap: () => Navigator.pop(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

