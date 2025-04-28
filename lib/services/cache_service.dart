import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/scan_result.dart';
import 'package:flutter/foundation.dart' show debugPrint;

class CacheService {
  static const String _cacheKey = 'scan_results_cache';
  static const int _maxCacheItems = 20; // Limiter la taille du cache

  // Singleton pattern
  static final CacheService _instance = CacheService._internal();
  factory CacheService() => _instance;
  CacheService._internal();

  // Sauvegarder un résultat de scan dans le cache
  Future<void> cacheResult(ScanResult result) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Récupérer le cache actuel
      final cachedData = prefs.getStringList(_cacheKey) ?? [];
      
      // Convertir le résultat en JSON
      final resultJson = jsonEncode(result.toJson());
      
      // Vérifier si cet objet existe déjà dans le cache (basé sur le nom de l'objet)
      final objectNameIndex = cachedData.indexWhere(
        (item) => jsonDecode(item)['objectName'] == result.objectName
      );
      
      List<String> updatedCache;
      if (objectNameIndex != -1) {
        // Mise à jour du résultat existant
        updatedCache = List.from(cachedData);
        updatedCache[objectNameIndex] = resultJson;
      } else {
        // Ajouter un nouveau résultat
        updatedCache = [...cachedData, resultJson];
        
        // Si le cache dépasse la limite, supprimer les entrées les plus anciennes
        if (updatedCache.length > _maxCacheItems) {
          updatedCache = updatedCache.sublist(
            updatedCache.length - _maxCacheItems
          );
        }
      }
      
      // Sauvegarder le cache mis à jour
      await prefs.setStringList(_cacheKey, updatedCache);
    } catch (e) {
      debugPrint('Error caching scan result: $e');
    }
  }

  // Récupérer un résultat de scan du cache par nom d'objet
  Future<ScanResult?> getCachedResult(String objectName) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Récupérer le cache actuel
      final cachedData = prefs.getStringList(_cacheKey) ?? [];
      
      // Rechercher l'objet dans le cache
      final resultJson = cachedData.firstWhere(
        (item) => jsonDecode(item)['objectName'] == objectName,
        orElse: () => '',
      );
      
      if (resultJson.isNotEmpty) {
        return ScanResult.fromJson(jsonDecode(resultJson));
      }
      
      return null;
    } catch (e) {
      debugPrint('Error retrieving cached result: $e');
      return null;
    }
  }

  // Récupérer tous les résultats de scan du cache
  Future<List<ScanResult>> getAllCachedResults() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Récupérer le cache actuel
      final cachedData = prefs.getStringList(_cacheKey) ?? [];
      
      // Convertir tous les éléments en objets ScanResult
      return cachedData
          .map((item) => ScanResult.fromJson(jsonDecode(item)))
          .toList();
    } catch (e) {
      debugPrint('Error retrieving all cached results: $e');
      return [];
    }
  }

  // Nettoyer les images temporaires qui ne sont plus référencées par le cache
  Future<void> cleanupUnusedImages() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Récupérer le cache actuel
      final cachedData = prefs.getStringList(_cacheKey) ?? [];
      
      // Extraire tous les chemins d'image du cache
      final cachedImagePaths = cachedData
          .map((item) => jsonDecode(item)['imagePath'] as String)
          .toSet();
      
      // Récupérer tous les fichiers dans le dossier temporaire
      final tempDir = await getTemporaryDirectory();
      final tempFiles = Directory(tempDir.path)
          .listSync()
          .whereType<File>()
          .where((file) => file.path.contains('optimized_'))
          .toList();
      
      // Supprimer les fichiers d'image qui ne sont plus référencés dans le cache
      for (final file in tempFiles) {
        if (!cachedImagePaths.contains(file.path)) {
          await file.delete();
          debugPrint('Deleted unused image: ${file.path}');
        }
      }
    } catch (e) {
      debugPrint('Error cleaning up unused images: $e');
    }
  }

  // Vider complètement le cache
  Future<void> clearCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_cacheKey);
      
      // Nettoyer aussi les images
      await cleanupUnusedImages();
    } catch (e) {
      debugPrint('Error clearing cache: $e');
    }
  }
}