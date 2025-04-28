# Diagrammes EcoScan

Ce document présente les diagrammes UML de l'application EcoScan, une application mobile écologique permettant d'identifier des objets et de fournir des conseils de recyclage et de réutilisation.

## Diagramme de cas d'utilisation

```mermaid
flowchart TD
    User((Utilisateur))
    
    subgraph "Application EcoScan"
        UC1[Prendre une photo d'un objet]
        UC2[Sélectionner une image de la galerie]
        UC3[Analyser un objet]
        UC4[Consulter les conseils de recyclage]
        UC5[Consulter les conseils de réutilisation]
        UC6[Voir l'historique des analyses]
        UC7[Effacer l'historique]
        UC8[Consulter une analyse précédente]
    end
    
    User -->|Utilise| UC1
    User -->|Utilise| UC2
    User -->|Utilise| UC6
    User -->|Utilise| UC7
    User -->|Utilise| UC8
    
    UC1 -->|Déclenche| UC3
    UC2 -->|Déclenche| UC3
    UC3 -->|Génère| UC4
    UC3 -->|Génère| UC5
    UC8 -->|Affiche| UC4
    UC8 -->|Affiche| UC5
```

## Diagramme de classes

```mermaid
classDiagram
    class ScanResult {
        +String objectName
        +double confidence
        +String imagePath
        +List~RecyclingTip~ recyclingTips
        +List~ReuseTip~ reuseTips
        +DateTime timestamp
        +toJson() Map~String, dynamic~
        +fromJson(Map~String, dynamic~) ScanResult
    }
    
    class RecyclingTip {
        +String title
        +String description
        +String? iconPath
        +toJson() Map~String, dynamic~
        +fromJson(Map~String, dynamic~) RecyclingTip
    }
    
    class ReuseTip {
        +String title
        +String description
        +String? iconPath
        +String? tutorialUrl
        +toJson() Map~String, dynamic~
        +fromJson(Map~String, dynamic~) ReuseTip
    }
    
    class ScanProvider {
        -ObjectDetectionService _objectDetectionService
        -CacheService _cacheService
        -ScanResult? _lastScanResult
        -bool _isLoading
        -String? _errorMessage
        -List~ScanResult~ _history
        -bool _isInitialized
        +ScanResult? lastScanResult
        +bool isLoading
        +String? errorMessage
        +List~ScanResult~ history
        +bool isInitialized
        +initialize() Future~void~
        +analyzeImage(String) Future~void~
        +loadHistory() Future~void~
        +clearHistory() Future~void~
        +selectPreviousResult(ScanResult) void
    }
    
    class ObjectDetectionService {
        -List~String~ _mockObjects
        -Random _random
        -_instance ObjectDetectionService
        +initialize() Future~void~
        +analyzeImage(String) Future~ScanResult?~
        -_getRecyclingTipsForObject(String) List~RecyclingTip~
        -_getReuseTipsForObject(String) List~ReuseTip~
        +dispose() void
    }
    
    class CameraService {
        +CameraController? controller
        +List~CameraDescription~? cameras
        -ImagePicker _picker
        -_instance CameraService
        +initialize() Future~void~
        +takePicture() Future~String?~
        +pickImage() Future~String?~
        -_optimizeImage(String) Future~String~
        +dispose() void
    }
    
    class CacheService {
        -SharedPreferences? _prefs
        +initialize() Future~void~
        +cacheResult(ScanResult) Future~void~
        +getAllCachedResults() Future~List~ScanResult~~
        +clearCache() Future~void~
    }
    
    class HomeScreen {
        -CameraService _cameraService
        -bool _isInitializing
        -_initializeServices() Future~void~
        -_takePicture() Future~void~
        -_pickImage() Future~void~
        -_openCamera() void
        -_openHistory() void
    }
    
    class ResultScreen {
        -_buildImageSection(ScanResult) Widget
        -_buildObjectInfoSection(ScanResult, BuildContext) Widget
        -_buildRecyclingSection(ScanResult, BuildContext) Widget
        -_buildReuseSection(ScanResult, BuildContext) Widget
        -_buildFooterSection(BuildContext) Widget
    }
    
    class HistoryScreen {
        -_showClearHistoryDialog(BuildContext) void
        -_buildHistoryItem(ScanResult, BuildContext) Widget
    }
    
    class CameraScreen {
        -_controller CameraController?
        -_isInitializing bool
        -_initializeCamera() Future~void~
        -_takePicture() Future~void~
    }
    
    ScanProvider --> ScanResult : utilise
    ScanProvider --> ObjectDetectionService : utilise
    ScanProvider --> CacheService : utilise
    ObjectDetectionService --> RecyclingTip : crée
    ObjectDetectionService --> ReuseTip : crée
    ObjectDetectionService --> ScanResult : crée
    ScanResult --> RecyclingTip : contient
    ScanResult --> ReuseTip : contient
    HomeScreen --> CameraService : utilise
    HomeScreen --> ScanProvider : utilise
    ResultScreen --> ScanResult : affiche
    HistoryScreen --> ScanProvider : utilise
    CameraScreen --> CameraService : utilise
```

## Diagramme de flux

```mermaid
sequenceDiagram
    actor User as Utilisateur
    participant Home as HomeScreen
    participant Camera as CameraScreen/CameraService
    participant Scan as ScanProvider
    participant Detect as ObjectDetectionService
    participant Cache as CacheService
    participant Result as ResultScreen
    participant History as HistoryScreen
    
    User->>Home: Lance l'application
    Home->>Scan: initialize()
    Scan->>Detect: initialize()
    Scan->>Cache: getAllCachedResults()
    Cache-->>Scan: Liste des résultats
    
    alt Prise de photo
        User->>Home: Clique sur "Prendre une photo"
        Home->>Camera: _openCamera()
        User->>Camera: Prend une photo
        Camera->>Camera: takePicture()
        Camera->>Camera: _optimizeImage()
        Camera-->>Home: Chemin de l'image
    else Sélection depuis la galerie
        User->>Home: Clique sur "Galerie"
        Home->>Camera: pickImage()
        Camera->>Camera: _optimizeImage()
        Camera-->>Home: Chemin de l'image
    end
    
    Home->>Scan: analyzeImage(imagePath)
    Scan->>Detect: analyzeImage(imagePath)
    Detect-->>Scan: ScanResult
    Scan->>Cache: cacheResult(result)
    Scan-->>Home: notifyListeners()
    Home->>Result: Navigation
    Result->>Scan: lastScanResult
    Result-->>User: Affiche les résultats
    
    alt Consulter l'historique
        User->>Home: Clique sur "Historique"
        Home->>History: Navigation
        History->>Scan: loadHistory()
        Scan->>Cache: getAllCachedResults()
        Cache-->>Scan: Liste des résultats
        Scan-->>History: Liste des résultats
        History-->>User: Affiche l'historique
        
        opt Sélectionner un résultat précédent
            User->>History: Clique sur un élément
            History->>Scan: selectPreviousResult(result)
            History->>Result: Navigation
            Result->>Scan: lastScanResult
            Result-->>User: Affiche les résultats
        end
        
        opt Effacer l'historique
            User->>History: Clique sur "Effacer"
            History->>User: Demande de confirmation
            User->>History: Confirme
            History->>Scan: clearHistory()
            Scan->>Cache: clearCache()
            Scan-->>History: notifyListeners()
            History-->>User: Affiche historique vide
        end
    end
```