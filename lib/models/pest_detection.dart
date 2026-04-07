class PestDetectionModel {
  final String id;
  final String pestName;
  final String plotName;
  final String cropType;
  final String riskLevel;
  final List<String> symptoms;
  final String impact;
  final String? weatherAdvice;
  final List<String> naturalRecommendations;
  final List<String> chemicalRecommendations;
  final DateTime timestamp;

  PestDetectionModel({
    required this.id,
    required this.pestName,
    required this.plotName,
    required this.cropType,
    required this.riskLevel,
    required this.symptoms,
    required this.impact,
    this.weatherAdvice,
    required this.naturalRecommendations,
    required this.chemicalRecommendations,
    required this.timestamp,
  });
}
