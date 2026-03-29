import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../models/plot.dart';
import 'firestore_service.dart';
import 'weather_location_service.dart';

class WeatherSmartService extends ChangeNotifier {

  // =====================================================
  // ===================== PLOTS =========================
  // =====================================================
  List<PlotModel> _plots = [];
  StreamSubscription? _plotsSubscription;

  List<PlotModel> get plots => _plots;

  // =====================================================
  // =================== DARK MODE =======================
  // =====================================================
  bool _isDarkMode = false;

  bool get isDarkMode => _isDarkMode;

  void toggleDarkMode(bool value) {
    _isDarkMode = value;
    notifyListeners();
  }

  // =====================================================
  // ================= ACTIVITY LOG ======================
  // =====================================================
  final List<Map<String, dynamic>> _activities = [];

  List<Map<String, dynamic>> get logs => _activities;

  // =====================================================
  // ==================== WEATHER ========================
  // =====================================================
  Map<String, dynamic>? _currentWeather;
  bool _isLoadingWeather = false;
  String? _weatherError;

  Map<String, dynamic>? get currentWeather => _currentWeather;
  bool get isLoadingWeather => _isLoadingWeather;
  String? get weatherError => _weatherError;

  // =====================================================
  // =================== AI ADVICE =======================
  // =====================================================
  String _advice = "Log an activity to receive AI farming advice.";
  bool _isGeneratingAdvice = false;

  String get advice => _advice;
  bool get isGeneratingAdvice => _isGeneratingAdvice;

  // =====================================================
  // ================== OPENROUTER =======================
  // =====================================================
  static const String _openRouterKey = "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";

  static const String _openRouterUrl =
      "https://openrouter.ai/api/v1/chat/completions";

  // =====================================================
  // ================== CONSTRUCTOR ======================
  // =====================================================
  WeatherSmartService() {
    FirebaseAuth.instance.authStateChanges().listen((user) {
      _plotsSubscription?.cancel();

      if (user != null) {
        _plotsSubscription =
            FirestoreService().getUserPlotsStream(user.uid).listen((plots) {
          _plots = plots;
          notifyListeners();
        });

        fetchWeatherForLocation();
      } else {
        _plots = [];
        _currentWeather = null;
        notifyListeners();
      }
    });
  }

  // =====================================================
  // ================= FETCH WEATHER =====================
  // =====================================================
  Future<void> fetchWeatherForLocation() async {
    _isLoadingWeather = true;
    notifyListeners();

    try {
      final position = await WeatherLocationService.getLocationWithPermission();

      if (position == null) {
        _weatherError = "Location permission denied";
        _isLoadingWeather = false;
        notifyListeners();
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
        _weatherError = "Failed to fetch weather";
      }
    } catch (e) {
      _weatherError = e.toString();
    }

    _isLoadingWeather = false;
    notifyListeners();
  }

  // =====================================================
  // ============ OPENROUTER AI FARMING ADVICE ===========
  // =====================================================
  Future<String> _generateAdvice({
    required String crop,
    required String activity,
    required double temperature,
    required double rainfall,
    required double humidity,
  }) async {

    final prompt = """
You are a smart farming assistant.

Crop: $crop
Farmer activity: $activity
Temperature: $temperature°C
Rainfall: $rainfall mm
Humidity: $humidity %

Give short and practical farming advice.
Use simple English.
Do not write long paragraphs.
Only tell the farmer what to do next.
""";

    try {
      final response = await http.post(
        Uri.parse(_openRouterUrl),
        headers: {
          "Authorization": "Bearer $_openRouterKey",
          "Content-Type": "application/json",
          "HTTP-Referer": "https://smartfarmingapp.com",
          "X-Title": "Smart Farming Weather App"
        },
        body: jsonEncode({
          "model": "openrouter/auto",
          "messages": [
            {"role": "user", "content": prompt}
          ],
          "temperature": 0.7
        }),
      ).timeout(const Duration(seconds: 25));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data["choices"][0]["message"]["content"];
      } else {
        return "AI service error (${response.statusCode})";
      }
    } catch (e) {
      return "Error connecting to AI service.";
    }
  }

  // =====================================================
  // ================= ADD ACTIVITY ======================
  // =====================================================
  Future<void> addLog(String activity) async {
    final time = DateFormat('h:mm a').format(DateTime.now());

    _activities.insert(0, {
      "title": activity,
      "time": time,
    });

    notifyListeners();

    // ================= Crop name =================
    final crop = _plots.isNotEmpty ? _plots[0].name : "maize";

    // ================= Weather data ==============
    double temperature = 25;
    double rainfall = 0;
    double humidity = 50;

    if (_currentWeather != null && _currentWeather!["current"] != null) {
      final current = _currentWeather!["current"];

      temperature =
          (current["temperature_2m"] as num?)?.toDouble() ?? 25;

      rainfall =
          (current["precipitation"] as num?)?.toDouble() ?? 0;

      humidity =
          (current["relative_humidity_2m"] as num?)?.toDouble() ?? 50;
    }

    // ================= Generate AI Advice ==========
    _isGeneratingAdvice = true;
    notifyListeners();

    final result = await _generateAdvice(
      crop: crop,
      activity: activity,
      temperature: temperature,
      rainfall: rainfall,
      humidity: humidity,
    );

    _advice = result;
    _isGeneratingAdvice = false;
    notifyListeners();

    // ================= Save to Firestore ==========
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      await FirestoreService().saveAdvice(user.uid, {
        "activity": activity,
        "crop": crop,
        "temperature": temperature,
        "rainfall": rainfall,
        "humidity": humidity,
        "advice": result,
        "createdAt": DateTime.now(),
      });
    }
  }

  // =====================================================
  // =================== PLOTS ===========================
  // =====================================================
  Future<void> addPlot(PlotModel plot) async {
    await FirestoreService().savePlot(plot);
  }

  Future<void> updatePlot(PlotModel plot) async {
    await FirestoreService().updatePlot(plot);
  }

  Future<void> deletePlot(String plotId) async {
    await FirestoreService().deletePlot(plotId);
  }
}