import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/scheduler.dart';
import 'package:path_provider/path_provider.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';
import '../../widgets/loading_indicator.dart';

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

  @override
  void initState() {
    super.initState();
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
          // 异步加载模型，不阻塞UI
          _loadModel();
        }
      });
    });
  }

  void _initializeWebView() {
    // 确保在主线程初始化WebView
    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.black)
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
      
      // 如果提供了路径，直接使用
      if (widget.modelPath != null) {
        modelPath = widget.modelPath!;
      } else {
        // 否则从assets加载 - 使用异步避免阻塞
        try {
          // 将文件加载移到后台执行，避免阻塞主线程
          final ByteData data = await rootBundle.load('assets/models/hanfu-test.glb');
          
          // 使用Future.microtask将文件写入操作移到下一个事件循环
          await Future.microtask(() async {
            final File file = File('${tempDir.path}/hanfu-test.glb');
            // 分批写入，避免一次性写入大文件阻塞
            final bytes = data.buffer.asUint8List();
            final chunkSize = 1024 * 1024; // 1MB chunks
            final fileSink = file.openWrite();
            
            try {
              for (int i = 0; i < bytes.length; i += chunkSize) {
                final end = (i + chunkSize < bytes.length) ? i + chunkSize : bytes.length;
                fileSink.add(bytes.sublist(i, end));
                // 让出控制权，避免阻塞
                await Future.delayed(Duration.zero);
              }
            } finally {
              await fileSink.close();
            }
          });
          
          modelPath = '${tempDir.path}/hanfu-test.glb';
        } catch (e) {
          throw Exception('无法加载模型文件: $e');
        }
      }

      // 加载Three.js库文件到临时目录 - 异步执行
      await Future.microtask(() async {
        final libsDir = Directory('${tempDir.path}/3d_libs');
        if (!await libsDir.exists()) {
          await libsDir.create(recursive: true);
        }

        // 复制Three.js库文件 - 分批加载避免阻塞
        try {
          // 使用Future.wait并行加载，但每个文件写入后让出控制权
          final futures = <Future>[];
          
          futures.add(_loadLibraryFile(
            'assets/3d_libs/three.min.js',
            '${libsDir.path}/three.min.js',
          ));
          
          // 加载ES6模块版本的库文件
          await _loadLibraryFile(
            'assets/3d_libs/GLTFLoader.js',
            '${libsDir.path}/GLTFLoader.js',
          );
          
          await _loadLibraryFile(
            'assets/3d_libs/OrbitControls.js',
            '${libsDir.path}/OrbitControls.js',
          );
          
          // 所有文件已加载
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
          // ModelViewer 会自动加载，只需要设置加载完成
          if (mounted) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                setState(() {
                  _isLoading = false;
                });
              }
            });
          }
        } else {
          // ModelViewer 不可用，使用 WebView
          await _load3DViewer();
        }
      } else if (_viewerMode == ViewerMode.modelviewer) {
        // 明确使用 ModelViewer
        if (mounted) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              setState(() {
                _isLoading = false;
              });
            }
          });
        }
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

      // 确保setState在主线程执行
      if (mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            setState(() {
              _isLoading = false;
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
            
            // 渲染器
            renderer = new THREE.WebGLRenderer({ 
                antialias: true,
                alpha: false
            });
            renderer.setSize(window.innerWidth, window.innerHeight);
            renderer.shadowMap.enabled = true;
            renderer.shadowMap.type = THREE.PCFSoftShadowMap;
            container.appendChild(renderer.domElement);
            
            // 控制器
            controls = new OrbitControls(camera, renderer.domElement);
            controls.enableDamping = true;
            controls.dampingFactor = 0.05;
            controls.minDistance = 1;
            controls.maxDistance = 10;
            controls.enableZoom = true;
            controls.enableRotate = true;
            controls.autoRotate = false;
            
            // 灯光
            const ambientLight = new THREE.AmbientLight(0xffffff, 0.7);
            scene.add(ambientLight);
            
            const directionalLight1 = new THREE.DirectionalLight(0xffffff, 0.9);
            directionalLight1.position.set(5, 5, 5);
            directionalLight1.castShadow = true;
            scene.add(directionalLight1);
            
            const directionalLight2 = new THREE.DirectionalLight(0xffffff, 0.5);
            directionalLight2.position.set(-5, -5, -5);
            scene.add(directionalLight2);
            
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
            
            // 动画循环
            function animate() {
                requestAnimationFrame(animate);
                
                // 更新动画混合器（如果存在）
                if (mixer) {
                    const delta = clock.getDelta();
                    mixer.update(delta);
                }
                
                controls.update();
                renderer.render(scene, camera);
            }
            animate();
            
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
  Widget _buildModelViewer() {
    if (_modelPath == null) {
      return const Center(child: CircularProgressIndicator());
    }

    try {
      return ModelViewer(
        src: _modelPath!,
        alt: widget.modelName,
        ar: true,
        autoRotate: true,
        cameraControls: true,
        backgroundColor: const Color(0xFF1a1a1a),
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
        child: CircularProgressIndicator(),
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

    if (_error != null && _viewerMode != ViewerMode.placeholder) {
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
                child: const Text('重试'),
              ),
            ],
          ),
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
          ? WebViewWidget(controller: _webViewController)
          : const Center(child: CircularProgressIndicator());
    } else if (_viewerMode == ViewerMode.placeholder) {
      // 占位方案
      bodyWidget = _buildPlaceholderViewer();
    } else if (_viewerMode == ViewerMode.modelviewer || 
               (_viewerMode == ViewerMode.auto && _modelViewerAvailable)) {
      // ModelViewer 方案（推荐，但不在鸿蒙平台上使用）
      bodyWidget = _buildModelViewer();
    } else {
      // 自动模式但 ModelViewer 不可用，使用 WebView
      bodyWidget = _isWebViewReady 
          ? WebViewWidget(controller: _webViewController)
          : const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.modelName),
        backgroundColor: Colors.black87,
        actions: [
          if (_viewerMode == ViewerMode.webview && !_isWebViewReady)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
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
                  child: Text('使用 ModelViewer'),
                ),
                const PopupMenuItem(
                  value: 'webview',
                  child: Text('使用 WebView'),
                ),
              ],
              const PopupMenuItem(
                value: 'placeholder',
                child: Text('占位视图'),
              ),
            ],
          ),
        ],
      ),
      backgroundColor: Colors.black,
      body: bodyWidget,
    );
  }
}

enum ViewerMode {
  auto,          // 自动选择
  modelviewer,   // ModelViewer 方案
  webview,       // WebView 方案
  placeholder,  // 占位方案
}
