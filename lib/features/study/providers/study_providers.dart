import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final subjectsProvider = StreamProvider<List<Map<String, dynamic>>>((ref) {
  return FirebaseFirestore.instance
      .collection('subjects') // 🔥 Firebase collection jahan saare subjects honge
      .snapshots()
      .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
});