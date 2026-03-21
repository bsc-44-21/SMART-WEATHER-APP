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
