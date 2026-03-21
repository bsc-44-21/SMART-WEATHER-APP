import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/plot.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Save a plot to Firestore
  Future<void> savePlot(PlotModel plot) async {
    try {
      await _db.collection('plots').doc(plot.id).set(plot.toMap());
    } catch (e) {
      print('Error saving plot: $e');
      rethrow;
    }
  }