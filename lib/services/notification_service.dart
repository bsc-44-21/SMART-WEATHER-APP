import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import '../models/notification_model.dart';
import '../models/plot.dart';
import '../models/crop_milestone_data.dart';
import 'package:flutter/material.dart';
import 'ai_advisory_service.dart';

class NotificationService extends ChangeNotifier {
  final List<NotificationModel> _notifications = [];
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  List<NotificationModel> get notifications => _notifications;

  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  NotificationService() {
    _initLocalNotifications();
  }

  Future<void> _initLocalNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );

    // Provide a basic callback for when a notification is tapped
    await _flutterLocalNotificationsPlugin.initialize(
      settings: initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        // Handle notification tapped logic here if needed
      },
    );
  }



  void addNotification(NotificationModel notification) {
    _notifications.insert(0, notification);
    notifyListeners();
  }

  Future<void> showLocalNotification(String title, String body) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'smart_farming_alerts', // id
      'Smart Farming Alerts', // title
      channelDescription: 'Important farming and weather alerts',
      importance: Importance.max,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);
    await _flutterLocalNotificationsPlugin.show(
      id: DateTime.now().millisecondsSinceEpoch.remainder(100000), // Random ID
      title: title,
      body: body,
      notificationDetails: platformChannelSpecifics,
    );

    // Also add it to our in-app list
    addNotification(NotificationModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      message: body,
      type: NotificationType.system,
      timestamp: DateTime.now(),
    ));
  }

  void markAsRead(String id) {
    final index = _notifications.indexWhere((n) => n.id == id);
    if (index != -1 && !_notifications[index].isRead) {
      _notifications[index].isRead = true;
      notifyListeners();
    }
  }

  void markAllAsRead() {
    bool changed = false;
    for (var notification in _notifications) {
      if (!notification.isRead) {
        notification.isRead = true;
        changed = true;
      }
    }
    if (changed) {
      notifyListeners();
    }
  }

  void removeNotification(String id) {
    _notifications.removeWhere((n) => n.id == id);
    notifyListeners();
  }

  Future<void> schedulePlotMilestones(PlotModel plot, List<Map<String, dynamic>> existingLogs, {Map<String, dynamic>? plotWeather}) async {
    if (plot.plantingDate.isEmpty) return;

    DateTime plantingDate;
    try {
      plantingDate = DateTime.parse(plot.plantingDate);
    } catch (_) {
      return; // Invalid date
    }

    final milestones = CropMilestoneData.getMilestonesForCrop(plot.cropName, plot.name);
    
    // Find already completed or skipped milestones for this plot
    // Ensure we are checking logs for THIS plot
    final completedTitles = existingLogs
        .where((log) => log['plot'] == plot.name || log['plot'] == plot.id)
        .map((log) => log['title'] as String)
        .toSet();

    for (var milestone in milestones) {
      final days = milestone['dap'] as int;
      final milestoneTitle = milestone['title'] as String;

      if (completedTitles.contains(milestoneTitle)) {
        continue; // Already processed
      }

      final targetDate = plantingDate.add(Duration(days: days));
      
      // Early reminder at DAP - 7 days (at 8:00 AM)
      final earlyReminderDate = targetDate.subtract(const Duration(days: 7));
      final scheduleTime = DateTime(earlyReminderDate.year, earlyReminderDate.month, earlyReminderDate.day, 8, 0);
      final now = DateTime.now();
      
      // Use unique ID specific to plot and days
      final uniqueId = (plot.id.hashCode ^ days.hashCode).abs() % 100000;

      if (now.isAfter(scheduleTime)) {
        // It's time to show the actionable notification in the OS or just in memory
        // Add to active, actionable UI list immediately, UNLESS it's already in the list
        if (!_notifications.any((n) => n.relatedPlotId == plot.id && n.activityTitle == milestoneTitle)) {
          final newNotif = NotificationModel(
            id: '${plot.id}_$days',
            title: milestoneTitle,
            message: milestone['body'],
            type: NotificationType.tip,
            timestamp: now,
            isActionable: true,
            relatedPlotId: plot.id,
            activityTitle: milestoneTitle,
            associatedDap: days,
          );
          addNotification(newNotif);

          // Background Fetch AI Advice if weather is available
          if (plotWeather != null) {
            _fetchAiAdvice(newNotif, plot.cropName, plotWeather);
          }
        }
      } else {
        // It's still in the future, schedule the OS push for the reminder
        _scheduleNotification(
          id: uniqueId, 
          title: "Upcoming: $milestoneTitle",
          body: "Starts in 7 days: ${milestone['body']}",
          scheduledDate: scheduleTime,
          type: NotificationType.tip,
        );
      }
    }
  }

  Future<void> _scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    required NotificationType type,
  }) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'smart_farming_milestones',
      'Smart Farming Milestones',
      channelDescription: 'Notifications for crop milestones',
      importance: Importance.max,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    final tzDate = tz.TZDateTime.from(scheduledDate, tz.local);

    await _flutterLocalNotificationsPlugin.zonedSchedule(
      id: id,
      title: title,
      body: body,
      scheduledDate: tzDate,
      notificationDetails: platformChannelSpecifics,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  Future<void> _fetchAiAdvice(NotificationModel notification, String cropName, Map<String, dynamic> weather) async {
    notification.isAnalyzing = true;
    notifyListeners();

    try {
      final advice = await AiAdvisoryService.analyzeActivity(
        activity: notification.activityTitle ?? notification.title,
        date: "Today",
        cropName: cropName,
        weatherData: weather,
      );

      notification.aiAdvice = advice['feedback_message'];
    } catch (e) {
      print('[NotificationService] AI Advice Error: $e');
    } finally {
      notification.isAnalyzing = false;
      notifyListeners();
    }
  }
}
