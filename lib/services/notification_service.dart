import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../models/notification_model.dart';
import 'package:flutter/material.dart';

class NotificationService extends ChangeNotifier {
  final List<NotificationModel> _notifications = [];
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  List<NotificationModel> get notifications => _notifications;

  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  NotificationService() {
    _initLocalNotifications();
    _loadInitialMockData();
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

  void _loadInitialMockData() {
    _notifications.addAll([
      NotificationModel(
        id: '1',
        title: 'Urgent Warning',
        message: 'Heavy rains may damage your crops. Take action immediately.',
        type: NotificationType.weather,
        timestamp: DateTime.now().subtract(const Duration(minutes: 2)),
        actionLabel: 'View Weather',
      ),
      NotificationModel(
        id: '2',
        title: 'Rain Alert',
        message: 'Moderate rain expected later today.',
        type: NotificationType.weather,
        timestamp: DateTime.now().subtract(const Duration(minutes: 12)),
      ),
      NotificationModel(
        id: '3',
        title: 'Pest Risk Predicted',
        message: 'Conditions are favorable for aphids. Check your tomatoes.',
        type: NotificationType.pest,
        timestamp: DateTime.now().subtract(const Duration(minutes: 40)),
      ),
      NotificationModel(
        id: '4',
        title: 'Fertilizer Tip',
        message: 'Apply nitrogen fertilizer this week. It is crucial for optimal growth.',
        type: NotificationType.tip,
        timestamp: DateTime.now().subtract(const Duration(days: 1)),
        isRead: true, // Example of pre-read notification
      ),
    ]);
    notifyListeners();
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
}
