/*
 * Created by Gwyn Bong Xiao Min
 * Copyright (c) 2021. All rights reserved.
 * Last modified 15/8/21 7:57 PM
 */
import 'dart:io';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firestore_helpers/firestore_helpers.dart';
import 'package:flutter/cupertino.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:nearbyou/models/route_coordinates_model.dart';
import 'package:nearbyou/models/route_marker_model.dart';
import 'package:nearbyou/models/route_post_model.dart';
import 'package:nearbyou/models/user_profile_model.dart';
import 'package:nearbyou/utilities/constants/constants.dart';
import 'package:vector_math/vector_math.dart';

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
        .then((DocumentReference doc) {
          final String postId = doc.id;
          postCollection.doc(postId).update({'postId': postId});
        })
        .whenComplete(() => print("Post added"))
        .catchError((e) => print(e));
  }

  static Future<String> addMarkersToPost(RouteMarker routeMarker) async {
    String markerDocId;
    await postMarkersCollection
        .add(routeMarker.toMap())
        .then((DocumentReference doc) {
          markerDocId = doc.id;
          postMarkersCollection
              .doc(markerDocId)
              .update({'routeMarkerDocID': markerDocId});
        })
        .whenComplete(() => print("Markers added to post"))
        .catchError((e) => print(e));

    return markerDocId;
  }

  static Future<void> deletePostData(
    String selectedPostId,
    List<String> postMarkerIds,
  ) async {
    //if the post has no markers
    if (postMarkerIds == null) {
      // delete the post
      await deletePost(selectedPostId);
    } else {
      //if post has existing markers
      //delete markers of the post first
      for (int i = 0; i < postMarkerIds.length; i++) {
        postMarkersCollection.doc(postMarkerIds[i]).delete().whenComplete(() {
          print("marker deleted");
        }).catchError((e) {
          print(e);
        });
      }
      await deletePost(selectedPostId);
    }
  }

  static Future<void> deletePost(String selectedPostId) async {
    await postCollection.doc(selectedPostId).delete().whenComplete(() {
      print("post deleted");
    }).catchError((e) {
      print(e);
    });
  }
}
