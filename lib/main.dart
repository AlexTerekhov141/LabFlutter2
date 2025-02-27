/*
* Терехов А.В. FlutterLab2
* Work with camera in Flutter app
* 27.02.2025
* */
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final cameras = await availableCameras();
  final firstCamera = cameras.first;

  runApp(MyApp(camera: firstCamera));
}

class MyApp extends StatelessWidget {
  final CameraDescription camera;

  const MyApp({super.key, required this.camera});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Camera App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: CameraScreen(camera: camera),
    );
  }
}

class CameraScreen extends StatefulWidget {
  final CameraDescription camera;

  const CameraScreen({super.key, required this.camera});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  // Контроллер
  late CameraController _controller;
  // Future
  late Future<void> _initializeControllerFuture;
  XFile? _capturedImage;

  @override
  void initState() {
    super.initState();
    // Создаём контроллер
    _controller = CameraController(widget.camera, ResolutionPreset.high);
    // Инициализируем контроллер камеры и сохраняем Future
    _initializeControllerFuture = _controller.initialize();
  }

  @override
  void dispose() {
    // Освобождаем ресурсы
    _controller.dispose();
    super.dispose();
  }

  Future<void> _takePicture() async {
    try {
      await _initializeControllerFuture;
      // Снимаем фото
      final image = await _controller.takePicture();
      // Обновляем состояние
      setState(() {
        _capturedImage = image;
      });
      // Показываем снимок
      Future.delayed(const Duration(seconds: 2), () {
        setState(() {
          _capturedImage = null;
        });
      });
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Camera Preview')),
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            // Если инициализация завершена: отображаем фото или показываем превью камеры.
            return _capturedImage != null
                ? Center(child: Image.file(File(_capturedImage!.path)))
                : CameraPreview(_controller);
          } else {
            // Если инициализация еще не завершена, отображаем индикатор загрузки.
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _takePicture,
        child: const Icon(Icons.camera_alt),
      ),
    );
  }
}
