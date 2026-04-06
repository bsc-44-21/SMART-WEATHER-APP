import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firestore_service.dart';
import 'weather_location_service.dart';
import 'openrouter_ai_service.dart';
import 'package:intl/intl.dart';
import '../models/plot.dart';
import '../models/activity_log.dart';
import '../core/mock_data.dart';
import 'package:uuid/uuid.dart';

class WeatherSmartService extends ChangeNotifier {
  List<PlotModel> _plots = [];
  List<Map<String, dynamic>> _activities = [];
  bool _isDarkMode = false;
  StreamSubscription? _plotsSubscription;
  StreamSubscription? _logsSubscription;
  Timer? _weatherTimer;
  
  // Weather data
  Map<String, dynamic>? _currentWeather;
  final Map<String, Map<String, dynamic>> _plotWeather = {};
  bool _isLoadingWeather = false;
  String? _weatherError;
  
  // AI Advice data
  String _currentAdvice = '';
  bool _isGeneratingAdvice = false;
  final List<String> _previousAdvice = [];
  final int _maxPreviousAdviceCount = 5;

 WeatherSmartService() {
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      _plotsSubscription?.cancel();
      _logsSubscription?.cancel();
      _weatherTimer?.cancel();
      if (user != null) {
        // Plots Stream
        _plotsSubscription = FirestoreService().getUserPlotsStream(user.uid).listen((plots) {
          _plots = plots;
          fetchWeatherForPlots(); // Fetch weather for each plot
          notifyListeners();
        }, onError: (e) {
          print('[WeatherSmartService] Plots stream error: $e');
        });
        
        // Logs Stream
        _logsSubscription = FirestoreService().getUserActivitiesStream(user.uid).listen((logs) {
          _activities = logs.map((l) => l.toMap()).toList();
          notifyListeners();
        }, onError: (e) {
          print('[WeatherSmartService] Logs stream error: $e');
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
        _activities = [];
        _currentWeather = null;
        _plotWeather.clear();
        notifyListeners();
      }
    });
  }

  List<PlotModel> get plots => _plots;
  List<Map<String, dynamic>> get logs => _activities;
  String get advice => _currentAdvice.isNotEmpty ? _currentAdvice : MockData.farmingAdvice;
  String get currentAdvice => _currentAdvice;
  bool get isGeneratingAdvice => _isGeneratingAdvice;
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

  Future<void> addLog(String activity, {String? plot, String? date, bool? isRecommended, String? aiFeedback}) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final logId = const Uuid().v4();
    final newLog = ActivityLogModel(
      id: logId,
      userId: user.uid,
      plot: plot ?? 'General',
      title: activity,
      time: date ?? DateFormat('MMM d, yyyy').format(DateTime.now()),
      isRecommended: isRecommended,
      aiFeedback: aiFeedback,
      createdAt: DateTime.now(),
    );

    // Save to Firestore - the stream will update the local UI list
    await FirestoreService().saveActivityLog(newLog);
  }

  @override
  void dispose() {
    _plotsSubscription?.cancel();
    _logsSubscription?.cancel();
    _weatherTimer?.cancel();
    super.dispose();
  }
}
