
enum NotificationType {
  weather,
  pest,
  tip,
  success,
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
  final bool isActionable;
  final String? relatedPlotId;
  final String? activityTitle;
  final int? associatedDap;
  String? aiAdvice;
  bool isAnalyzing;

  NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.timestamp,
    this.isRead = false,
    this.actionLabel,
    this.actionRoute,
    this.isActionable = false,
    this.relatedPlotId,
    this.activityTitle,
    this.associatedDap,
    this.aiAdvice,
    this.isAnalyzing = false,
  });
}