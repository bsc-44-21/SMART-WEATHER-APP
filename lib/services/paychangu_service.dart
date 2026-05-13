import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/secrets.dart';
import 'package:uuid/uuid.dart';
import 'dart:developer' as developer;

class PaychanguResponse {
  final String? checkoutUrl;
  final String txRef;

  PaychanguResponse({this.checkoutUrl, required this.txRef});
}

class PaychanguService {
  static const String _baseUrl = 'https://api.paychangu.com/payment';
  static const String _verifyUrl = 'https://api.paychangu.com/verify-payment';

