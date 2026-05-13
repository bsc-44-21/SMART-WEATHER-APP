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

 static Future<PaychanguResponse?> createPaymentSession({
    required String email,
    required String firstName,
    required String lastName,
    required double amount,
  }) async {
    final transactionRef = 'tx-${const Uuid().v4().substring(0, 8)}';
    
   
    try {
      developer.log('Initializing Paychangu payment for $email', name: 'PaychanguService');
      
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer ${AppSecrets.paychanguSecretKey}',
          'Content-Type': 'application/json',
        },
