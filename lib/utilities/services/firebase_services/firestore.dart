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
import 'package:nearbyou/models/post_comment_model.dart';
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

  //upload comments to specific post
  static Future<void> uploadComment(String postId, PostComment comment) async {
    await postCollection
        .doc(postId)
        .collection(comments)
        .add(comment.toMap())
        .then((DocumentReference doc) {
          final String commentId = doc.id;
          postCollection
              .doc(postId)
              .collection(comments)
              .doc(commentId)
              .update({'postCommentId': commentId});
        })
        .whenComplete(() => print("Comments uploaded"))
        .catchError((e) => print(e));
  }

  static Future<List<RouteMarker>> getNearbyFBMarkers(GeoPoint center) async {
    List<RouteMarker> allMarkers = [];
    double centerLat = center.latitude;
    double centerLng = center.longitude;

    double distance = 30;
    double lat = 0.0144927536231884;
    double lng = 0.0181818181818182;

    double lowerLat = centerLat - (lat * distance);
    double lowerLng = centerLng - (lng * distance);

    double greaterLat = centerLat + (lat * distance);
    double greaterLng = centerLng + (lat * distance);

    final lesserGP = GeoPoint(lowerLat, lowerLng);
    final greaterGP = GeoPoint(greaterLat, greaterLng);

    // filter out the nearby coordinates
    await postMarkersCollection
        .where(
          'position.geopoint',
          isGreaterThan: lesserGP,
          isLessThan: greaterGP,
        )
        .get()
        .then((value) {
      value.docs.forEach((snap) {
        String markerId = snap['markerID'];
        // GeoPoint coordinates = snap['coordinates'];

        // GeoFirePoint coordinates = snap['position']['geopoint'];

        RouteCoordinates coordinates = RouteCoordinates(
            geoHash: snap['position']['geohash'],
            geoPoint: snap['position']['geopoint']);

        RouteMarker value =
            RouteMarker(markerID: markerId, coordinates: coordinates);

        allMarkers.add(value);
      });
    });

    return allMarkers;
  }

  static void followUser(String currentUser, String followingUserId) {
    //currentUser is the one following another user profile (followingUserId)
    //Add to its following
    profileCollection
        .doc(currentUser)
        .collection(following)
        .doc(followingUserId)
        .update({'dateTimeFollowed': timestamp});

    // add to the other party's followers
    profileCollection
        .doc(followingUserId)
        .collection(followers)
        .doc(currentUser)
        .update({'dateTimeFollowing': timestamp});
  }

  static void unFollowUser(String currentUser, String unfollowUserId) {
    //remove from its following
    profileCollection
        .doc(currentUser)
        .collection(following)
        .doc(unfollowUserId)
        .get()
        .then((doc) => doc.exists ?? doc.reference.delete());

    //remove from the other party's followers
    profileCollection
        .doc(unfollowUserId)
        .collection(followers)
        .doc(currentUser)
        .get()
        .then((doc) => doc.exists ?? doc.reference.delete());
  }

  static Future<bool> isFollowing(
      String currentUser, String followUserId) async {
    DocumentSnapshot followingDoc = await profileCollection
        .doc(followUserId)
        .collection(following)
        .doc(currentUser)
        .get();
    return followingDoc.exists;
  }

  static Future<int> followingNum(String id) async {
    QuerySnapshot followNum =
        await profileCollection.doc(id).collection(following).get();
    return followNum.docs.length;
  }

  static Future<int> followerNum(String id) async {
    QuerySnapshot followerNum =
        await profileCollection.doc(id).collection(followers).get();
    return followerNum.docs.length;
  }
}
