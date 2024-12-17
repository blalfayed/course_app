// ignore_for_file: avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DpFirebase {
  Future<void> addToFavorites(String itemId, String itemName) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('favorites')
          .doc(itemId)
          .set({
        'itemId': itemId,
        'itemName': itemName,
        'addedAt': FieldValue.serverTimestamp(),
      });
      print('Item added to favorites.');
    } else {
      print('User not logged in.');
    }
  }

  Stream<List<Map<String, dynamic>>> getFavorites() {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      return FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('favorites')
          .snapshots()
          .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
    } else {
      return const Stream.empty();
    }
  }
}
