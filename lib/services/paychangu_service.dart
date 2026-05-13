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

