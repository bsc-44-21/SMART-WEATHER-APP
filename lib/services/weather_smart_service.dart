import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../core/mock_data.dart';
import '../models/plot.dart';
import 'firestore_service.dart';
import 'weather_location_service.dart';
import 'package:intl/intl.dart';

class WeatherSmartService extends ChangeNotifier {
  List<PlotModel> _plots = [];
  final List<Map<String, dynamic>> _activities = List.from(MockData.activities);
  bool _isDarkMode = false;
  StreamSubscription? _plotsSubscription;
  
  // Weather data
  Map<String, dynamic>? _currentWeather;
  bool _isLoadingWeather = false;
  String? _weatherError;

 WeatherSmartService() {
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      _plotsSubscription?.cancel();
      if (user != null) {
        _plotsSubscription = FirestoreService().getUserPlotsStream(user.uid).listen((plots) {
          _plots = plots;
          notifyListeners();
        });
        // Fetch weather when user logs in
        fetchWeatherForLocation();
      } else {
        _plots = [];
        _currentWeather = null;
        notifyListeners();
      }
    });
  }

   List<PlotModel> get plots => _plots;
  List<Map<String, dynamic>> get logs => _activities;
  String get advice => MockData.farmingAdvice;
  bool get isDarkMode => _isDarkMode;
  Map<String, dynamic>? get currentWeather => _currentWeather;
  bool get isLoadingWeather => _isLoadingWeather;
  String? get weatherError => _weatherError;

  void toggleDarkMode(bool value) {
    _isDarkMode = value;
    notifyListeners();
  }

  // Fetch weather for current location
  Future<void> fetchWeatherForLocation() async {
    _isLoadingWeather = true;
    _weatherError = null;
    notifyListeners();

    try {
      print('[Weather] Starting weather fetch...');
      
      // Get location with permission
      final position = await WeatherLocationService.getLocationWithPermission();
      
      if (position == null) {
        _weatherError = 'Location permission denied. Enable location access in settings.';
        print('[Weather] Location permission denied');
        _isLoadingWeather = false;
        notifyListeners();
        return;
      }

      print('[Weather] Location obtained: ${position.latitude}, ${position.longitude}');

      // Fetch weather from Open-Meteo
      final weather = await WeatherLocationService.fetchWeather(
        position.latitude,
        position.longitude,
      );

      if (weather != null) {
        _currentWeather = weather;
        _weatherError = null;
        print('[Weather] Weather fetched successfully');
      } else {
        _weatherError = 'Failed to fetch weather. Check your internet connection.';
        print('[Weather] Weather data was null');
      }
    } catch (e) {
      _weatherError = 'Error: ${e.toString()}';
      print('[Weather] Exception: $e');
    } finally {
      _isLoadingWeather = false;
      notifyListeners();
    }
  }

  Future<void> addPlot(PlotModel plot) async {
    await FirestoreService().savePlot(plot);
  }

  Future<void> updatePlot(PlotModel plot) async {
    await FirestoreService().updatePlot(plot);
  }

  Future<void> deletePlot(String plotId) async {
    await FirestoreService().deletePlot(plotId);
  }

  void addLog(String activity) {
    _activities.insert(0, {
      'title': activity,
      'time': DateFormat('h:mm a').format(DateTime.now()),
    });
    notifyListeners();
  }
}

