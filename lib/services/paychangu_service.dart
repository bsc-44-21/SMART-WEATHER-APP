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

  static Future<PaychanguResponse> createPaymentSession({
    required String email,
    required String firstName,
    required String lastName,
    required double amount,
  }) async {
    final transactionRef = 'tx-${const Uuid().v4().substring(0, 8)}';
    
    try {
      developer.log('Initializing Paychangu payment for $email', name: 'PaychanguService');
      developer.log('Using public key: ${AppSecrets.paychanguPublicKey.substring(0, 10)}...', name: 'PaychanguService');
      
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
      ).timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          throw Exception('Payment request timed out. Please check your internet connection.');
        },
      );

      developer.log('Paychangu Response Status: ${response.statusCode}', name: 'PaychanguService');
      developer.log('Paychangu Response Body: ${response.body}', name: 'PaychanguService');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        developer.log('Decoded response: $data', name: 'PaychanguService');
        
        if (data['status'] == 'success' && data['data'] != null) {
          final checkoutUrl = data['data']['checkout_url'];
          if (checkoutUrl != null && checkoutUrl.isNotEmpty) {
            return PaychanguResponse(
              checkoutUrl: checkoutUrl,
              txRef: transactionRef,
            );
          } else {
            throw Exception('No checkout URL received from payment gateway');
          }
        } else {
          final message = data['message'] ?? 'Payment initialization failed';
          throw Exception('Payment error: $message');
        }
      } else {
        final errorBody = response.body;
        developer.log('API Error: $errorBody', name: 'PaychanguService');
        throw Exception('Payment API error: ${response.statusCode} - $errorBody');
      }
    } catch (e) {
      developer.log('Paychangu Error: $e', name: 'PaychanguService', error: e);
      rethrow;
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
        
        if (paymentData != null) {
          final String paymentStatus = paymentData['status'].toString().toLowerCase();
          final dynamic amountPaid = paymentData['amount'];
          
          bool isPaid = paymentStatus == 'success';
          
          if (isPaid && expectedAmount != null) {
            double actualAmount = double.tryParse(amountPaid.toString()) ?? 0;
            // Allow for minor differences if any, but usually should match
            if (actualAmount < expectedAmount) {
              developer.log('Payment amount mismatch: Expected $expectedAmount, got $actualAmount', name: 'PaychanguService');
              return false;
            }
          }
          
          return isPaid;
        }
      }
      return false;
    } catch (e) {
      developer.log('Verify Error: $e', name: 'PaychanguService', error: e);
      return false;
    }
  }
}
