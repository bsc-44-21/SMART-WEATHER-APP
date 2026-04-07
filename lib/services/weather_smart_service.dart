import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../core/mock_data.dart';
import '../models/plot.dart';
import 'firestore_service.dart';
import 'weather_location_service.dart';
import 'openrouter_ai_service.dart';
import 'package:intl/intl.dart';

class WeatherSmartService extends ChangeNotifier {
  List<PlotModel> _plots = [];
  final List<Map<String, dynamic>> _activities = List.from(MockData.activities);

  bool _isDarkMode = false;

  StreamSubscription? _plotsSubscription;
  Timer? _weatherTimer;

  // Weather
  Map<String, dynamic>? _currentWeather;
  final Map<String, Map<String, dynamic>> _plotWeather = {};
  bool _isLoadingWeather = false;
  String? _weatherError;

  // AI
  String _currentAdvice = '';
  bool _isGeneratingAdvice = false;
  final List<String> _previousAdvice = [];
  final int _maxPreviousAdviceCount = 5;

  // Control
  bool _isFetchingWeather = false;

  WeatherSmartService() {
    FirebaseAuth.instance.authStateChanges().listen((user) {
      _plotsSubscription?.cancel();
      _weatherTimer?.cancel();

      if (user != null) {
        _plotsSubscription = FirestoreService()
            .getUserPlotsStream(user.uid)
            .listen((plots) {
          _plots = plots;
          notifyListeners();
        });

        // ✅ ONLY fetch current location weather
        fetchWeatherForLocation();

        // ✅ Slow safe refresh (every 15 minutes)
        _weatherTimer = Timer.periodic(const Duration(minutes: 15), (_) {
          fetchWeatherForLocation();
        });
      } else {
        _plots = [];
        _currentWeather = null;
        _plotWeather.clear();
        notifyListeners();
      }
    });
  }

  // ================= GETTERS =================
  List<PlotModel> get plots => _plots;
  List<Map<String, dynamic>> get logs => _activities;

  String get advice =>
      _currentAdvice.isNotEmpty ? _currentAdvice : MockData.farmingAdvice;

  String get currentAdvice => _currentAdvice;
  bool get isGeneratingAdvice => _isGeneratingAdvice;
  bool get isDarkMode => _isDarkMode;

  Map<String, dynamic>? get currentWeather => _currentWeather;

  bool get isLoadingWeather => _isLoadingWeather;
  String? get weatherError => _weatherError;

  // ================= UI =================
  void toggleDarkMode(bool value) {
    _isDarkMode = value;
    notifyListeners();
  }

  // ================= WEATHER =================
  Future<void> fetchWeatherForLocation() async {
    if (_isFetchingWeather) return;

    _isFetchingWeather = true;
    _isLoadingWeather = true;
    notifyListeners();

    try {
      final position =
          await WeatherLocationService.getLocationWithPermission();

      if (position == null) {
        _weatherError = 'Location permission denied';
        return;
      }

      final weather = await WeatherLocationService.fetchWeather(
        position.latitude,
        position.longitude,
      );

      if (weather != null) {
        _currentWeather = weather;
        _weatherError = null;
      } else {
        _weatherError = 'Weather unavailable';
      }
    } catch (e) {
      _weatherError = 'Error: $e';
    } finally {
      _isFetchingWeather = false;
      _isLoadingWeather = false;
      notifyListeners();
    }
  }

  Future<void> fetchWeatherForPlots() async {
    if (_plots.isEmpty) return;

    await Future.wait(
      _plots.map((plot) => fetchWeatherForPlot(plot)),
    );
  }

  Future<void> fetchWeatherForPlot(PlotModel plot) async {
    if (plot.latitude.isEmpty || plot.longitude.isEmpty) return;

    try {
      final lat = double.parse(plot.latitude);
      final lon = double.parse(plot.longitude);

      final weather = await WeatherLocationService.fetchWeather(lat, lon);

      if (weather != null) {
        weather['fetched_at'] = DateTime.now().toIso8601String();
        _plotWeather[plot.id] = weather;
        notifyListeners();
      }
    } catch (e) {
      print('[Plot Weather Error]: $e');
    }
  }

  Map<String, dynamic>? getPlotWeather(String plotId) => _plotWeather[plotId];

  // ================= PLOTS =================
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

  // ================= LOGS =================
  void addLog(String activity, {String? plot, String? date}) {
    final entryDate =
        date ?? DateFormat('MMM d, yyyy').format(DateTime.now());

    _activities.insert(0, {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'title': activity,
      'plot': plot ?? 'General',
      'time': entryDate,
      'advice': '',
      'isGeneratingAdvice': true,
    });

    notifyListeners();
  }

  // ================= AI =================
  Future<void> askAIQuestion(String question) async {
    if (question.trim().isEmpty) return;

    _isGeneratingAdvice = true;
    notifyListeners();

    try {
      final answer =
          await OpenRouterAiService().generateCustomResponse(
        userPrompt: question,
      );

      _currentAdvice = answer;

      _previousAdvice.insert(0, answer);
      if (_previousAdvice.length > _maxPreviousAdviceCount) {
        _previousAdvice.removeLast();
      }
    } catch (e) {
      _currentAdvice = 'AI unavailable.';
    } finally {
      _isGeneratingAdvice = false;
      notifyListeners();
    }
  }

  // ================= CLEANUP =================
  @override
  void dispose() {
    _plotsSubscription?.cancel();
    _weatherTimer?.cancel();
    super.dispose();
  }
}