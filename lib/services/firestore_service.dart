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
      await _db.collection('plots').doc(plot.id).update(plot.toMap());
    } catch (e) {
      rethrow;
    }
  }
  // Get a real-time stream of plots for a specific user
  Stream<List<PlotModel>> getUserPlotsStream(String userId) {
    // Handling both legacy 'userId' and new 'user_id'
    return _db
        .collection('plots')
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
            .map((doc) => PlotModel.fromMap(doc.data(), doc.id))
            .where((plot) => plot.userId == userId)
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
}