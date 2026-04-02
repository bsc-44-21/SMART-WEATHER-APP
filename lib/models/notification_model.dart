import 'package:flutter/material.dart';

enum NotificationType {
  weather,
  pest,
  tip,
  system,
}

class NotificationModel {
  final String id;
  final String title;
  final String message;
  final NotificationType type;
  final DateTime timestamp;
  bool isRead;
  final String? actionLabel;
  final String? actionRoute;

  NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.timestamp,
    this.isRead = false,
    this.actionLabel,
    this.actionRoute,
  });
}
