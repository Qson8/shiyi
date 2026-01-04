import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';
import '../../widgets/loading_indicator.dart';

/// 改进的3D模型查看器，支持多种渲染方案
class ModelViewerScreenV2 extends StatefulWidget {
  final String modelName;
  final String? modelPath;

  const ModelViewerScreenV2({
    Key? key,
    required this.modelName,
    this.modelPath,
  }) : super(key: key);

  @override
  State<ModelViewerScreenV2> createState() => _ModelViewerScreenV2State();
}

class _ModelViewerScreenV2State extends State<ModelViewerScreenV2> {
  String? _modelPath;
  bool _isLoading = true;
  String? _error;
  ViewerMode _viewerMode = ViewerMode.modelViewer;
  bool _modelViewerAvailable = true;

  @override
  void initState() {
    super.initState();
    _loadModel();
  }

  Future<void> _loadModel() async {
    try {
      String modelPath;
      final Directory tempDir = await getTemporaryDirectory();
      
      // 如果提供了路径，直接使用
      if (widget.modelPath != null) {
        modelPath = widget.modelPath!;
      } else {
        // 从assets加载模型文件
        try {
          final ByteData data = await rootBundle.load('assets/models/hanfu-test.glb');
          final File file = File('${tempDir.path}/hanfu-test.glb');
          await file.writeAsBytes(data.buffer.asUint8List());
          modelPath = file.path;
        } catch (e) {
          throw Exception('无法加载模型文件: $e');
        }
      }

      if (mounted) {
        setState(() {
          _modelPath = modelPath;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = '模型加载失败: $e';
          _isLoading = false;
        });
      }
    }
  }

  /// 尝试使用 ModelViewer，如果失败则降级
  Widget _buildModelViewer() {
    if (_modelPath == null) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    try {
      // 方案1: 使用 model_viewer_plus (推荐，原生渲染)
      return ModelViewer(
        src: _modelPath!,
        alt: widget.modelName,
        ar: true,
        autoRotate: true,
        cameraControls: true,
        backgroundColor: const Color(0xFF1a1a1a),
      );
    } catch (e) {
      // 如果 ModelViewer 不可用，使用占位方案
      if (mounted) {
        setState(() {
          _modelViewerAvailable = false;
          _viewerMode = ViewerMode.placeholder;
        });
      }
      return _buildPlaceholderViewer();
    }
  }

  /// 占位方案：显示模型信息和提示
  Widget _buildPlaceholderViewer() {
    return Container(
      color: const Color(0xFF1a1a1a),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.view_in_ar_rounded,
              size: 80,
              color: Colors.white54,
            ),
            const SizedBox(height: 24),
            Text(
              widget.modelName,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                '3D模型查看功能暂时不可用\n\n'
                '可能的原因：\n'
                '• 当前平台不支持3D渲染\n'
                '• 模型文件加载失败\n'
                '• 需要更新应用版本\n\n'
                '建议：\n'
                '• 检查设备是否支持WebGL\n'
                '• 尝试在其他设备上查看',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () {
                // 尝试重新加载
                setState(() {
                  _isLoading = true;
                  _error = null;
                  _modelViewerAvailable = true;
                  _viewerMode = ViewerMode.modelViewer;
                });
                _loadModel();
              },
              icon: const Icon(Icons.refresh),
              label: const Text('重试'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white24,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('加载中...'),
          backgroundColor: Colors.black87,
        ),
        backgroundColor: Colors.black,
        body: const LoadingIndicator(message: '正在加载3D模型...'),
      );
    }

    if (_error != null && _viewerMode == ViewerMode.modelViewer) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('错误'),
          backgroundColor: Colors.black87,
        ),
        backgroundColor: Colors.black,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  _error!,
                  style: const TextStyle(color: Colors.white),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _isLoading = true;
                    _error = null;
                  });
                  _loadModel();
                },
                child: const Text('重试'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.modelName),
        backgroundColor: Colors.black87,
        actions: [
          if (_viewerMode == ViewerMode.modelViewer && _modelViewerAvailable)
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert),
              onSelected: (value) {
                if (value == 'switch') {
                  setState(() {
                    _viewerMode = ViewerMode.placeholder;
                  });
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'switch',
                  child: Text('切换到占位视图'),
                ),
              ],
            ),
        ],
      ),
      backgroundColor: Colors.black,
      body: _viewerMode == ViewerMode.modelViewer && _modelViewerAvailable
          ? _buildModelViewer()
          : _buildPlaceholderViewer(),
    );
  }
}

enum ViewerMode {
  modelViewer,
  placeholder,
}

