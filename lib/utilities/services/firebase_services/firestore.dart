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

  static Future<List<RouteMarker>> getNearby(GeoPoint selected) async {
    List<RouteMarker> allMarkers = [];
    final geo = Geoflutterfire();

    //create geofirepoint
    GeoFirePoint center =
        geo.point(latitude: selected.latitude, longitude: selected.longitude);

    double radius = 10.0; // in kilometers
    String field = 'position';

    Stream<List<DocumentSnapshot>> stream = geo
        .collection(collectionRef: postMarkersCollection)
        .within(center: center, radius: radius, field: field, strictMode: true);

    stream.listen((List<DocumentSnapshot> doc) {
      doc.forEach((element) {
        String markerId = element['markerID'];
        RouteCoordinates position = element['position'];
        // GeoFirePoint position = element['position'];
        RouteMarker value =
            RouteMarker(markerID: markerId, coordinates: position);
        allMarkers.add(value);
      });

      print("Number of nearby places: " + doc.length.toString());
    });

    print("number of neighbors: " + stream.length.toString());
    return allMarkers;
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
}
