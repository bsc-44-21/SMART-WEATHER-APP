import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'core/theme.dart';
import 'screens/auth_screen.dart';
import 'services/weather_smart_service.dart';
import 'services/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => WeatherSmartService()),
        ChangeNotifierProvider(create: (context) => AuthService()),
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
      home: const AuthScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
