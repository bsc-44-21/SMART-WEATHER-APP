import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class WeatherLocationService {

  static Future<Position?> getLocationWithPermission() async {