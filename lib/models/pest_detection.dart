<<<<<<< HEAD
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
=======
import 'package:cloud_firestore/cloud_firestore.dart';

class PestDetectionModel {
  final String id;
  final String userId;
  final String cropType;
  final String plotName; // Linked plot name
  final String pestName;
  final List<String> symptoms;
  final String impact;
  final List<String> naturalRecommendations;
  final List<String> chemicalRecommendations;
  final String riskLevel;
  final DateTime timestamp;
  final String? imageUrl;
  final String? weatherAdvice; // Added to store smart advisory

  PestDetectionModel({
    required this.id,
    required this.userId,
    required this.cropType,
    required this.plotName, // Added
    required this.pestName,
    required this.symptoms,
    required this.impact,
    required this.naturalRecommendations,
    required this.chemicalRecommendations,
    required this.riskLevel,
    required this.timestamp,
    this.imageUrl,
    this.weatherAdvice,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'cropType': cropType,
      'plotName': plotName, // Added
      'pestName': pestName,
      'symptoms': symptoms,
      'impact': impact,
      'naturalRecommendations': naturalRecommendations,
      'chemicalRecommendations': chemicalRecommendations,
      'riskLevel': riskLevel,
      'timestamp': Timestamp.fromDate(timestamp),
      'imageUrl': imageUrl,
      'weatherAdvice': weatherAdvice,
    };
  }

  factory PestDetectionModel.fromMap(Map<String, dynamic> map, String id) {
    return PestDetectionModel(
      id: id,
      userId: map['userId'] ?? '',
      cropType: map['cropType'] ?? '',
      plotName: map['plotName'] ?? 'General', // Added
      pestName: map['pestName'] ?? '',
      symptoms: List<String>.from(map['symptoms'] ?? []),
      impact: map['impact'] ?? '',
      naturalRecommendations: List<String>.from(map['naturalRecommendations'] ?? []),
      chemicalRecommendations: List<String>.from(map['chemicalRecommendations'] ?? []),
      riskLevel: map['riskLevel'] ?? 'Low',
      timestamp: (map['timestamp'] as Timestamp).toDate(),
      imageUrl: map['imageUrl'],
      weatherAdvice: map['weatherAdvice'],
    );
  }
>>>>>>> ec92c3d034004b71c4bfeee6128e73920aa13109
}
