import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/scheduler.dart';
import 'package:path_provider/path_provider.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';
import '../../widgets/loading_indicator.dart';
import '../../utils/shiyi_font.dart';
import '../../services/model_repository.dart';
import '../../services/settings_service.dart';

class ModelViewerScreen extends StatefulWidget {
  final String modelName;
  final String? modelPath;

  const ModelViewerScreen({
    Key? key,
    required this.modelName,
    this.modelPath,
  }) : super(key: key);

  @override
  State<ModelViewerScreen> createState() => _ModelViewerScreenState();
}

class _ModelViewerScreenState extends State<ModelViewerScreen> {
  String? _modelPath;
  bool _isLoading = true;
  String? _error;
  late final WebViewController _webViewController;
  bool _isWebViewReady = false;
  ViewerMode _viewerMode = ViewerMode.auto; // 自动选择最佳方案
  bool _modelViewerAvailable = true;
  int _modelViewerKey = 0; // ModelViewer的key，用于刷新和复位
  String _loadingStatus = '准备加载...';
  double _loadingProgress = 0.0;
  String _renderQuality = 'medium'; // 渲染质量设置

  @override
  void initState() {
    super.initState();
    // 读取渲染质量设置
    _renderQuality = SettingsService.getRenderQuality();
    
    // 设置沉浸式状态栏
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        SystemChrome.setEnabledSystemUIMode(
          SystemUiMode.edgeToEdge,
        );
        SystemChrome.setSystemUIOverlayStyle(
          const SystemUiOverlayStyle(
            statusBarColor: Colors.transparent, // 透明状态栏
            statusBarIconBrightness: Brightness.light, // 浅色图标（适配深色背景）
            statusBarBrightness: Brightness.dark, // iOS 状态栏样式
          ),
        );
      }
    });
    
    // 检测平台，在鸿蒙平台上直接使用 WebView
    final bool isOhos = !Platform.isAndroid && !Platform.isIOS && !Platform.isMacOS && !Platform.isWindows && !Platform.isLinux;
    if (isOhos) {
      _viewerMode = ViewerMode.webview;
      _modelViewerAvailable = false;
    }
    
    // 延迟初始化，避免阻塞UI线程
    // 使用SchedulerBinding确保在下一帧执行
    SchedulerBinding.instance.addPostFrameCallback((_) {
      // 再延迟一帧，确保UI完全渲染后再开始加载
      Future.delayed(const Duration(milliseconds: 50), () {
        if (mounted) {
          _initializeWebView();
          // 异步加载模型，不阻塞UI（使用独立实例，不影响首页）
          _loadModel();
        }
      });
    });
  }
  
  @override
  void dispose() {
    // 恢复系统UI样式（可选）
    // SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
    super.dispose();
  }

  void _initializeWebView() {
    // 确保在主线程初始化WebView - 性能优化配置
    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.transparent) // 透明背景，沉浸式效果
      ..enableZoom(false)  // 禁用缩放以提升性能
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            // 页面开始加载
            if (mounted) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) {
                  setState(() => _isLoading = true);
                }
              });
            }
          },
          onPageFinished: (String url) {
            // 确保setState在主线程执行
            if (mounted) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) {
                  setState(() {
                    _isWebViewReady = true;
                    _isLoading = false;
                  });
                }
              });
            }
          },
          onWebResourceError: (WebResourceError error) {
            // 处理WebView错误
            if (mounted) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) {
                  setState(() {
                    _error = 'WebView错误: ${error.description}\n错误代码: ${error.errorCode}';
                    _isLoading = false;
                  });
                }
              });
            }
            // 输出控制台消息用于调试
            debugPrint('WebView Error: ${error.description} (Code: ${error.errorCode})');
          },
        ),
      );
  }

  Future<void> _loadModel() async {
    try {
      String modelPath;
      final Directory tempDir = await getTemporaryDirectory();
      
      // 如果提供了路径，需要检查是否是assets路径
      if (widget.modelPath != null) {
        final providedPath = widget.modelPath!;
        // 如果是assets路径，需要复制到临时目录
        if (providedPath.startsWith('assets/')) {
          try {
            if (mounted) {
              setState(() {
                _loadingStatus = '加载模型文件...';
                _loadingProgress = 0.2;
              });
            }
            
            final ByteData data = await rootBundle.load(providedPath);
            final fileName = providedPath.split('/').last;
            final File file = File('${tempDir.path}/$fileName');
            
            // 分批写入，避免一次性写入大文件阻塞
            final bytes = data.buffer.asUint8List();
            final chunkSize = 1024 * 1024; // 1MB chunks
            final totalChunks = (bytes.length / chunkSize).ceil();
            final fileSink = file.openWrite();
            
            try {
              int currentChunk = 0;
              for (int i = 0; i < bytes.length; i += chunkSize) {
                final end = (i + chunkSize < bytes.length) ? i + chunkSize : bytes.length;
                fileSink.add(bytes.sublist(i, end));
                currentChunk++;
                
                // 更新进度
                if (mounted && totalChunks > 0) {
                  setState(() {
                    _loadingProgress = 0.2 + (currentChunk / totalChunks) * 0.3;
                    _loadingStatus = '复制模型文件... ${((currentChunk / totalChunks) * 100).toStringAsFixed(0)}%';
                  });
                }
                
                await Future.delayed(Duration.zero);
              }
            } finally {
              await fileSink.close();
            }
            
            modelPath = file.path;
          } catch (e) {
            throw Exception('无法加载模型文件: $e');
          }
        } else {
          // 已经是文件路径，直接使用
          modelPath = providedPath;
        }
      } else {
        // 如果没有提供路径，从ModelRepository获取默认模型
        try {
          final models = await ModelRepository.getAll();
          if (models.isEmpty) {
            throw Exception('没有可用的模型');
          }
          
          // 使用第一个模型作为默认模型
          final defaultModel = models.first;
          final providedPath = defaultModel.path;
          
          // 如果是assets路径，需要复制到临时目录
          if (providedPath.startsWith('assets/')) {
            try {
              if (mounted) {
                setState(() {
                  _loadingStatus = '加载默认模型...';
                  _loadingProgress = 0.2;
                });
              }
              
              final ByteData data = await rootBundle.load(providedPath);
              final fileName = providedPath.split('/').last;
              final File file = File('${tempDir.path}/$fileName');
              
              // 分批写入，避免一次性写入大文件阻塞
              final bytes = data.buffer.asUint8List();
              final chunkSize = 1024 * 1024; // 1MB chunks
              final totalChunks = (bytes.length / chunkSize).ceil();
              final fileSink = file.openWrite();
              
              try {
                int currentChunk = 0;
                for (int i = 0; i < bytes.length; i += chunkSize) {
                  final end = (i + chunkSize < bytes.length) ? i + chunkSize : bytes.length;
                  fileSink.add(bytes.sublist(i, end));
                  currentChunk++;
                  
                  // 更新进度
                  if (mounted && totalChunks > 0) {
                    setState(() {
                      _loadingProgress = 0.2 + (currentChunk / totalChunks) * 0.3;
                      _loadingStatus = '复制模型文件... ${((currentChunk / totalChunks) * 100).toStringAsFixed(0)}%';
                    });
                  }
                  
                  await Future.delayed(Duration.zero);
                }
              } finally {
                await fileSink.close();
              }
              
              modelPath = file.path;
            } catch (e) {
              throw Exception('无法加载模型文件: $e');
            }
          } else {
            // 已经是文件路径，直接使用
            modelPath = providedPath;
          }
        } catch (e) {
          throw Exception('无法加载默认模型: $e');
        }
      }

      // 加载Three.js库文件到临时目录 - 异步执行
      if (mounted) {
        setState(() {
          _loadingStatus = '加载3D库文件...';
          _loadingProgress = 0.5;
        });
      }
      
      await Future.microtask(() async {
        final libsDir = Directory('${tempDir.path}/3d_libs');
        if (!await libsDir.exists()) {
          await libsDir.create(recursive: true);
        }

        // 复制Three.js库文件 - 分批加载避免阻塞
        try {
          // 加载three.min.js
          if (mounted) {
            setState(() {
              _loadingStatus = '加载Three.js核心库...';
              _loadingProgress = 0.55;
            });
          }
          await _loadLibraryFile(
            'assets/3d_libs/three.min.js',
            '${libsDir.path}/three.min.js',
          );
          
          // 加载GLTFLoader
          if (mounted) {
            setState(() {
              _loadingStatus = '加载GLTF加载器...';
              _loadingProgress = 0.7;
            });
          }
          await _loadLibraryFile(
            'assets/3d_libs/GLTFLoader.js',
            '${libsDir.path}/GLTFLoader.js',
          );
          
          // 加载OrbitControls
          if (mounted) {
            setState(() {
              _loadingStatus = '加载控制器...';
              _loadingProgress = 0.85;
            });
          }
          await _loadLibraryFile(
            'assets/3d_libs/OrbitControls.js',
            '${libsDir.path}/OrbitControls.js',
          );
          
          // 所有文件已加载
          if (mounted) {
            setState(() {
              _loadingStatus = '准备渲染...';
              _loadingProgress = 0.9;
            });
          }
        } catch (e) {
          throw Exception('无法加载Three.js库文件: $e');
        }
      });

      // 确保setState在主线程执行
      if (mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            setState(() {
              _modelPath = modelPath;
            });
          }
        });
      }

      // 根据模式选择加载方案
      // 在鸿蒙平台上，ModelViewer 可能不可用，直接使用 WebView
      final bool isOhos = !Platform.isAndroid && !Platform.isIOS && !Platform.isMacOS && !Platform.isWindows && !Platform.isLinux;
      
      if (_viewerMode == ViewerMode.webview || isOhos) {
        // 明确使用 WebView 方案，或在鸿蒙平台上强制使用 WebView
        if (isOhos && _viewerMode == ViewerMode.auto) {
          // 在鸿蒙平台上自动切换到 WebView
          if (mounted) {
            setState(() {
              _viewerMode = ViewerMode.webview;
              _modelViewerAvailable = false;
            });
          }
        }
        await _load3DViewer();
      } else if (_viewerMode == ViewerMode.auto) {
        // 自动模式：优先尝试 ModelViewer，如果不可用则使用 WebView
        if (_modelViewerAvailable) {
          // ModelViewer 会自动加载，延迟设置加载完成，给模型一些时间加载
          if (mounted) {
            setState(() {
              _loadingStatus = '渲染模型...';
              _loadingProgress = 0.95;
            });
          }
          Future.delayed(const Duration(milliseconds: 500), () {
            if (mounted) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) {
                  setState(() {
                    _isLoading = false;
                    _loadingProgress = 1.0;
                    _loadingStatus = '加载完成';
                  });
                }
              });
            }
          });
        } else {
          // ModelViewer 不可用，使用 WebView
          await _load3DViewer();
        }
      } else if (_viewerMode == ViewerMode.modelviewer) {
        // 明确使用 ModelViewer，延迟设置加载完成
        if (mounted) {
          setState(() {
            _loadingStatus = '渲染模型...';
            _loadingProgress = 0.95;
          });
        }
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                setState(() {
                  _isLoading = false;
                  _loadingProgress = 1.0;
                  _loadingStatus = '加载完成';
                });
              }
            });
          }
        });
      }
    } catch (e) {
      // 确保错误处理在主线程执行
      if (mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            setState(() {
              _error = '模型加载失败: $e';
              _isLoading = false;
            });
          }
        });
      }
    }
  }

  /// 异步加载库文件，避免阻塞主线程
  Future<void> _loadLibraryFile(String assetPath, String filePath) async {
    final data = await rootBundle.load(assetPath);
    final file = File(filePath);
    final bytes = data.buffer.asUint8List();
    
    // 小文件直接写入，大文件分批写入
    if (bytes.length < 1024 * 1024) {
      await file.writeAsBytes(bytes);
    } else {
      final chunkSize = 512 * 1024; // 512KB chunks
      final fileSink = file.openWrite();
      try {
        for (int i = 0; i < bytes.length; i += chunkSize) {
          final end = (i + chunkSize < bytes.length) ? i + chunkSize : bytes.length;
          fileSink.add(bytes.sublist(i, end));
          await Future.delayed(Duration.zero); // 让出控制权
        }
      } finally {
        await fileSink.close();
      }
    }
  }

  // 刷新3D模型
  Future<void> _refreshModel() async {
    if (_modelPath == null) return;
    
    setState(() {
      _modelViewerKey++; // 改变key强制重建ModelViewer
      _isLoading = true;
      _error = null; // 清除之前的错误
      _isWebViewReady = false; // 重置WebView状态
    });
    
    // 根据当前模式重新加载
    if (_viewerMode == ViewerMode.webview) {
      // WebView模式：重新加载（_load3DViewer会等待onPageFinished回调来设置_isLoading = false）
      await _load3DViewer();
    } else if (_viewerMode == ViewerMode.modelviewer || 
               (_viewerMode == ViewerMode.auto && _modelViewerAvailable)) {
      // ModelViewer模式：延迟设置加载完成，给模型一些时间加载
      Future.delayed(const Duration(milliseconds: 800), () {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      });
    } else {
      // 自动模式：重新加载模型
      await _loadModel();
    }
  }


  Future<void> _load3DViewer() async {
    try {
      final File modelFile = File(_modelPath!);
      final String modelFileName = modelFile.path.split('/').last;
      
      // 获取3d_libs目录路径
      final Directory tempDir = await getTemporaryDirectory();
      final libsDir = Directory('${tempDir.path}/3d_libs');
      final modelDir = modelFile.parent;
      
      // 生成HTML内容，使用本地Three.js库
      final String htmlContent = _generateHTML(
        modelFileName,
        'file://${libsDir.path}/',
        'file://${modelDir.path}/',
      );

      // 确保WebView操作在主线程执行（iOS要求）
      // 使用SchedulerBinding确保在主线程
      if (Platform.isIOS) {
        // iOS需要确保在主线程执行，等待当前帧完成
        await SchedulerBinding.instance.endOfFrame;
        // 再延迟一小段时间，确保UI线程空闲
        await Future.delayed(const Duration(milliseconds: 16));
      }
      
      // 加载HTML到WebView，使用file://协议作为baseUrl
      // 使用Future.microtask确保在主线程执行
      await Future.microtask(() async {
        await _webViewController.loadHtmlString(
          htmlContent,
          baseUrl: 'file://${tempDir.path}/',
        );
      });

      // 注意：不要在这里立即设置_isLoading = false
      // 应该等待onPageFinished回调来设置，确保WebView真正加载完成
      // onPageFinished回调会设置_isWebViewReady = true 和 _isLoading = false
    } catch (e) {
      // 确保错误处理在主线程执行
      if (mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            setState(() {
              _error = '3D查看器加载失败: $e';
              _isLoading = false;
            });
          }
        });
      }
    }
  }

  String _generateHTML(String modelFileName, String libsBaseUrl, String modelBaseUrl) {
    final threeJsUrl = '${libsBaseUrl}three.min.js';
    final gltfLoaderUrl = '${libsBaseUrl}GLTFLoader.js';
    final orbitControlsUrl = '${libsBaseUrl}OrbitControls.js';
    final modelUrl = '${modelBaseUrl}$modelFileName';
    
    // 根据渲染质量设置调整参数
    final bool useAntialias = _renderQuality == 'high';
    final String precision = _renderQuality == 'low' ? 'lowp' : (_renderQuality == 'high' ? 'highp' : 'mediump');
    final double maxPixelRatio = _renderQuality == 'low' ? 1.0 : (_renderQuality == 'high' ? 2.0 : 1.5);
    final int targetFPS = _renderQuality == 'low' ? 24 : (_renderQuality == 'high' ? 60 : 30);
    final bool enableShadows = _renderQuality == 'high';
    
    return '''
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0, user-scalable=no">
    <title>3D Model Viewer</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        body {
            width: 100%;
            height: 100vh;
            overflow: hidden;
            background: #000;
        }
        #container {
            width: 100%;
            height: 100%;
        }
        #info {
            position: absolute;
            top: 10px;
            left: 10px;
            color: white;
            background: rgba(0,0,0,0.6);
            padding: 8px 12px;
            border-radius: 8px;
            font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif;
            font-size: 12px;
            z-index: 100;
            backdrop-filter: blur(10px);
        }
    </style>
    <!-- 加载Three.js核心库 -->
    <script src="$threeJsUrl"></script>
</head>
<body>
    <div id="info">${widget.modelName} - 加载中...</div>
    <div id="container"></div>
    
    <!-- 使用ES6模块加载GLTFLoader和OrbitControls -->
    <script type="module">
        // 添加错误处理
        window.addEventListener('error', function(e) {
            console.error('Global error:', e.error);
            document.getElementById('info').textContent = '错误: ' + (e.message || '未知错误');
        });
        
        // 动态导入ES6模块
        let GLTFLoader, OrbitControls;
        
        Promise.all([
            import('$gltfLoaderUrl'),
            import('$orbitControlsUrl')
        ]).then(modules => {
            GLTFLoader = modules[0].GLTFLoader;
            OrbitControls = modules[1].OrbitControls;
            initViewer();
        }).catch(error => {
            console.error('Failed to load modules:', error);
            document.getElementById('info').textContent = '模块加载失败: ' + (error.message || '未知错误');
            document.getElementById('info').style.background = 'rgba(255,0,0,0.8)';
        });
        
        function initViewer() {
        
            let scene, camera, renderer, controls, model;
            let mixer = null; // 动画混合器
            let clock = new THREE.Clock(); // 用于动画时间
            let container = document.getElementById('container');
            
            // 初始化场景
            scene = new THREE.Scene();
            scene.background = new THREE.Color(0x1a1a1a);
            
            // 相机
            camera = new THREE.PerspectiveCamera(
                45,
                window.innerWidth / window.innerHeight,
                0.1,
                1000
            );
            camera.position.set(0, 0, 5);
            
            // 渲染器 - 根据质量设置配置
            renderer = new THREE.WebGLRenderer({ 
                antialias: ${useAntialias},  // 根据质量设置抗锯齿
                alpha: false,
                powerPreference: 'high-performance',  // 优先使用高性能GPU
                precision: '$precision'  // 根据质量设置精度
            });
            renderer.setSize(window.innerWidth, window.innerHeight);
            renderer.shadowMap.enabled = ${enableShadows};  // 根据质量设置阴影
            if (renderer.shadowMap.enabled) {
                renderer.shadowMap.type = THREE.PCFSoftShadowMap;  // 高质量阴影
            }
            renderer.setPixelRatio(Math.min(window.devicePixelRatio, ${maxPixelRatio}));  // 根据质量设置像素比
            container.appendChild(renderer.domElement);
            
            // 控制器 - 性能优化配置
            controls = new OrbitControls(camera, renderer.domElement);
            controls.enableDamping = true;
            controls.dampingFactor = 0.1;  // 增加阻尼因子以减少计算
            controls.minDistance = 1;
            controls.maxDistance = 10;
            controls.enableZoom = true;
            controls.enableRotate = true;
            controls.autoRotate = false;  // 保持关闭自动旋转以节省性能
            controls.enablePan = true;
            
            // 灯光 - 性能优化：减少灯光数量和复杂度
            const ambientLight = new THREE.AmbientLight(0xffffff, 0.8);  // 增加环境光强度
            scene.add(ambientLight);
            
            // 根据质量设置方向光和阴影
            const directionalLight = new THREE.DirectionalLight(0xffffff, 0.6);
            directionalLight.position.set(5, 5, 5);
            directionalLight.castShadow = ${enableShadows};  // 根据质量设置阴影
            if (${enableShadows}) {
                directionalLight.shadow.mapSize.width = 2048;  // 高质量阴影贴图
                directionalLight.shadow.mapSize.height = 2048;
                directionalLight.shadow.camera.near = 0.5;
                directionalLight.shadow.camera.far = 50;
            }
            scene.add(directionalLight);
            
            // 加载模型
            const loader = new GLTFLoader();
            const modelPath = '$modelUrl';
            
            console.log('Loading model from:', modelPath);
            document.getElementById('info').textContent = '正在加载模型...';
            
            loader.load(
                modelPath,
                function(gltf) {
                    console.log('Model loaded successfully');
                    model = gltf.scene;
                    scene.add(model);
                    
                    // 处理模型动画
                    if (gltf.animations && gltf.animations.length > 0) {
                        console.log('Found ' + gltf.animations.length + ' animation(s)');
                        // 创建动画混合器
                        mixer = new THREE.AnimationMixer(model);
                        
                        // 播放所有动画
                        gltf.animations.forEach((clip) => {
                            console.log('Playing animation: ' + clip.name);
                            const action = mixer.clipAction(clip);
                            action.play();
                        });
                    } else {
                        console.log('No animations found in model');
                    }
                    
                    // 计算模型边界并调整相机
                    const box = new THREE.Box3().setFromObject(model);
                    const center = box.getCenter(new THREE.Vector3());
                    const size = box.getSize(new THREE.Vector3());
                    const maxDim = Math.max(size.x, size.y, size.z);
                    const fov = camera.fov * (Math.PI / 180);
                    const cameraZ = Math.abs(maxDim / 2 / Math.tan(fov / 2));
                    
                    camera.position.set(center.x, center.y, center.z + cameraZ * 1.5);
                    controls.target.copy(center);
                    controls.update();
                    
                    // 隐藏加载提示
                    document.getElementById('info').style.display = 'none';
                },
                function(xhr) {
                    if (xhr.lengthComputable) {
                        const percent = (xhr.loaded / xhr.total * 100).toFixed(0);
                        document.getElementById('info').textContent = '加载中: ' + percent + '%';
                    }
                },
                function(error) {
                    console.error('Error loading model:', error);
                    document.getElementById('info').textContent = '模型加载失败: ' + (error.message || '未知错误');
                    document.getElementById('info').style.background = 'rgba(255,0,0,0.8)';
                }
            );
            
            // 重置相机函数（供外部调用）
            window.resetCamera = function() {
                if (model) {
                    const box = new THREE.Box3().setFromObject(model);
                    const center = box.getCenter(new THREE.Vector3());
                    const size = box.getSize(new THREE.Vector3());
                    const maxDim = Math.max(size.x, size.y, size.z);
                    const fov = camera.fov * (Math.PI / 180);
                    const cameraZ = Math.abs(maxDim / 2 / Math.tan(fov / 2));
                    
                    camera.position.set(center.x, center.y, center.z + cameraZ * 1.5);
                    controls.target.copy(center);
                    controls.update();
                    renderer.render(scene, camera);
                }
            };
            
            // 动画循环 - 根据质量设置帧率控制
            let lastFrameTime = performance.now();
            let frameCount = 0;
            let fps = 60;
            const targetFPS = ${targetFPS};  // 根据质量设置目标帧率
            const frameInterval = 1000 / targetFPS;
            let lastRenderTime = 0;
            let needsRender = true;  // 只在需要时渲染
            
            function animate(currentTime) {
                requestAnimationFrame(animate);
                
                const elapsed = currentTime - lastRenderTime;
                
                // 帧率控制：限制渲染频率
                if (elapsed < frameInterval) {
                    return;
                }
                
                lastRenderTime = currentTime - (elapsed % frameInterval);
                
                // 更新动画混合器（如果存在）
                if (mixer) {
                    const delta = clock.getDelta();
                    if (delta > 0) {  // 只在有有效delta时更新
                        mixer.update(delta);
                        needsRender = true;
                    }
                }
                
                // 只在控制器有变化或需要渲染时更新
                if (controls.enableDamping) {
                    controls.update();
                    needsRender = true;
                }
                
                // 只在需要时渲染
                if (needsRender) {
                    renderer.render(scene, camera);
                    needsRender = false;
                }
                
                // 性能监控（可选，用于调试）
                frameCount++;
                if (currentTime - lastFrameTime >= 1000) {
                    fps = frameCount;
                    frameCount = 0;
                    lastFrameTime = currentTime;
                    // console.log('FPS:', fps);  // 取消注释以查看FPS
                }
            }
            animate(performance.now());
            
            // 响应式调整
            window.addEventListener('resize', function() {
                camera.aspect = window.innerWidth / window.innerHeight;
                camera.updateProjectionMatrix();
                renderer.setSize(window.innerWidth, window.innerHeight);
            });
        }
    </script>
</body>
</html>
''';
  }

  /// 构建 ModelViewer (方案1: 推荐)
  /// 使用独立实例，不影响首页模型
  Widget _buildModelViewer() {
    if (_modelPath == null) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      );
    }

    try {
      // 使用独立的ModelViewer实例，确保不影响首页
      return RepaintBoundary(
        child: ModelViewer(
          key: ValueKey('detail_${_modelPath}_$_modelViewerKey'), // 使用key控制刷新和复位
          src: _modelPath!,
          alt: widget.modelName,
          ar: false,  // 关闭AR以提升性能
          autoRotate: false,  // 关闭自动旋转以节省性能
          cameraControls: true,
          backgroundColor: Colors.transparent, // 透明背景，沉浸式效果
          disableZoom: false,
          // interactionPrompt 参数已移除，使用默认配置
        ),
      );
    } catch (e) {
      // 如果 ModelViewer 创建失败，切换到 WebView 方案
      if (mounted) {
        setState(() {
          _modelViewerAvailable = false;
          _viewerMode = ViewerMode.webview;
        });
        // 延迟加载 WebView
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted && _modelPath != null) {
            _load3DViewer();
          }
        });
      }
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      );
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
                '• WebView功能受限\n\n'
                '建议：\n'
                '• 检查设备是否支持WebGL\n'
                '• 尝试在其他设备上查看\n'
                '• 更新应用版本',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      _isLoading = true;
                      _error = null;
                      _modelViewerAvailable = true;
                      _viewerMode = ViewerMode.auto;
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
                const SizedBox(width: 16),
                ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      _viewerMode = ViewerMode.webview;
                    });
                    if (_modelPath != null) {
                      _load3DViewer();
                    }
                  },
                  icon: const Icon(Icons.web),
                  label: const Text('使用WebView'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white24,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final padding = MediaQuery.of(context).padding;
    
    if (_isLoading) {
      return Scaffold(
        backgroundColor: Colors.black,
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          title: const Text(
            '加载中...',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          systemOverlayStyle: const SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: Brightness.light,
            statusBarBrightness: Brightness.dark,
          ),
          leading: null, // 移除leading，改用Stack中的按钮，保持位置一致
          automaticallyImplyLeading: false,
        ),
        body: Stack(
          children: [
            // 加载指示器（带进度）
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    _loadingStatus,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // 进度条
                  Container(
                    width: MediaQuery.of(context).size.width * 0.6,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(2),
                    ),
                    child: FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: _loadingProgress,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${(_loadingProgress * 100).toStringAsFixed(0)}%',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            // 顶部按钮层（确保在最上层，与正常状态位置一致）
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // 返回按钮（与正常状态完全一致）
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.85),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.5),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                            spreadRadius: 0,
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () => Navigator.pop(context),
                          borderRadius: BorderRadius.circular(24),
                          child: const Icon(
                            Icons.arrow_back_ios_new,
                            color: Colors.white,
                            size: 22,
                          ),
                        ),
                      ),
                    ),
                    // 右侧留空，保持布局一致
                    const SizedBox(width: 48),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }

    if (_error != null && _viewerMode != ViewerMode.placeholder) {
      return Scaffold(
        backgroundColor: Colors.black,
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          title: const Text(
            '错误',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          systemOverlayStyle: const SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: Brightness.light,
            statusBarBrightness: Brightness.dark,
          ),
          leading: null, // 移除leading，改用Stack中的按钮，保持位置一致
          automaticallyImplyLeading: false,
        ),
        body: Stack(
          children: [
            // 错误内容
            Center(
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
                      if (mounted) {
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          if (mounted) {
                            setState(() {
                              _isLoading = true;
                              _error = null;
                              _viewerMode = ViewerMode.auto;
                              _modelViewerAvailable = true;
                            });
                            _loadModel();
                          }
                        });
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white.withOpacity(0.2),
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('重试'),
                  ),
                ],
              ),
            ),
            // 顶部按钮层（确保在最上层，与正常状态位置一致）
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // 返回按钮（与正常状态完全一致）
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.85),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.5),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                            spreadRadius: 0,
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () => Navigator.pop(context),
                          borderRadius: BorderRadius.circular(24),
                          child: const Icon(
                            Icons.arrow_back_ios_new,
                            color: Colors.white,
                            size: 22,
                          ),
                        ),
                      ),
                    ),
                    // 右侧留空，保持布局一致
                    const SizedBox(width: 48),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }

    // 根据模式选择渲染方案
    // 再次检测平台，确保在鸿蒙平台上使用 WebView
    final bool isOhos = !Platform.isAndroid && !Platform.isIOS && !Platform.isMacOS && !Platform.isWindows && !Platform.isLinux;
    
    Widget bodyWidget;
    if (_viewerMode == ViewerMode.webview || isOhos) {
      // WebView 方案（或在鸿蒙平台上强制使用）
      bodyWidget = _isWebViewReady 
          ? Container(
              color: Colors.black, // 黑色背景，沉浸式效果
              child: WebViewWidget(controller: _webViewController),
            )
          : const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            );
    } else if (_viewerMode == ViewerMode.placeholder) {
      // 占位方案
      bodyWidget = _buildPlaceholderViewer();
    } else if (_viewerMode == ViewerMode.modelviewer || 
               (_viewerMode == ViewerMode.auto && _modelViewerAvailable)) {
      // ModelViewer 方案（推荐，但不在鸿蒙平台上使用）
      bodyWidget = Container(
        color: Colors.black, // 黑色背景，沉浸式效果
        child: _buildModelViewer(),
      );
    } else {
      // 自动模式但 ModelViewer 不可用，使用 WebView
      bodyWidget = _isWebViewReady 
          ? Container(
              color: Colors.black, // 黑色背景，沉浸式效果
              child: WebViewWidget(controller: _webViewController),
            )
          : const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            );
    }
    
    return Scaffold(
      backgroundColor: Colors.black, // 深色背景，沉浸式体验
      extendBodyBehindAppBar: true, // 让内容延伸到AppBar下方
      appBar: AppBar(
        title: Text(
          widget.modelName,
          style: ShiyiFont.titleStyle.copyWith(
            fontSize: 18,
            color: Colors.white, // 白色文字，适配深色背景
            fontWeight: FontWeight.w500,
          ),
        ),
        backgroundColor: Colors.transparent, // 完全透明
        elevation: 0,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light, // 浅色图标
          statusBarBrightness: Brightness.dark,
        ),
        leading: null, // 移除leading，改用Stack中的按钮
        automaticallyImplyLeading: false,
        actions: const [], // 移除actions，改用Stack中的按钮
      ),
      body: Stack(
        children: [
          // 3D模型内容
          bodyWidget,
          // 顶部按钮层（确保在最上层）
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // 返回按钮（增强可见性）
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.85),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.3),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.5),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                          spreadRadius: 0,
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => Navigator.pop(context),
                        borderRadius: BorderRadius.circular(24),
                        child: const Icon(
                          Icons.arrow_back_ios_new,
                          color: Colors.white,
                          size: 22,
                        ),
                      ),
                    ),
                  ),
                  // 右侧按钮组
                  Row(
                    children: [
                      // 加载指示器（如果需要）
                      if (_viewerMode == ViewerMode.webview && !_isWebViewReady)
                        Container(
                          margin: const EdgeInsets.only(right: 8),
                          padding: const EdgeInsets.all(12.0),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.6),
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          ),
                        ),
                      // 刷新按钮（只要模型路径存在就显示）
                      if (_modelPath != null)
                        Container(
                          margin: const EdgeInsets.only(right: 8),
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.75),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.3),
                              width: 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.5),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                                spreadRadius: 0,
                              ),
                            ],
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: _refreshModel,
                              borderRadius: BorderRadius.circular(24),
                              child: const Icon(
                                Icons.refresh,
                                color: Colors.white,
                                size: 22,
                              ),
                            ),
                          ),
                        ),
                      // 更多选项按钮
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.6), // 提高背景透明度，更明显
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: PopupMenuButton<String>(
                          icon: const Icon(
                            Icons.more_vert,
                            color: Colors.white,
                            size: 20,
                          ),
                          tooltip: '更多选项',
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          color: Colors.black87,
                          onSelected: (value) {
                            if (value == 'modelviewer' && _modelPath != null) {
                              setState(() {
                                _viewerMode = ViewerMode.modelviewer;
                                _modelViewerAvailable = true;
                              });
                            } else if (value == 'webview' && _modelPath != null) {
                              setState(() {
                                _viewerMode = ViewerMode.webview;
                              });
                              _load3DViewer();
                            } else if (value == 'placeholder') {
                              setState(() {
                                _viewerMode = ViewerMode.placeholder;
                              });
                            }
                          },
                          itemBuilder: (context) => [
                            if (_modelPath != null) ...[
                              const PopupMenuItem(
                                value: 'modelviewer',
                                child: Text('使用 ModelViewer', style: TextStyle(color: Colors.white)),
                              ),
                              const PopupMenuItem(
                                value: 'webview',
                                child: Text('使用 WebView', style: TextStyle(color: Colors.white)),
                              ),
                            ],
                            const PopupMenuItem(
                              value: 'placeholder',
                              child: Text('占位视图', style: TextStyle(color: Colors.white)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

enum ViewerMode {
  auto,          // 自动选择
  modelviewer,   // ModelViewer 方案
  webview,       // WebView 方案
  placeholder,  // 占位方案
}

