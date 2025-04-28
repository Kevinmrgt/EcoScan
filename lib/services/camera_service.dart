import 'dart:io';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' show join;
import 'package:path_provider/path_provider.dart';
import 'package:image/image.dart' as img;
import 'package:flutter/foundation.dart' show debugPrint;

class CameraService {
  CameraController? controller;
  List<CameraDescription>? cameras;
  late final ImagePicker _picker;

  // Singleton pattern
  static final CameraService _instance = CameraService._internal();
  factory CameraService() => _instance;

  CameraService._internal() {
    _picker = ImagePicker();
  }

  Future<void> initialize() async {
    try {
      cameras = await availableCameras();
      if (cameras != null && cameras!.isNotEmpty) {
        controller = CameraController(
          cameras![0],
          ResolutionPreset.medium,
          enableAudio: false,
          imageFormatGroup: Platform.isAndroid
              ? ImageFormatGroup.yuv420
              : ImageFormatGroup.bgra8888,
        );
        await controller!.initialize();
      }
    } catch (e) {
      debugPrint('Error initializing camera: $e');
    }
  }

  Future<String?> takePicture() async {
    if (controller == null || !controller!.value.isInitialized) {
      debugPrint('Error: Camera controller not initialized');
      return null;
    }

    try {
      // Réduire la résolution pour minimiser l'empreinte carbone
      controller!.setFlashMode(FlashMode.off);
      
      final XFile file = await controller!.takePicture();
      
      // Optimiser l'image pour réduire la taille
      final optimizedPath = await _optimizeImage(file.path);
      
      return optimizedPath;
    } catch (e) {
      debugPrint('Error taking picture: $e');
      return null;
    }
  }

  Future<String?> pickImage() async {
    try {
      final XFile? file = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
      );
      
      if (file == null) {
        return null;
      }
      
      // Optimiser l'image pour réduire la taille
      final optimizedPath = await _optimizeImage(file.path);
      
      return optimizedPath;
    } catch (e) {
      debugPrint('Error picking image: $e');
      return null;
    }
  }

  // Optimiser l'image pour réduire l'empreinte carbone
  Future<String> _optimizeImage(String imagePath) async {
    try {
      // Lire l'image
      final File originalFile = File(imagePath);
      final List<int> originalBytes = await originalFile.readAsBytes();
      final img.Image? originalImage = img.decodeImage(originalBytes);
      
      if (originalImage == null) {
        return imagePath;
      }
      
      // Redimensionner l'image à une résolution raisonnable
      final img.Image resizedImage = img.copyResize(
        originalImage,
        width: 800,
      );
      
      // Compresser l'image
      final List<int> compressedBytes = img.encodeJpg(resizedImage, quality: 85);
      
      // Sauvegarder l'image compressée
      final Directory directory = await getTemporaryDirectory();
      final String targetPath = join(
        directory.path,
        'optimized_${DateTime.now().millisecondsSinceEpoch}.jpg',
      );
      
      final File optimizedFile = File(targetPath);
      await optimizedFile.writeAsBytes(compressedBytes);
      
      return targetPath;
    } catch (e) {
      debugPrint('Error during image optimization: $e');
      return imagePath;
    }
  }

  void dispose() {
    controller?.dispose();
  }
}