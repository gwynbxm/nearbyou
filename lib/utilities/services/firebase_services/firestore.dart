/*
 * Created by Gwyn Bong Xiao Min
 * Copyright (c) 2021. All rights reserved.
 * Last modified 17/7/21 9:18 PM
 */
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nearbyou/models/user_profile_model.dart';

final FirebaseFirestore _firestore = FirebaseFirestore.instance;

final CollectionReference profileCollection = _firestore.collection('profile');

class DatabaseServices {
  static Future<void> addUser(
    String uid,
    UserProfile userProfile,
  ) async {
    await profileCollection
        .doc(uid)
        .set(userProfile.toMap())
        .whenComplete(() => print("User added"))
        .catchError((e) => print(e));
  }

  static Future<void> getUser(String uid) async {
    DocumentSnapshot documentSnapshot = await profileCollection.doc(uid).get();
    return documentSnapshot;
  }

  static Future<void> updateUser(
    UserProfile userProfile,
    String uid,
  ) async {
    await profileCollection
        .doc(uid)
        .update(userProfile.toMap())
        .whenComplete(() => print("User updated"))
        .catchError((e) => print(e));
  }

  static Future<void> deleteUser(
    String uid,
    String docId,
  ) async {
    await profileCollection
        .doc(uid)
        .delete()
        .whenComplete(() => print("User deleted"))
        .catchError((e) => print(e));
  }
}
