import 'dart:io';
import 'dart:math';
import 'package:flutter/services.dart';
import '../models/scan_result.dart';

/// Service simulé pour la reconnaissance d'objets
/// Utilisé pour le MVP en attendant l'intégration complète de TensorFlow Lite
class ObjectDetectionService {
  // Liste d'objets fictifs pour la démonstration
  final List<String> _mockObjects = [
    'Bouteille plastique',
    'Canette aluminium',
    'Emballage carton',
    'Sac plastique',
    'Bouteille en verre',
    'Journal',
    'Pot de yaourt',
    'Boîte de conserve',
    'Pile électrique',
    'Appareil électronique'
  ];
  
  final Random _random = Random();
  
  // Singleton pattern
  static final ObjectDetectionService _instance = ObjectDetectionService._internal();
  factory ObjectDetectionService() => _instance;
  
  ObjectDetectionService._internal();
  
  Future<void> initialize() async {
    // Simulation de l'initialisation
    await Future.delayed(const Duration(milliseconds: 500));
    print('ObjectDetectionService mock initialized successfully');
  }
  
  Future<ScanResult?> analyzeImage(String imagePath) async {
    // Simuler un temps de traitement réaliste
    await Future.delayed(const Duration(seconds: 1, milliseconds: 500));
    
    try {
      // Vérifie si le fichier image existe réellement
      final imageFile = File(imagePath);
      if (!await imageFile.exists()) {
        throw Exception('Image file not found');
      }
      
      // Génère un objet aléatoire de la liste pour la démonstration
      final objectName = _mockObjects[_random.nextInt(_mockObjects.length)];
      final confidence = 0.7 + (_random.nextDouble() * 0.25); // Entre 0.7 et 0.95
      
      // Générer des conseils spécifiques à l'objet
      return ScanResult(
        objectName: objectName,
        confidence: confidence,
        imagePath: imagePath,
        recyclingTips: _getRecyclingTipsForObject(objectName),
        reuseTips: _getReuseTipsForObject(objectName),
        timestamp: DateTime.now(),
      );
    } catch (e) {
      print('Error during mock image analysis: $e');
      return null;
    }
  }
  
  List<RecyclingTip> _getRecyclingTipsForObject(String objectName) {
    // Conseils de recyclage spécifiques à chaque type d'objet
    switch (objectName) {
      case 'Bouteille plastique':
        return [
          RecyclingTip(
            title: 'Bac jaune',
            description: 'Déposez dans le bac de tri sélectif jaune après avoir retiré le bouchon.',
          ),
          RecyclingTip(
            title: 'Écraser',
            description: 'Écrasez la bouteille horizontalement pour gagner de l\'espace.',
          ),
        ];
      case 'Canette aluminium':
        return [
          RecyclingTip(
            title: 'Bac jaune',
            description: 'Les canettes sont recyclables à l\'infini, déposez-les dans le bac jaune.',
          ),
          RecyclingTip(
            title: 'Point de collecte',
            description: 'Certaines communes ont des points de collecte spécifiques pour l\'aluminium.',
          ),
        ];
      case 'Emballage carton':
        return [
          RecyclingTip(
            title: 'Bac jaune',
            description: 'Pliez le carton avant de le jeter pour gagner de la place.',
          ),
          RecyclingTip(
            title: 'Déchetterie',
            description: 'Les gros cartons peuvent être amenés en déchetterie.',
          ),
        ];
      case 'Appareil électronique':
        return [
          RecyclingTip(
            title: 'Point de collecte spécial',
            description: 'Apportez les appareils électroniques dans un point de collecte DEEE.',
          ),
          RecyclingTip(
            title: 'Reprise magasin',
            description: 'Les magasins d\'électronique sont tenus de reprendre vos anciens appareils.',
          ),
        ];
      default:
        return [
          RecyclingTip(
            title: 'Centre de tri',
            description: 'Déposez cet objet dans un centre de tri local pour un recyclage approprié.',
          ),
          RecyclingTip(
            title: 'Démontage',
            description: 'Séparez les différents matériaux avant de recycler.',
          ),
        ];
    }
  }
  
  List<ReuseTip> _getReuseTipsForObject(String objectName) {
    // Conseils de réutilisation spécifiques à chaque type d'objet
    switch (objectName) {
      case 'Bouteille plastique':
        return [
          ReuseTip(
            title: 'Mini serre',
            description: 'Transformez-la en mini serre pour faire pousser des plantes.',
            tutorialUrl: 'https://example.com/mini-serre',
          ),
          ReuseTip(
            title: 'Pot à crayons',
            description: 'Coupez le haut et décorez-la pour en faire un pot à crayons.',
          ),
        ];
      case 'Canette aluminium':
        return [
          ReuseTip(
            title: 'Porte-bougie',
            description: 'Nettoyez-la et percez des motifs pour créer un joli porte-bougie.',
            tutorialUrl: 'https://example.com/bougie-canette',
          ),
          ReuseTip(
            title: 'Pot de fleurs',
            description: 'Transformez-la en petit pot pour plantes succulentes.',
          ),
        ];
      default:
        return [
          ReuseTip(
            title: 'Projet DIY',
            description: 'Transformez cet objet en un projet créatif.',
            tutorialUrl: 'https://example.com/diy',
          ),
          ReuseTip(
            title: 'Don',
            description: 'Si l\'objet est encore fonctionnel, envisagez de le donner à une association locale.',
          ),
        ];
    }
  }
  
  void dispose() {
    // Rien à nettoyer dans cette implémentation simulée
  }
}