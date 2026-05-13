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
  bool get isPremium => _userProfile?.isPremium ?? false;

  // AI Advisory
  bool canQueryAI() {
    if (isPremium) return true;
    if (_userProfile == null) return false;

    // Reset daily counter if it's a new day
    final now = DateTime.now();
    if (_userProfile!.lastAiQueryDate.day != now.day ||
        _userProfile!.lastAiQueryDate.month != now.month ||
        _userProfile!.lastAiQueryDate.year != now.year) {
      return true; // Counter will be reset to 1
    }

    return _userProfile!.aiQueriesToday < maxFreeAiQueriesToday;
  }

  Future<void> incrementAIQuery() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || isPremium || _userProfile == null) return;

    final now = DateTime.now();
    int newCount = _userProfile!.aiQueriesToday + 1;

    // If it is a new day, reset counter to 1
    if (_userProfile!.lastAiQueryDate.day != now.day ||
        _userProfile!.lastAiQueryDate.month != now.month ||
        _userProfile!.lastAiQueryDate.year != now.year) {
      newCount = 1;
    }
    await FirestoreService().updateAIUsage(user.uid, newCount, now);
  }

  // Pest Detection
  bool canScanPest() {
    if (isPremium) return true;
    if (_userProfile == null) return false;

    final now = DateTime.now();
    // Reset if it's a new month
    if (_userProfile!.lastPestScanDate.month != now.month ||
        _userProfile!.lastPestScanDate.year != now.year) {
      return true;
    }
return _userProfile!.pestScansThisMonth < maxFreePestScansMonth;
  }

  Future<void> incrementPestScan() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || isPremium || _userProfile == null) return;

