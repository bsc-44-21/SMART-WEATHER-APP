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
  // Setters for Loading & Errors
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String? message) {
    _errorMessage = message;
    notifyListeners();
  }

  // Sign Up
  Future<bool> signUpWithEmailAndPassword(
    String email,
    String password,
    String name,
  ) async {
    _setLoading(true);
    _setError(null);
    try {
      UserCredential credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await credential.user?.updateDisplayName(name);

      _setLoading(false);
      return true;
    } on FirebaseAuthException catch (e) {
      _setLoading(false);
      _setError(_getFriendlyErrorMessage(e.code));
      return false;
    } catch (e) {
      _setLoading(false);
      _setError("Oops! Something went wrong on our end. Please check your connection and try again.");
      return false;
    }
  }

  // Sign In
  Future<bool> signInWithEmailAndPassword(String email, String password) async {
    _setLoading(true);
    _setError(null);
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      _setLoading(false);
      return true;
    } on FirebaseAuthException catch (e) {
      _setLoading(false);
      _setError(_getFriendlyErrorMessage(e.code));
      return false;
    } catch (e) {
      _setLoading(false);
      _setError("Oops! Something went wrong on our end. Please check your connection and try again.");
      return false;
    }
  }

  // Sign Out
  Future<void> signOut() async {
    _setLoading(true);
    try {
      await _auth.signOut();
    } finally {
      _setLoading(false);
    }
  }

  // Forgot Password
  Future<bool> sendPasswordResetEmail(String email) async {
    _setLoading(true);
    _setError(null);
    try {
      await _auth.sendPasswordResetEmail(email: email);
      _setLoading(false);
      return true;
    } on FirebaseAuthException catch (e) {
      _setLoading(false);
      _setError(_getFriendlyErrorMessage(e.code));
      return false;
    } catch (e) {
      _setLoading(false);
      _setError("We couldn't send the reset email. Please make sure you're connected and try again.");
      return false;
    }
  }

  // Map Firebase Errors to User-Friendly Strings
  String _getFriendlyErrorMessage(String code) {
    switch (code) {
      case 'user-not-found':
        return "We couldn't find a farmer account with that email.";
      case 'wrong-password':
        return "The password you entered is incorrect. Let's try again!";
      case 'invalid-email':
        return "Please check your email address. It doesn't look quite right.";
      case 'user-disabled':
        return "Your farm account has been temporarily disabled. Please contact support.";
      case 'email-already-in-use':
        return "An account with this email already exists. Try logging in instead.";
      case 'weak-password':
        return "Your password is a bit too weak. Try adding numbers or symbols for better security.";
      case 'invalid-credential':
        return "We couldn't log you in. Please check your email and password and try again.";
      default:
        return "Something went wrong while checking your details. Please try again.";
    }
  }
}
