import 'dart:async';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/common_widgets.dart';
import '../core/theme.dart';
import '../services/weather_smart_service.dart';
import '../services/weather_location_service.dart';
import '../services/navigation_service.dart';
import '../services/notification_service.dart';
import '../widgets/create_plot_sheet.dart';
import 'notifications_page.dart';
import 'log_page.dart';
import 'detect_page.dart';
import '../models/notification_model.dart';
import 'package:url_launcher/url_launcher.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning,';
    if (hour < 17) return 'Good Afternoon,';
    return 'Good Evening,';
  }

  @override
  Widget build(BuildContext context) {
    final weatherService = context.watch<WeatherSmartService>();
    final plots = weatherService.plots;
    final currentWeather = weatherService.currentWeather;

    final user = FirebaseAuth.instance.currentUser;
    final username = user?.displayName ?? user?.email?.split('@')[0] ?? 'Farmer';

    // Calculate total area
    double totalArea = 0;
    for (var plot in plots) {
      totalArea += double.tryParse(plot.fieldSize) ?? 0;
    }

    final colorScheme = Theme.of(context).colorScheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Welcome & Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _getGreeting(),
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.9),
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    username,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -1,
                    ),
                  ),
                ],
              ),
              Consumer<NotificationService>(
                builder: (context, notificationService, child) {
                  final unreadCount = notificationService.unreadCount;
                  return Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: colorScheme.surface,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.03),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: IconButton(
                          icon: const Icon(LucideIcons.bell),
                          color: colorScheme.primary,
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const NotificationsPage(),
                              ),
                            );
                          },
                        ),
                      ),
                      if (unreadCount > 0)
                        Positioned(
                          right: -2,
                          top: -2,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Colors.redAccent,
                              shape: BoxShape.circle,
                            ),
                            constraints: const BoxConstraints(
                              minWidth: 16,
                              minHeight: 16,
                            ),
                            child: Text(
                              '$unreadCount',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
            ],
          ),

          const SizedBox(height: 32),

          // 2. Banner Ads (replaces the Local Weather section)
          // Place your banner images under `assets/banners/` and update
          // `pubspec.yaml` to include them. This widget will gracefully
          // fall back to a placeholder if an asset isn't found.
          _buildBannerAds(context),
          const SizedBox(height: 24),

          // 3. Farm Analytics
          Row(
            children: [
              Expanded(
                child: _buildAnalyticCard(
                  context,
                  title: 'Total Plots',
                  value: '${plots.length}',
                  icon: LucideIcons.map,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildAnalyticCard(
                  context,
                  title: 'Total Area',
                  value: '${totalArea.toStringAsFixed(1)} Ha',
                  icon: LucideIcons.maximize,
                ),
              ),
            ],
          ),

          const SizedBox(height: 32),

          // 4. Quick Actions
          Text(
            'Quick Actions',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppTheme.primaryAccent,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 16),
          _buildQuickAction(
            context,
            icon: LucideIcons.plus,
            title: 'Add New Plot',
            subtitle: 'Register a new field',
            onTap: () => showCreatePlotBottomSheet(context),
          ),
          const SizedBox(height: 12),
          _buildQuickAction(
            context,
            icon: LucideIcons.camera,
            title: 'Detect',
            subtitle: 'Scan field for pests',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const DetectPage()),
              );
            },
          ),
          const SizedBox(height: 12),
          _buildQuickAction(
            context,
            icon: LucideIcons.clipboardList,
            title: 'Log Activity',
            subtitle: 'Record farm tasks & events',
            onTap: () => showFullActivityLogSheet(context, initialFilter: 'All'),
          ),

          const SizedBox(height: 32),

          // 5. Recent Notifications
          Builder(builder: (context) {
            final notifications = context.watch<NotificationService>().notifications;
            final recentNotifs = notifications.take(3).toList();
          if (recentNotifs.isEmpty) return const SizedBox.shrink();
            
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Recent Notifications',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 16),
                ...recentNotifs.map((notif) => Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: FarmingCard(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: colorScheme.primary.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            notif.type == NotificationType.weather || notif.type == NotificationType.pest || notif.type == NotificationType.system ? LucideIcons.alertTriangle : LucideIcons.bell, 
                            size: 16, 
                            color: colorScheme.primary,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                notif.title,
                                style: GoogleFonts.inter(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                notif.message,
                                style: GoogleFonts.inter(
                                  color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.9),
                                  fontSize: 11,
                                  height: 1.4,
                                ),
                              ),
                              if (notif.aiAdvice != null && notif.aiAdvice!.isNotEmpty) ...[
                                const SizedBox(height: 12),
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: AppTheme.terracotta.withOpacity(0.08),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: AppTheme.terracotta.withOpacity(0.15)),
                                  ),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Icon(LucideIcons.sparkles, size: 14, color: AppTheme.terracotta),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          notif.aiAdvice!,
                                          style: GoogleFonts.inter(
                                            color: AppTheme.terracotta,
                                            fontSize: 11,
                                            height: 1.4,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ] else if (notif.isAnalyzing) ...[
                                const SizedBox(height: 8),
                                Text(
                                  'Getting AI advice...',
                                  style: GoogleFonts.inter(
                                    color: Colors.grey,
                                    fontSize: 10,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ]
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                )),
              ],
            );
          }),
          
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildLocalWeatherCard(BuildContext context, Map<String, dynamic> weather, {Key? key}) {
    final current = weather['current'];
    if (current == null) return SizedBox.shrink(key: key);

    final temp = current['temperature_2m'];
    final weatherCode = current['weather_code'];
    final emoji = WeatherLocationService.getWeatherEmoji(weatherCode);
    final desc = WeatherLocationService.getWeatherDescription(weatherCode);

    return FarmingCard(
      key: key,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [colorScheme.primary, const Color(0xFF1B3F1A)], // Lush Green to Deep Green
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Local Weather',
                      style: GoogleFonts.inter(
                        color: Theme.of(context).colorScheme.onPrimary.withOpacity(0.9),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '$temp°',
                          style: GoogleFonts.inter(
                            color: Theme.of(context).colorScheme.onPrimary,
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                            height: 1.0,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Text(
                            desc,
                            style: GoogleFonts.inter(
                              color: Theme.of(context).colorScheme.onPrimary.withOpacity(0.85),
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Text(
                emoji,
                style: const TextStyle(fontSize: 48),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWeatherErrorCard(BuildContext context, {required String error, required VoidCallback onRetry}) {
    return FarmingCard(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.grey.shade800, Colors.grey.shade900],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
                BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
                Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(LucideIcons.cloudOff, color: Theme.of(context).colorScheme.onPrimary, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Weather Offline',
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onPrimary,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      error,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.onPrimary.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              icon: const Icon(LucideIcons.refreshCw, size: 16),
              label: const Text('Try Refreshing'),
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.surface,
                foregroundColor: Theme.of(context).textTheme.bodyLarge?.color,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalyticCard(BuildContext context, {required String title, required String value, required IconData icon}) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: colorScheme.primary.withOpacity(0.08)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: colorScheme.primary.withOpacity(0.5), size: 20),
          const SizedBox(height: 12),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
              style: GoogleFonts.inter(
                color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.9),
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAction(BuildContext context, {required IconData icon, required String title, required String subtitle, required VoidCallback onTap}) {
    final colorScheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: colorScheme.primary.withOpacity(0.08)),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4)),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colorScheme.primary.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: colorScheme.primary, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w700,
                      color: colorScheme.primary,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: GoogleFonts.inter(
                      color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.9),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            Icon(LucideIcons.chevronRight, color: Theme.of(context).dividerColor, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildBannerAds(BuildContext context) {
    final weatherService = context.watch<WeatherSmartService>();
    final current = weatherService.currentWeather;
    final currentNow = current != null ? current['current'] as Map<String, dynamic>? : null;

    // If we don't have weather yet, attempt a fetch (use microtask to avoid calling during build sync)
    if (currentNow == null && !weatherService.isLoadingWeather) {
      Future.microtask(() => weatherService.fetchWeatherForLocation());
    }

    // Build a list of widgets: first one is a dynamic weather banner, followed by image banners
    final List<Widget> banners = [];

    // Weather banner (first)
    banners.add(
      ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppTheme.primaryAccent, AppTheme.terracotta.withValues(alpha: 0.15)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          padding: const EdgeInsets.all(16),
          child: currentNow != null
              ? Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Local Weather', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.white70)),
                          const SizedBox(height: 6),
                          Text(
                            '${currentNow['temperature_2m'] ?? '-'}°',
                            style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            WeatherLocationService.getWeatherDescription(currentNow['weather_code'] ?? 0),
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white70),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      WeatherLocationService.getWeatherEmoji(currentNow['weather_code'] ?? 0),
                      style: const TextStyle(fontSize: 48),
                    ),
                  ],
                )
              : Center(
                  child: Text(
                    'Weather unavailable. Turn on location or data.',
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                ),
        ),
      ),
    );

    // Add existing asset banners after the weather banner
    final List<String> assetBanners = [
      'assets/banners/banner1.png',
      'assets/banners/banner2.png',
      'assets/banners/banner3.png',
    ];

    for (final path in assetBanners) {
      banners.add(
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Container(
            color: Colors.grey.shade200,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.asset(
                  path,
                  fit: BoxFit.cover,
                  errorBuilder: (ctx, error, stack) => Container(
                    color: Colors.grey.shade300,
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(LucideIcons.image, size: 36, color: Colors.grey.shade600),
                          const SizedBox(height: 8),
                          Text('Add ${path.split('/').last} to assets', style: GoogleFonts.inter(color: Colors.grey.shade600, fontSize: 12)),
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'SPONSORED',
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
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

    return SizedBox(
      height: 180,
      child: BannerCarousel(items: banners),
    );
  }

}

class BannerCarousel extends StatefulWidget {
  final List<Widget> items;
  final Duration interval;
  const BannerCarousel({super.key, required this.items, this.interval = const Duration(seconds: 8)});

  @override
  State<BannerCarousel> createState() => _BannerCarouselState();
}

class _BannerCarouselState extends State<BannerCarousel> {
  late final PageController _controller;
  Timer? _timer;
  int _current = 0;

  @override
  void initState() {
    super.initState();
    _controller = PageController(initialPage: 0);
    if (widget.items.length > 1) {
      _timer = Timer.periodic(widget.interval, (_) {
        final next = (_current + 1) % widget.items.length;
        if (mounted) {
          _controller.animateToPage(next, duration: const Duration(milliseconds: 1000), curve: Curves.easeInOut);
        }
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: PageView.builder(
            controller: _controller,
            itemCount: widget.items.length,
            onPageChanged: (p) => setState(() => _current = p),
            itemBuilder: (context, index) {
              return widget.items[index];
            },
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(widget.items.length, (i) {
            final bool active = i == _current;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: active ? 18 : 8,
              height: 8,
              decoration: BoxDecoration(
                color: active ? AppTheme.primaryAccent : Colors.grey.shade400,
                borderRadius: BorderRadius.circular(8),
              ),
            );
          }),
        ),
      ],
    );
  }
}
