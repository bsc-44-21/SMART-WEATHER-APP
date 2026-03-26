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
  Timer? _weatherTimer;
  
  // Weather data
  Map<String, dynamic>? _currentWeather;
  final Map<String, Map<String, dynamic>> _plotWeather = {};
  bool _isLoadingWeather = false;
  String? _weatherError;

 WeatherSmartService() {
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      _plotsSubscription?.cancel();
      _weatherTimer?.cancel();
      if (user != null) {
        _plotsSubscription = FirestoreService().getUserPlotsStream(user.uid).listen((plots) {
          _plots = plots;
          fetchWeatherForPlots(); // Fetch weather for each plot
          notifyListeners();
        });
        
        // Start periodic refresh every minute
        _weatherTimer = Timer.periodic(const Duration(minutes: 1), (_) {
          fetchWeatherForPlots();
          fetchWeatherForLocation();
        });

        // Fetch weather when user logs in
        fetchWeatherForLocation();
      } else {
        _plots = [];
        _currentWeather = null;
        _plotWeather.clear();
        notifyListeners();
      }
    });
  }

   List<PlotModel> get plots => _plots;
  List<Map<String, dynamic>> get logs => _activities;
  String get advice => MockData.farmingAdvice;
  bool get isDarkMode => _isDarkMode;
  Map<String, dynamic>? get currentWeather => _currentWeather;
  Map<String, dynamic>? getPlotWeather(String plotId) => _plotWeather[plotId];
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

  Future<void> fetchWeatherForPlots() async {
    for (var plot in _plots) {
      await fetchWeatherForPlot(plot);
    }
  }

  Future<void> fetchWeatherForPlot(PlotModel plot) async {
    if (plot.latitude.isNotEmpty && plot.longitude.isNotEmpty) {
      try {
        final lat = double.parse(plot.latitude);
        final lng = double.parse(plot.longitude);
        final weather = await WeatherLocationService.fetchWeather(lat, lng);
        if (weather != null) {
          weather['fetched_at'] = DateTime.now().toIso8601String();
          _plotWeather[plot.id] = weather;
          notifyListeners();
        }
      } catch (e) {
        print('[WeatherSmartService] Error fetching weather for plot ${plot.id}: $e');
      }
    }
  }

  Future<void> addPlot(PlotModel plot) async {
    await FirestoreService().savePlot(plot);
    await fetchWeatherForPlot(plot);
  }

  Future<void> updatePlot(PlotModel plot) async {
    await FirestoreService().updatePlot(plot);
    await fetchWeatherForPlot(plot);
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

  @override
  void dispose() {
    _plotsSubscription?.cancel();
    _weatherTimer?.cancel();
    super.dispose();
  }
}

