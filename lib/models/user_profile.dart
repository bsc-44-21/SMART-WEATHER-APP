import 'package:cloud_firestore/cloud_firestore.dart';

class UserProfile {
  final String id;
  final bool isPremium;
  final int aiQueriesToday;
  final DateTime lastAiQueryDate;
  final int pestScansThisMonth;
  final DateTime lastPestScanDate;

  UserProfile({
    required this.id,
    this.isPremium = false,
    this.aiQueriesToday = 0,
    DateTime? lastAiQueryDate,
    this.pestScansThisMonth = 0,
    DateTime? lastPestScanDate,
  })  : lastAiQueryDate = lastAiQueryDate ?? DateTime.now().subtract(const Duration(days: 1)),
        lastPestScanDate = lastPestScanDate ?? DateTime.now().subtract(const Duration(days: 30));

  factory UserProfile.fromMap(Map<String, dynamic> data, String documentId) {
    return UserProfile(
      id: documentId,
      isPremium: data['isPremium'] ?? false,
      aiQueriesToday: data['aiQueriesToday'] ?? 0,
      lastAiQueryDate: data['lastAiQueryDate'] is Timestamp
          ? (data['lastAiQueryDate'] as Timestamp).toDate()
          : null,
      pestScansThisMonth: data['pestScansThisMonth'] ?? 0,
      lastPestScanDate: data['lastPestScanDate'] is Timestamp
          ? (data['lastPestScanDate'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'isPremium': isPremium,
      'aiQueriesToday': aiQueriesToday,
      'lastAiQueryDate': lastAiQueryDate,
      'pestScansThisMonth': pestScansThisMonth,
      'lastPestScanDate': lastPestScanDate,
    };
  }
}
