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
body: jsonEncode({
          'public_key': AppSecrets.paychanguPublicKey,
          'amount': amount,
          'currency': 'MWK',
          'email': email,
          'first_name': firstName,
          'last_name': lastName,
          'callback_url': 'https://smartweather.app/success',
          'return_url': 'https://smartweather.app/success',
          'tx_ref': transactionRef,
          'customization': {
            'title': 'Smart Weather Premium',
            'description': 'Payment for Premium Subscription',
          },
          'meta': {
            'uuid': const Uuid().v4(),
            'source': 'flutter_app'
          }
        }),
      );


      developer.log('Paychangu Response: ${response.statusCode} - ${response.body}', name: 'PaychanguService');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'success') {
          return PaychanguResponse(
            checkoutUrl: data['data']['checkout_url'],
            txRef: transactionRef,
          );
        }
      }
  
      return null;
    } catch (e) {
      developer.log('Paychangu Error: $e', name: 'PaychanguService', error: e);
      return null;
    }
  }

 static Future<bool> verifyTransaction(String txRef, {double? expectedAmount}) async {
    try {
      final response = await http.get(
        Uri.parse('$_verifyUrl/$txRef'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer ${AppSecrets.paychanguSecretKey}',
        },
      );
      developer.log('Verify Response: ${response.statusCode} - ${response.body}', name: 'PaychanguService');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        // IMPORTANT: Paychangu's top-level 'status' is the API request status.
        // The actual payment status is inside the 'data' object.
        final paymentData = data['data'];
        

     
