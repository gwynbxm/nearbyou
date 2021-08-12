/*
 * Created by Gwyn Bong Xiao Min
 * Copyright (c) 2021. All rights reserved.
 * Last modified 12/8/21 6:44 PM
 */
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nearbyou/models/route_post_model.dart';
import 'package:nearbyou/models/user_profile_model.dart';
import 'package:nearbyou/utilities/constants/constants.dart';

class DatabaseServices {
  static Future<void> addUser(
    String uid,
    UserData userData,
  ) async {
    await profileCollection
        .doc(uid)
        .set(userData.signUpToJson())
        .whenComplete(() => print("User added"))
        .catchError((e) => print(e));
  }

  static Future<void> getUser(String uid) async {
    DocumentSnapshot documentSnapshot = await profileCollection.doc(uid).get();
    return documentSnapshot;
  }

  static Future<void> updateUser(
    UserData userData,
    String uid,
  ) async {
    await profileCollection
        .doc(uid)
        .update(userData.editProfiletoJson())
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

  static Future<void> addPost(
    RoutePost routePost,
  ) async {
    await postCollection
        .add(routePost.toMap())
        .whenComplete(() => print("Post added"))
        .catchError((e) => print(e));
  }

  static Future<void> addRouteData() async {}
}
