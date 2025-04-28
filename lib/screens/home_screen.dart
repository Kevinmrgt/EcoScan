import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/scan_provider.dart';
import '../services/camera_service.dart';
import 'camera_screen.dart';
import 'result_screen.dart';
import 'history_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final CameraService _cameraService = CameraService();
  bool _isInitializing = true;
  
  @override
  void initState() {
    super.initState();
    _initializeServices();
  }
  
  Future<void> _initializeServices() async {
    final scanProvider = Provider.of<ScanProvider>(context, listen: false);
    await scanProvider.initialize();
    await _cameraService.initialize();
    
    if (mounted) {
      setState(() {
        _isInitializing = false;
      });
    }
  }
  
  Future<void> _takePicture() async {
    final imagePath = await _cameraService.takePicture();
    if (imagePath != null && mounted) {
      // Naviguer vers la caméra ou directement analyser l'image
      final scanProvider = Provider.of<ScanProvider>(context, listen: false);
      await scanProvider.analyzeImage(imagePath);
      
      if (mounted && scanProvider.lastScanResult != null) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ResultScreen()),
        );
      }
    }
  }
  
  Future<void> _pickImage() async {
    final imagePath = await _cameraService.pickImage();
    if (imagePath != null && mounted) {
      final scanProvider = Provider.of<ScanProvider>(context, listen: false);
      await scanProvider.analyzeImage(imagePath);
      
      if (mounted && scanProvider.lastScanResult != null) {
        Navigator.push(
          context, 
          MaterialPageRoute(builder: (context) => const ResultScreen()),
        );
      }
    }
  }
  
  void _openCamera() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CameraScreen()),
    );
  }
  
  void _openHistory() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const HistoryScreen()),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('EcoScan'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: _isInitializing ? null : _openHistory,
            tooltip: 'Historique',
          ),
        ],
      ),
      body: Consumer<ScanProvider>(
        builder: (context, scanProvider, child) {
          if (_isInitializing || scanProvider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          
          if (scanProvider.errorMessage != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    color: Theme.of(context).colorScheme.error,
                    size: 60,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    scanProvider.errorMessage!,
                    style: Theme.of(context).textTheme.titleMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _openCamera,
                    child: const Text('Réessayer'),
                  ),
                ],
              ),
            );
          }
          
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo ou image d'en-tête
                  Icon(
                    Icons.eco,
                    size: 120,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 24),
                  // Titre de l'application
                  Text(
                    'EcoScan',
                    style: Theme.of(context).textTheme.headlineLarge,
                  ),
                  const SizedBox(height: 16),
                  // Description
                  Text(
                    'Scannez des objets et découvrez comment les recycler ou les réutiliser de manière écologique.',
                    style: Theme.of(context).textTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 48),
                  // Bouton principal pour scanner
                  ElevatedButton.icon(
                    onPressed: _openCamera,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                    ),
                    icon: const Icon(Icons.camera_alt),
                    label: const Text(
                      'Scanner un objet',
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Bouton pour choisir une image existante
                  TextButton.icon(
                    onPressed: _pickImage,
                    icon: const Icon(Icons.photo_library),
                    label: const Text('Choisir depuis la galerie'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
  
  @override
  void dispose() {
    _cameraService.dispose();
    super.dispose();
  }
}