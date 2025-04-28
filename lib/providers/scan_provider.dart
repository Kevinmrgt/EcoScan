import 'package:flutter/material.dart';
import '../models/scan_result.dart';
import '../services/object_detection_service.dart';
import '../services/cache_service.dart';

class ScanProvider extends ChangeNotifier {
  final ObjectDetectionService _objectDetectionService = ObjectDetectionService();
  final CacheService _cacheService = CacheService();

  ScanResult? _lastScanResult;
  bool _isLoading = false;
  String? _errorMessage;
  List<ScanResult> _history = [];
  bool _isInitialized = false;

  ScanResult? get lastScanResult => _lastScanResult;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<ScanResult> get history => _history;
  bool get isInitialized => _isInitialized;

  // Initialiser les services
  Future<void> initialize() async {
    if (_isInitialized) return;

    _setLoading(true);
    try {
      await _objectDetectionService.initialize();
      _history = await _cacheService.getAllCachedResults();
      _isInitialized = true;
    } catch (e) {
      _setError('Erreur lors de l\'initialisation: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  // Analyser une image
  Future<void> analyzeImage(String imagePath) async {
    if (!_isInitialized) {
      await initialize();
    }

    _setLoading(true);
    _clearError();

    try {
      // Vérifier si nous avons déjà l'objet dans le cache (comparaison d'images)
      // Ceci serait implémenté dans une version réelle avec des hash d'images
      
      // Si nous n'avons pas de résultat en cache, analyser l'image
      final result = await _objectDetectionService.analyzeImage(imagePath);
      
      if (result == null) {
        _setError('Impossible d\'identifier l\'objet. Essayez une autre image.');
        return;
      }
      
      // Mise à jour de l'état
      _lastScanResult = result;
      
      // Ajouter le résultat à l'historique et au cache
      if (!_history.any((item) => item.objectName == result.objectName)) {
        _history.add(result);
      }
      await _cacheService.cacheResult(result);
      
      notifyListeners();
    } catch (e) {
      _setError('Erreur lors de l\'analyse: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  // Récupérer tous les résultats du cache
  Future<void> loadHistory() async {
    _setLoading(true);
    try {
      _history = await _cacheService.getAllCachedResults();
      _history.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      notifyListeners();
    } catch (e) {
      _setError('Erreur lors du chargement de l\'historique: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  // Effacer l'historique
  Future<void> clearHistory() async {
    _setLoading(true);
    try {
      await _cacheService.clearCache();
      _history = [];
      _lastScanResult = null;
      notifyListeners();
    } catch (e) {
      _setError('Erreur lors du nettoyage de l\'historique: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  // Sélectionner un résultat précédent
  void selectPreviousResult(ScanResult result) {
    _lastScanResult = result;
    notifyListeners();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _objectDetectionService.dispose();
    super.dispose();
  }
}