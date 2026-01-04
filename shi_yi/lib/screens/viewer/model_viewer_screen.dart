import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:webview_flutter/webview_flutter.dart';
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

  @override
  void initState() {
    super.initState();
    _initializeWebView();
    _loadModel();
  }

  void _initializeWebView() {
    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.black)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (String url) {
            if (mounted) {
              setState(() => _isWebViewReady = true);
            }
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
        // 否则从assets加载
        try {
          final ByteData data = await rootBundle.load('assets/models/hanfu-test.glb');
          final File file = File('${tempDir.path}/hanfu-test.glb');
          await file.writeAsBytes(data.buffer.asUint8List());
          modelPath = file.path;
        } catch (e) {
          throw Exception('无法加载模型文件: $e');
        }
      }

      // 加载Three.js库文件到临时目录
      final libsDir = Directory('${tempDir.path}/3d_libs');
      if (!await libsDir.exists()) {
        await libsDir.create(recursive: true);
      }

      // 复制Three.js库文件
      try {
        final threeJsData = await rootBundle.load('assets/3d_libs/three.min.js');
        final threeJsFile = File('${libsDir.path}/three.min.js');
        await threeJsFile.writeAsBytes(threeJsData.buffer.asUint8List());

        final gltfLoaderData = await rootBundle.load('assets/3d_libs/GLTFLoader.js');
        final gltfLoaderFile = File('${libsDir.path}/GLTFLoader.js');
        await gltfLoaderFile.writeAsBytes(gltfLoaderData.buffer.asUint8List());

        final orbitControlsData = await rootBundle.load('assets/3d_libs/OrbitControls.js');
        final orbitControlsFile = File('${libsDir.path}/OrbitControls.js');
        await orbitControlsFile.writeAsBytes(orbitControlsData.buffer.asUint8List());
      } catch (e) {
        throw Exception('无法加载Three.js库文件: $e');
      }

      setState(() {
        _modelPath = modelPath;
      });

      // 加载3D查看器HTML
      await _load3DViewer();
    } catch (e) {
      setState(() {
        _error = '模型加载失败: $e';
        _isLoading = false;
      });
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

      // 加载HTML到WebView，使用file://协议作为baseUrl
      await _webViewController.loadHtmlString(
        htmlContent,
        baseUrl: 'file://${tempDir.path}/',
      );

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = '3D查看器加载失败: $e';
        _isLoading = false;
      });
    }
  }

  String _generateHTML(String modelFileName, String libsBaseUrl, String modelBaseUrl) {
    // 使用UMD格式直接加载所有库（兼容性更好）
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
    <div id="info">${widget.modelName} - 单指旋转，双指缩放</div>
    <div id="container"></div>
    
    <!-- 使用ES6模块加载GLTFLoader和OrbitControls -->
    <script type="module">
        import { GLTFLoader } from '$gltfLoaderUrl';
        import { OrbitControls } from '$orbitControlsUrl';
        
        let scene, camera, renderer, controls, model;
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
        
        loader.load(
            modelPath,
            function(gltf) {
                model = gltf.scene;
                scene.add(model);
                
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
            }
        );
        
        // 动画循环
        function animate() {
            requestAnimationFrame(animate);
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
    </script>
</body>
</html>
''';
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

    if (_error != null) {
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
          if (!_isWebViewReady)
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
        ],
      ),
      backgroundColor: Colors.black,
      body: WebViewWidget(controller: _webViewController),
    );
  }
}
