import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/scan_result.dart';
import '../providers/scan_provider.dart';

class ResultScreen extends StatelessWidget {
  const ResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ScanProvider>(
      builder: (context, scanProvider, child) {
        final result = scanProvider.lastScanResult;
        
        if (result == null) {
          // Normalement, l'utilisateur ne devrait pas atteindre cet écran sans résultat
          return Scaffold(
            appBar: AppBar(
              title: const Text('Résultats'),
            ),
            body: const Center(
              child: Text('Aucun résultat disponible'),
            ),
          );
        }
        
        return Scaffold(
          appBar: AppBar(
            title: const Text('Résultats d\'analyse'),
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Image de l'objet scanné
                _buildImageSection(result),
                
                // Information sur l'objet détecté
                _buildObjectInfoSection(result, context),
                
                // Conseils de recyclage
                _buildRecyclingSection(result, context),
                
                // Conseils de réutilisation
                _buildReuseSection(result, context),
                
                // Appel à l'action final et note écologique
                _buildFooterSection(context),
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () => Navigator.pop(context),
            backgroundColor: Theme.of(context).colorScheme.secondary,
            tooltip: 'Scanner un autre objet',
            child: const Icon(Icons.camera_alt),
          ),
        );
      },
    );
  }
  
  Widget _buildImageSection(ScanResult result) {
    return Container(
      height: 200,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.black.withAlpha(25), // Remplacé withOpacity par withAlpha
      ),
      child: Image.file(
        File(result.imagePath),
        fit: BoxFit.contain,
      ),
    );
  }
  
  Widget _buildObjectInfoSection(ScanResult result, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.check_circle,
                color: Theme.of(context).colorScheme.primary,
                size: 32,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Objet identifié',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                    Text(
                      result.objectName,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    Text(
                      'Confiance: ${(result.confidence * 100).toStringAsFixed(1)}%',
                      style: const TextStyle(
                        fontSize: 14,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Divider(height: 32),
        ],
      ),
    );
  }
  
  Widget _buildRecyclingSection(ScanResult result, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.recycling,
                color: Colors.green[700],
                size: 28,
              ),
              const SizedBox(width: 12),
              Text(
                'Comment recycler',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...result.recyclingTips.map((tip) => _buildTipCard(
            tip.title,
            tip.description,
            tip.iconPath,
            Colors.green.withAlpha(25), // Remplacé withOpacity par withAlpha
            context,
          )),
          const Divider(height: 32),
        ],
      ),
    );
  }
  
  Widget _buildReuseSection(ScanResult result, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.autorenew,
                color: Colors.blue[700],
                size: 28,
              ),
              const SizedBox(width: 12),
              Text(
                'Comment réutiliser',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...result.reuseTips.map((tip) {
            final card = _buildTipCard(
              tip.title,
              tip.description,
              tip.iconPath,
              Colors.blue.withAlpha(25), // Remplacé withOpacity par withAlpha
              context,
            );
            
            if (tip.tutorialUrl != null) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  card,
                  Padding(
                    padding: const EdgeInsets.only(left: 16.0, bottom: 16.0),
                    child: TextButton.icon(
                      onPressed: () {
                        // Dans une application réelle, ouvrirait le lien
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Ouverture du tutoriel...'),
                          ),
                        );
                      },
                      icon: const Icon(Icons.play_circle_outline),
                      label: const Text('Voir le tutoriel'),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.blue[700],
                      ),
                    ),
                  ),
                ],
              );
            }
            
            return card;
          }),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
  
  Widget _buildTipCard(
    String title,
    String description,
    String? iconPath,
    Color backgroundColor,
    BuildContext context,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12.0),
      elevation: 1,
      color: backgroundColor,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: const TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildFooterSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      color: Colors.grey[200],
      child: Column(
        children: [
          const Text(
            '🌱 Chaque petit geste compte pour la planète',
            style: TextStyle(
              fontStyle: FontStyle.italic,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            'Optimisé pour réduire l\'empreinte carbone',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}