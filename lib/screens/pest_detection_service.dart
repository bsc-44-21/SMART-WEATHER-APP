import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:http/http.dart' as http;
import '../core/secrets.dart';

class PestDetectionService {
  // Using a more reliable and tested model for plant diseases/pests
  static const String _modelId = "deniz/image-classification-plant-diseases";
  static const String _apiUrl = "https://api-inference.huggingface.co/models/$_modelId";

  static Future<String> detectPest(File imageFile) async {
    try {
      final bytes = await imageFile.readAsBytes();
      
      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: {
          "Authorization": "Bearer ${AppSecrets.huggingFaceKey}",
          "Content-Type": "application/octet-stream",
          // CRITICAL: Tells Hugging Face to wait for the model to load if it's cold