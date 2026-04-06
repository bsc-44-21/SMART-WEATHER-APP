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
