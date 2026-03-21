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