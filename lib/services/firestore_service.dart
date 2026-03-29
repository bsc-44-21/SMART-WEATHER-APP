import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/plot.dart';

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