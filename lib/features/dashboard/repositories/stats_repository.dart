import 'package:cloud_firestore/cloud_firestore.dart';

class StatsRepository {
  final FirebaseFirestore _firestore;
  final String userId;

  StatsRepository({required this.userId, FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _workouts =>
      _firestore.collection('users').doc(userId).collection('workouts');

  CollectionReference<Map<String, dynamic>> get _dietEntries =>
      _firestore.collection('users').doc(userId).collection('diet_entries');

  Future<int> getWorkoutsThisWeek() async {
    return 0;
  }

  Future<int> getCaloriesToday() async {
    return 0;
  }
}
