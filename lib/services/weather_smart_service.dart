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

  void addLog(String activity, {String? plot, String? date}) {
    final entryDate = date ?? DateFormat('MMM d, yyyy').format(DateTime.now());
    final logId = 'log_${DateTime.now().millisecondsSinceEpoch}';

    _activities.insert(0, {
      'id': logId,
      'title': activity,
      'plot': plot ?? 'General',
      'time': entryDate,
      'advice': '',
      'isGeneratingAdvice': true, // Add generating flag
    });
    
    // Generate AI advice for this activity
    _generateAdviceForActivity(
      activity: activity,
      plotName: plot ?? 'General',
      date: entryDate,
      logId: logId,
    );
    
    notifyListeners();
  }

  /// Generate farming advice using OpenRouter AI based on the logged activity
  Future<void> _generateAdviceForActivity({
    required String activity,
    required String plotName,
    required String date,
    required String logId,
  }) async {
    print('[WeatherSmartService] _generateAdviceForActivity: activity=$activity plot=$plotName date=$date logId=$logId');
    _isGeneratingAdvice = true;
    notifyListeners();

    try {
      // Find the plot to get crop name and weather data
      String cropName = 'Unknown Crop';
      Map<String, dynamic>? plotWeather;
      
      if (plotName != 'General') {
        try {
          final selectedPlot = _plots.firstWhere((p) => p.name == plotName);
          cropName = selectedPlot.cropName.isNotEmpty ? selectedPlot.cropName : 'Unknown Crop';
          plotWeather = _plotWeather[selectedPlot.id] ?? _currentWeather;
        } catch (e) {
          // Plot not found, use current location weather
          cropName = 'Unknown Crop';
          plotWeather = _currentWeather;
        }
      } else {
        plotWeather = _currentWeather;
      }

      // Validate supported crops before proceeding
      const supportedCrops = ['tomato', 'maize', 'groundnut'];
      final cropLower = cropName.toLowerCase().trim();
      print('[WeatherSmartService] Crop validation: cropName="$cropName" (lowercased="$cropLower") supported=$supportedCrops');
      
      if (!supportedCrops.contains(cropLower)) {
        final errorMsg = 'AI advice only available for tomato, maize, or groundnut. Your crop: "$cropName"';
        print('[WeatherSmartService] Crop validation FAILED: $errorMsg');
        _currentAdvice = errorMsg;
        _setLogAdvice(logId, errorMsg);
        return;
      }
      
      if (plotWeather == null) {
        print('[WeatherSmartService] WARNING: plotWeather is null, using default');
        plotWeather = {};
      }
      
      print('[WeatherSmartService] Crop validation passed. Calling AI with crop=$cropName activity=$activity');
      
      // Generate advice using OpenRouter AI
      final advice = await OpenRouterAiService().generateFarmingAdvice(
        activity: activity,
        plotName: plotName,
        cropName: cropName,
        date: date,
        weatherData: plotWeather,
        previousAdvice: _previousAdvice,
      );

      _currentAdvice = advice;
      
      // Store in previous advice list for context in next requests
      _previousAdvice.insert(0, advice);
      if (_previousAdvice.length > _maxPreviousAdviceCount) {
        _previousAdvice.removeLast();
      }
      
      // TODO: Store advice in Firestore for later retrieval
      // await FirestoreService().saveActivityAdvice(userId, activity, advice, date);
      
      print('[WeatherSmartService] Generated advice: $advice');
      _setLogAdvice(logId, advice);
    } catch (e) {
      final errorMsg = 'Error: ${e.toString()}';
      _currentAdvice = errorMsg;
      _setLogAdvice(logId, errorMsg);
      print('[WeatherSmartService] ERROR generating advice: $e');
    } finally {
      _isGeneratingAdvice = false;
      notifyListeners();
    }
  }

  void _setLogAdvice(String logId, String advice) {
    final idx = _activities.indexWhere((log) => log['id'] == logId);
    if (idx != -1) {
      _activities[idx]['advice'] = advice;
      _activities[idx]['isGeneratingAdvice'] = false; // Mark as done
      notifyListeners();
    }
  }

  /// Ask the AI a custom user question and store the answer
  Future<void> askAIQuestion(String question) async {
    print('[WeatherSmartService] askAIQuestion called with: $question');
    if (question.trim().isEmpty) {
      _currentAdvice = 'Please enter a question.';
      notifyListeners();
      return;
    }

    _isGeneratingAdvice = true;
    notifyListeners();

    try {
      print('[WeatherSmartService] Calling OpenRouterAiService.generateCustomResponse');
      final answer = await OpenRouterAiService().generateCustomResponse(userPrompt: question);
      print('[WeatherSmartService] Received answer: $answer');
      _currentAdvice = answer;

      // keep history
      _previousAdvice.insert(0, answer);
      if (_previousAdvice.length > _maxPreviousAdviceCount) {
        _previousAdvice.removeLast();
      }
    } catch (e) {
      _currentAdvice = 'Unable to generate AI response. Please try again later.';
      print('[WeatherSmartService] askAIQuestion error: $e');
    } finally {
      _isGeneratingAdvice = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _plotsSubscription?.cancel();
    _weatherTimer?.cancel();
    super.dispose();
  }
}
