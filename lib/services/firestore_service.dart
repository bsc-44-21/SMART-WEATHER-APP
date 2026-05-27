import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/plot.dart';
import '../models/activity_log.dart';
import '../models/pest_detection.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Save a plot to Firestore
  Future<void> savePlot(PlotModel plot) async {
    try {
      await _db.collection('plots').doc(plot.id).set(plot.toMap());
    } catch (e) {
      rethrow;
    }
  }
  // Update an existing plot in Firestore
  Future<void> updatePlot(PlotModel plot) async {
    try {
      await _db.collection('plots').doc(plot.id).set(plot.toMap(), SetOptions(merge: true));
    } catch (e) {
      rethrow;
    }
  }
  // Get a real-time stream of plots for a specific user
  Stream<List<PlotModel>> getUserPlotsStream(String userId) {
    // We search both 'userId' (new) and 'user_id' (legacy) if needed, 
    // but primarily we should move to 'userId'.
    return _db
        .collection('plots')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
            .map((doc) => PlotModel.fromMap(doc.data(), doc.id))
            .toList();
        });
  }

  // Save or Update an activity log
  Future<void> saveActivityLog(ActivityLogModel log) async {
    try {
      await _db.collection('activity_logs').doc(log.id).set(log.toMap());
    } catch (e) {
      rethrow;
    }
  }

  // Delete an activity log
  Future<void> deleteActivityLog(String logId) async {
    try {
      await _db.collection('activity_logs').doc(logId).delete();
    } catch (e) {
      rethrow;
    }
  }

  // Get a real-time stream of activities for a specific user
  Stream<List<ActivityLogModel>> getUserActivitiesStream(String userId) {
    return _db
        .collection('activity_logs')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
          final docs = snapshot.docs
            .map((doc) => ActivityLogModel.fromMap(doc.data(), doc.id))
            .toList();
          
          // Sort client-side to avoid requiring a composite index in Firestore
          docs.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return docs;
        });
  }

  // Save a pest detection
  Future<void> savePestDetection(PestDetectionModel detection) async {
    try {
      await _db.collection('pest_detections').doc(detection.id).set(detection.toMap());
    } catch (e) {
      rethrow;
    }
  }

  // Get a stream of pest detections
  Stream<List<PestDetectionModel>> getUserPestDetectionsStream(String userId) {
    return _db
        .collection('pest_detections')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
          final docs = snapshot.docs
              .map((doc) => PestDetectionModel.fromMap(doc.data(), doc.id))
              .toList();
          
          docs.sort((a, b) => b.timestamp.compareTo(a.timestamp));
          return docs; // Newest first
        });
  }

  // Delete a pest detection
  Future<void> deletePestDetection(String detectionId) async {
    try {
      await _db.collection('pest_detections').doc(detectionId).delete();
    } catch (e) {
      rethrow;
    }
  }

  // Delete a plot
  Future<void> deletePlot(String plotId) async {
     try {
      await _db.collection('plots').doc(plotId).delete();
    } catch (e) {
      rethrow;
    }
  }

  // Save generated advice in Firestore
  Future<void> saveAdvice(String userId, Map<String, dynamic> advice) async {
    try {
      await _db.collection('advice').add({
        'userId': userId,
        'activity': advice['activity'] ?? '',
        'weather': advice['weather'] ?? {},
        'advice': advice['advice'] ?? '',
        'explanation': advice['explanation'] ?? '',
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      rethrow;
    }
  }

  // --- Freemium User Profile ---
  Future<void> createUserProfileIfNotExists(String userId) async {
    final docRef = _db.collection('users').doc(userId);
    final docSnap = await docRef.get();
    if (!docSnap.exists) {
      await docRef.set({
        'isPremium': false,
        'aiQueriesToday': 0,
        'lastAiQueryDate': FieldValue.serverTimestamp(),
        'pestScansThisMonth': 0,
        'lastPestScanDate': FieldValue.serverTimestamp(),
      });
    }
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>> getUserProfileStream(String userId) {
    return _db.collection('users').doc(userId).snapshots();
  }

  Future<void> updateUserSubscription(String userId, bool isPremium) async {
    await _db.collection('users').doc(userId).set({
      'isPremium': isPremium,
    }, SetOptions(merge: true));
  }

  Future<void> updateAIUsage(String userId, int count, DateTime date) async {
    await _db.collection('users').doc(userId).set({
      'aiQueriesToday': count,
      'lastAiQueryDate': date,
    }, SetOptions(merge: true));
  }

  Future<void> updatePestScanUsage(String userId, int count, DateTime date) async {
    await _db.collection('users').doc(userId).set({
      'pestScansThisMonth': count,
      'lastPestScanDate': date,
    }, SetOptions(merge: true));
  }
}
