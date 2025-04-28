class ScanResult {
  final String objectName;
  final double confidence;
  final String imagePath;
  final List<RecyclingTip> recyclingTips;
  final List<ReuseTip> reuseTips;
  final DateTime timestamp;

  ScanResult({
    required this.objectName,
    required this.confidence,
    required this.imagePath,
    required this.recyclingTips,
    required this.reuseTips,
    required this.timestamp,
  });

  // Pour la mise en cache des résultats
  Map<String, dynamic> toJson() {
    return {
      'objectName': objectName,
      'confidence': confidence,
      'imagePath': imagePath,
      'recyclingTips': recyclingTips.map((tip) => tip.toJson()).toList(),
      'reuseTips': reuseTips.map((tip) => tip.toJson()).toList(),
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory ScanResult.fromJson(Map<String, dynamic> json) {
    return ScanResult(
      objectName: json['objectName'],
      confidence: json['confidence'],
      imagePath: json['imagePath'],
      recyclingTips: (json['recyclingTips'] as List)
          .map((tipJson) => RecyclingTip.fromJson(tipJson))
          .toList(),
      reuseTips: (json['reuseTips'] as List)
          .map((tipJson) => ReuseTip.fromJson(tipJson))
          .toList(),
      timestamp: DateTime.parse(json['timestamp']),
    );
  }
}

class RecyclingTip {
  final String title;
  final String description;
  final String? iconPath;

  RecyclingTip({
    required this.title,
    required this.description,
    this.iconPath,
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'iconPath': iconPath,
    };
  }

  factory RecyclingTip.fromJson(Map<String, dynamic> json) {
    return RecyclingTip(
      title: json['title'],
      description: json['description'],
      iconPath: json['iconPath'],
    );
  }
}

class ReuseTip {
  final String title;
  final String description;
  final String? iconPath;
  final String? tutorialUrl;

  ReuseTip({
    required this.title,
    required this.description,
    this.iconPath,
    this.tutorialUrl,
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'iconPath': iconPath,
      'tutorialUrl': tutorialUrl,
    };
  }

  factory ReuseTip.fromJson(Map<String, dynamic> json) {
    return ReuseTip(
      title: json['title'],
      description: json['description'],
      iconPath: json['iconPath'],
      tutorialUrl: json['tutorialUrl'],
    );
  }
}