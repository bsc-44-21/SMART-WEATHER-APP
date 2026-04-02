import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../widgets/common_widgets.dart';
import '../core/theme.dart';
import '../services/notification_service.dart';
import '../models/notification_model.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const AppLogo(size: 40, backgroundColor: Colors.white),
                      const SizedBox(width: 16),
                      Text(
                        'Notifications',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 28,
                        ),
                      ),
                    ],
                  ),
                  Consumer<NotificationService>(
                    builder: (context, notificationService, child) {
                      if (notificationService.unreadCount > 0) {
                        return IconButton(
                          icon: const Icon(LucideIcons.checkCheck),
                          tooltip: 'Mark all as read',
                          onPressed: () {
                            notificationService.markAllAsRead();
                          },
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Notifications List
              Expanded(
                child: Consumer<NotificationService>(
                  builder: (context, notificationService, child) {
                    final notifications = notificationService.notifications;

                    if (notifications.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              LucideIcons.bellRing,
                              size: 64,
                              color: AppTheme.textMuted.withOpacity(0.5),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              "You're all caught up!",
                              style: TextStyle(
                                fontSize: 18,
                                color: AppTheme.textMuted,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return ListView.separated(
                      itemCount: notifications.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 16),
                      itemBuilder: (context, index) {
                        final notification = notifications[index];
                        return Dismissible(
                          key: Key(notification.id),
                          direction: DismissDirection.endToStart,
                          onDismissed: (direction) {
                            notificationService.removeNotification(notification.id);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Notification dismissed'),
                                duration: Duration(seconds: 2),
                              ),
                            );
                          },
                          background: Container(
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            decoration: BoxDecoration(
                              color: Colors.red.shade400,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Icon(
                              LucideIcons.trash2,
                              color: Colors.white,
                            ),
                          ),
                          child: GestureDetector(
                            onTap: () {
                              if (!notification.isRead) {
                                notificationService.markAsRead(notification.id);
                              }
                            },
                            child: _NotificationCard(notification: notification),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),

              const SizedBox(height: 24),

              // Back Button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: BorderSide(color: AppTheme.primaryAccent.withOpacity(0.5)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Back to Settings',
                    style: TextStyle(
                      color: AppTheme.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  final NotificationModel notification;

  const _NotificationCard({required this.notification});

  @override
  Widget build(BuildContext context) {
    Color cardColor;
    Color iconColor;
    IconData icon;

    switch (notification.type) {
      case NotificationType.weather:
        cardColor = const Color(0xFFFFEBEE); // Light red
        iconColor = Colors.red;
        icon = LucideIcons.cloudRain;
        break;
      case NotificationType.pest:
        cardColor = const Color(0xFFE8F5E9); // Light green
        iconColor = Colors.green;
        icon = LucideIcons.bug;
        break;
      case NotificationType.tip:
        cardColor = Colors.white;
        iconColor = Colors.black54;
        icon = LucideIcons.leaf;
        break;
      case NotificationType.system:
      default:
        cardColor = const Color(0xFFE8EAF6); // Light indigo
        iconColor = Colors.indigo;
        icon = LucideIcons.info;
        break;
    }

    if (notification.isRead) {
      cardColor = Colors.grey.shade100;
      iconColor = iconColor.withOpacity(0.5);
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: notification.isRead
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
        border: notification.isRead
            ? Border.all(color: Colors.grey.shade300, width: 1)
            : null,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        notification.title,
                        style: TextStyle(
                          fontWeight: notification.isRead ? FontWeight.w600 : FontWeight.bold,
                          fontSize: 16,
                          color: notification.isRead ? AppTheme.textMuted : (iconColor == Colors.black54 ? AppTheme.textPrimary : iconColor),
                        ),
                      ),
                    ),
                    if (!notification.isRead)
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: AppTheme.primaryAccent,
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  notification.message,
                  style: TextStyle(
                    fontSize: 14,
                    color: notification.isRead ? Colors.grey.shade600 : Colors.black87,
                    height: 1.4,
                  ),
                ),
                if (notification.actionLabel != null) ...[
                  const SizedBox(height: 12),
                  InkWell(
                    onTap: () {
                      // Navigate or perform action
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryAccent.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        notification.actionLabel!,
                        style: TextStyle(
                          color: AppTheme.primaryAccent,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.bottomRight,
                  child: Text(
                    timeago.format(notification.timestamp),
                    style: TextStyle(
                      fontSize: 12,
                      color: notification.isRead ? Colors.grey.shade500 : Colors.black45,
                      fontWeight: notification.isRead ? FontWeight.normal : FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
