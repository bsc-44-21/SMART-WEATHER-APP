import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
class AuthService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
    // State
  User? _user;
  bool _isLoading = false;
  String? _errorMessage;
    // Getters
  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
    AuthService() {
    _auth.authStateChanges().listen((User? user) {
      _user = user;
      notifyListeners();
    });
  }