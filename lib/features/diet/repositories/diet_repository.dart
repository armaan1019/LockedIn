import 'package:cloud_firestore/cloud_firestore.dart';

class DietRepository {
  final FirebaseFirestore _firestore;

  DietRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  
}
