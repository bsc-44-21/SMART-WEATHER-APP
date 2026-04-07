import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'core/theme.dart';
import 'screens/auth_screen.dart';
import 'screens/dashboard_screen.dart';
import 'services/weather_smart_service.dart';
import 'services/auth_service.dart';
import 'services/navigation_service.dart';
import 'services/notification_service.dart';
import 'services/firestore_service.dart';

import 'dart:io';

class MyHttpOverrides extends HttpOverrides{
  @override
  HttpClient createHttpClient(SecurityContext? context){
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port)=> true;
  }
}

void main() async {
  HttpOverrides.global = MyHttpOverrides();
  WidgetsFlutterBinding.ensureInitialized();
  tz.initializeTimeZones();
  await Firebase.initializeApp();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => WeatherSmartService()),
        ChangeNotifierProvider(create: (context) => AuthService()),
        ChangeNotifierProvider(create: (context) => NavigationService()),
        ChangeNotifierProvider(create: (context) => NotificationService()),
        Provider(create: (context) => FirestoreService()),
      ],
      child: const WeatherSmartApp(),
    ),
  );
}

class WeatherSmartApp extends StatelessWidget {
  const WeatherSmartApp({super.key});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = context.watch<WeatherSmartService>().isDarkMode;

    return MaterialApp(
      title: 'WeatherSmart',
      theme: AppTheme.theme,
      darkTheme: AppTheme.darkTheme,
      themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: const AuthWrapper(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthService>().user;

    if (user != null) {
      return MainLayout();
    } else {
      return AuthScreen();
    }
  }
}
