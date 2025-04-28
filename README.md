# EcoScan - Application d'analyse écologique d'objets

EcoScan est une application mobile Flutter qui permet aux utilisateurs d'identifier des objets et de recevoir des conseils sur la façon de les recycler ou de les réutiliser de manière écologique. L'application utilise la reconnaissance d'images pour analyser des objets à partir de photos prises avec l'appareil photo ou importées depuis la galerie.

![EcoScan Logo](assets/icons/eco.png)

## 📱 Fonctionnalités

- **Analyse d'objets** : Prenez une photo ou sélectionnez une image de la galerie pour identifier des objets et obtenir des conseils écologiques.
- **Conseils de recyclage** : Recevez des informations détaillées sur comment recycler correctement l'objet identifié.
- **Conseils de réutilisation** : Découvrez des idées créatives pour donner une seconde vie aux objets.
- **Historique des analyses** : Consultez et gérez l'historique de vos analyses précédentes.

## 🛠️ Technologies utilisées

- **Flutter** : Framework de développement cross-platform
- **Provider** : Gestion d'état
- **Camera** : Accès à l'appareil photo de l'appareil
- **Image Picker** : Sélection d'images depuis la galerie
- **Shared Preferences** : Stockage local de données
- **TensorFlow Lite** : (à venir) Modèle de détection d'objets

## 🏗️ Architecture

L'application est structurée selon le modèle MVVM (Model-View-ViewModel) :

### Modèle de données
- `ScanResult` : Représente le résultat d'une analyse d'objet
- `RecyclingTip` : Conseils de recyclage pour un objet
- `ReuseTip` : Conseils de réutilisation pour un objet

### Services
- `ObjectDetectionService` : Service responsable de l'analyse d'images et de l'identification d'objets
- `CameraService` : Gère l'accès à l'appareil photo et à la galerie d'images
- `CacheService` : Stocke et récupère les résultats d'analyses précédentes

### Écrans
- `HomeScreen` : Écran principal avec options pour scanner ou choisir une image
- `CameraScreen` : Interface pour prendre une photo
- `ResultScreen` : Affiche les résultats de l'analyse et les conseils
- `HistoryScreen` : Affiche l'historique des analyses précédentes

## 📊 Diagrammes

L'application comprend les diagrammes suivants pour documenter son architecture :
- Diagramme de cas d'utilisation
- Diagramme de classes
- Diagramme de flux

Pour plus de détails, consultez le fichier [diagram.md](diagram.md).

## 🚀 Installation

1. Assurez-vous d'avoir Flutter installé sur votre machine
   ```
   flutter doctor
   ```

2. Clonez le dépôt
   ```
   git clone https://github.com/votre-utilisateur/ecoscan.git
   ```

3. Installez les dépendances
   ```
   flutter pub get
   ```

4. Exécutez l'application
   ```
   flutter run
   ```

## 📝 Notes de développement

- L'application utilise actuellement des données simulées pour la détection d'objets
- L'intégration d'un modèle TensorFlow Lite pour la détection d'objets est prévue
- Des correctifs pour TensorFlow Lite sont disponibles dans le dossier `/patches`

## 📄 Licence

Ce projet est sous licence MIT - voir le fichier LICENSE pour plus de détails.

## 🤝 Contribution

Les contributions sont les bienvenues ! N'hésitez pas à ouvrir une issue ou à soumettre une pull request.

---

Développé avec ❤️ par l'équipe EcoScan
