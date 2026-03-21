import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../core/mock_data.dart';
import '../models/plot.dart';
import 'firestore_service.dart';
import 'package:intl/intl.dart';

class WeatherSmartService extends ChangeNotifier {
  List<PlotModel> _plots = [];
  final List<Map<String, dynamic>> _activities = List.from(MockData.activities);
  bool _isDarkMode = false;
  StreamSubscription? _plotsSubscription;

 WeatherSmartService() {
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      _plotsSubscription?.cancel();
      if (user != null) {
        _plotsSubscription = FirestoreService().getUserPlotsStream(user.uid).listen((plots) {
          _plots = plots;
          notifyListeners();
        });
      } else {
        _plots = [];
        notifyListeners();
      }
    });
  }

   List<PlotModel> get plots => _plots;
  List<Map<String, dynamic>> get logs => _activities;
  String get advice => MockData.farmingAdvice;
  bool get isDarkMode => _isDarkMode;

  void toggleDarkMode(bool value) {
    _isDarkMode = value;
    notifyListeners();
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

