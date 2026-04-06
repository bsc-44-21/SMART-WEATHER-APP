import 'package:cloud_firestore/cloud_firestore.dart';

class ActivityLogModel {
  final String id;
  final String userId;
  final String plot;
  final String title;
  final String time;
  final bool? isRecommended;
  final String? aiFeedback;
  final DateTime createdAt;

    ActivityLogModel({
    required this.id,
    required this.userId,
    required this.plot,
    required this.title,
    required this.time,
    this.isRecommended,
    this.aiFeedback,
    required this.createdAt,
  });

 Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'plot': plot,
      'title': title,
      'time': time,
      'isRecommended': isRecommended,
      'aiFeedback': aiFeedback,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory ActivityLogModel.fromMap(Map<String, dynamic> map, String docId) {
    return ActivityLogModel(
      id: docId,
      userId: map['userId'] ?? '',
      plot: map['plot'] ?? '',
      title: map['title'] ?? '',
      time: map['time'] ?? '',
      isRecommended: map['isRecommended'],
      aiFeedback: map['aiFeedback'],
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}