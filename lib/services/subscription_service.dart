import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firestore_service.dart';
import '../models/user_profile.dart';

class SubscriptionService extends ChangeNotifier {
  UserProfile? _userProfile;
  StreamSubscription? _profileSub;
    
  // Rate Limits
  static const int maxFreePlots = 1;
  static const int maxFreeAiQueriesToday = 3;
  static const int maxFreePestScansMonth = 3;

  SubscriptionService() {
    FirebaseAuth.instance.authStateChanges().listen((user) {
      _profileSub?.cancel();
      if (user != null) {
        // Ensure profile exists
        FirestoreService().createUserProfileIfNotExists(user.uid).then((_) {
          _profileSub = FirestoreService().getUserProfileStream(user.uid).listen((docSnap) {
            if (docSnap.exists) {
              _userProfile = UserProfile.fromMap(docSnap.data()!, docSnap.id);
              notifyListeners();
            }
          });
        });
      } else {
        _userProfile = null;
        notifyListeners();
      }
    });
  }
