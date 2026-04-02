import 'package:http/http.dart' as http;
import 'dart:convert';
import '../core/ai_config.dart';
import '../models/plot.dart';

class OpenRouterAiService {
  static final OpenRouterAiService _instance = OpenRouterAiService._internal();

  factory OpenRouterAiService() {
    return _instance;
  }