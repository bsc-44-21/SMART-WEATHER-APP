import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
class AuthService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;