import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../widgets/common_widgets.dart';
import '../core/theme.dart';
import '../services/notification_service.dart';
import '../services/weather_smart_service.dart';
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
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(LucideIcons.arrowLeft),
                        onPressed: () => Navigator.pop(context),
                        color: AppTheme.primaryAccent,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Notifications',
                        style: Theme.of(context).textTheme.displayMedium?.copyWith(
                          color: AppTheme.primaryAccent,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -0.5,
                          fontSize: 32,
                        ),
                      ),
                    ],
                  ),
                  Consumer<NotificationService>(
                    builder: (context, notificationService, child) {
                      if (notificationService.unreadCount > 0) {
                        return TextButton.icon(
                          icon: const Icon(LucideIcons.checkCheck, size: 16),
                          label: const Text(
                            'Mark all read',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.5,
                            ),
                          ),
                          onPressed: () => notificationService.markAllAsRead(),
                          style: TextButton.styleFrom(
                            foregroundColor: AppTheme.primaryAccent.withOpacity(0.6),
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                          ),
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
                            Container(
                              padding: const EdgeInsets.all(32),
                              decoration: BoxDecoration(
                                color: AppTheme.primaryAccent.withOpacity(0.04),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                LucideIcons.bellRing,
                                size: 56,
                                color: AppTheme.primaryAccent.withOpacity(0.2),
                              ),
                            ),
                            const SizedBox(height: 24),
                            Text(
                              "You're all caught up!",
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: AppTheme.primaryAccent.withOpacity(0.8),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "Your farming schedule is perfectly on track.",
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppTheme.textMuted,
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

              const SizedBox(height: 16),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    Color stripColor;
    IconData icon;

    switch (notification.type) {
      case NotificationType.weather:
        stripColor = Colors.blue.shade400;
        icon = LucideIcons.cloudRain;
        break;
      case NotificationType.pest:
        stripColor = Colors.orange.shade400;
        icon = LucideIcons.bug;
        break;
      case NotificationType.tip:
        stripColor = AppTheme.primaryAccent;
        icon = LucideIcons.leaf;
        break;
      case NotificationType.success:
        stripColor = Colors.green.shade400;
        icon = LucideIcons.checkCircle;
        break;
      case NotificationType.system:
      default:
        stripColor = Colors.grey.shade400;
        icon = LucideIcons.info;
        break;
    }

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppTheme.primaryAccent.withOpacity(isDark ? 0.2 : 0.08),
          width: 1,
        ),
        boxShadow: notification.isRead
            ? []
            : [
                BoxShadow(
                  color: (isDark ? Colors.black : AppTheme.primaryAccent).withOpacity(0.04),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
      ),
      clipBehavior: Clip.antiAlias,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Status Strip
            Container(
              width: 6,
              color: notification.isRead ? stripColor.withOpacity(0.3) : stripColor,
            ),
            
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          icon, 
                          size: 16, 
                          color: notification.isRead ? AppTheme.textMuted : stripColor,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            notification.title,
                            style: TextStyle(
                              fontWeight: notification.isRead ? FontWeight.w600 : FontWeight.w800,
                              fontSize: 14,
                              color: notification.isRead ? AppTheme.textMuted : AppTheme.textPrimary,
                            ),
                          ),
                        ),
                        if (!notification.isRead)
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: Colors.redAccent,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      notification.message,
                      style: TextStyle(
                        fontSize: 13,
                        color: notification.isRead ? AppTheme.textMuted : AppTheme.textPrimary.withOpacity(0.8),
                        height: 1.5,
                      ),
                    ),
                    
                    // Smart Advisory Section
                    if (notification.isAnalyzing) ...[
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          const SizedBox(
                            width: 12,
                            height: 12,
                            child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.primaryAccent),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'AI is analyzing weather safety...',
                            style: TextStyle(
                              fontSize: 11,
                              fontStyle: FontStyle.italic,
                              color: AppTheme.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ] else if (notification.aiAdvice != null) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: stripColor.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: stripColor.withOpacity(0.1)),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(LucideIcons.lightbulb, size: 14, color: stripColor),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                notification.aiAdvice!,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  fontStyle: FontStyle.italic,
                                  color: stripColor.withOpacity(0.8),
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                    
                    // Action Buttons for Milestones
                    if (notification.isActionable && !notification.isRead) ...[
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          ElevatedButton(
                            onPressed: () async {
                              final weatherService = context.read<WeatherSmartService>();
                              await weatherService.addLog(
                                notification.activityTitle ?? notification.title,
                                plot: notification.relatedPlotId,
                                aiFeedback: 'Completed on time.',
                              );
                              
                              if (context.mounted) {
                                context.read<NotificationService>().removeNotification(notification.id);
                                
                                final plotIdx = weatherService.plots.indexWhere((p) => p.id == notification.relatedPlotId);
                                if (plotIdx != -1) {
                                  context.read<NotificationService>().schedulePlotMilestones(weatherService.plots[plotIdx], weatherService.logs);
                                }
                                
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Activity tracked and logged!'))
                                );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryAccent,
                              foregroundColor: Colors.white,
                              minimumSize: const Size(120, 40),
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              elevation: 0,
                            ),
                            child: const Text(
                              'I Did This', 
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(width: 8),
                          TextButton(
                            onPressed: () async {
                              final weatherService = context.read<WeatherSmartService>();
                              await weatherService.addLog(
                                notification.activityTitle ?? notification.title,
                                plot: notification.relatedPlotId,
                                aiFeedback: 'Skipped by user.',
                              );
                              
                              if (context.mounted) {
                                context.read<NotificationService>().removeNotification(notification.id);
                                
                                final plotIdx = weatherService.plots.indexWhere((p) => p.id == notification.relatedPlotId);
                                if (plotIdx != -1) {
                                  context.read<NotificationService>().schedulePlotMilestones(weatherService.plots[plotIdx], weatherService.logs);
                                }
                              }
                            },
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.red.shade400,
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            ),
                            child: const Text(
                              'Skip', 
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                            ),
                          ),
                        ],
                      ),
                    ],

                    // Standard Action Label (if any)
                    if (notification.actionLabel != null && !notification.isActionable) ...[
                      const SizedBox(height: 12),
                      InkWell(
                        onTap: () {
                          // Generic action handler
                        },
                        child: Text(
                          notification.actionLabel!,
                          style: TextStyle(
                            color: AppTheme.primaryAccent,
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                    
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          timeago.format(notification.timestamp),
                          style: TextStyle(
                            fontSize: 11,
                            color: AppTheme.textMuted.withOpacity(0.6),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

