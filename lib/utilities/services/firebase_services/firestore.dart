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
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:nearbyou/models/location_model.dart';
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

  //get all markers
  static Future<List<RouteMarker>> getAllMarkers() async {
    List<RouteMarker> allNearbyMarkers = [];

    await postMarkersCollection
        .get()
        .then((value) => value.docs.forEach((snapshot) {
              LatLng location =
                  LatLng(snapshot['location'][0], snapshot['location'][1]);

              String markerId = snapshot['markerID'];
              RouteCoordinates coordinates = RouteCoordinates(
                  geoHash: snapshot['position']['geohash'],
                  geoPoint: snapshot['position']['geopoint']);

              RouteMarker value = RouteMarker(
                  markerID: markerId,
                  coordinates: coordinates,
                  location: location);
              allNearbyMarkers.add(value);
            }));

    print("all marker from firestore" + allNearbyMarkers.length.toString());
    return allNearbyMarkers;
  }

  //geoflutterfire package does not work
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

  //older version, but cant really work except displaying all markers
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

  //calculate upon retrieving from firestore does not work
  static Future<List<RouteMarker>> getNearbyFP(GeoPoint center) async {
    List<RouteMarker> allNearbyMarkers = [];

    double centerLat = center.latitude;
    double centerLng = center.longitude;

    double earthRad = 6371; //earth mean radius in km

    double distance = 2;
    //1km/40,000km * 360 degrees
    double adjust = .008983112; // 1km in degrees at equator
    // double lngRatio = 1 / cos(radians(centerLat));
    double distToDeg = distance * adjust;

    //boundary square box
    double topLeftLat = centerLat + (distToDeg);
    double tLRatio = 1 / cos(radians(topLeftLat));
    double topLeftLng = centerLng - (distToDeg * tLRatio);
    var topLeft = GeoPoint(topLeftLat, topLeftLng);

    double topRightLat = centerLat + (distToDeg);
    double tRRatio = 1 / cos(radians(topRightLat));
    double topRightLng = centerLng - (distToDeg * tRRatio);
    var topRight = GeoPoint(topRightLat, topRightLng);

    double btmLeftLat = centerLat - (distToDeg);
    double bLRatio = 1 / cos(radians(btmLeftLat));
    double btmLeftLng = centerLng - (distToDeg * bLRatio);
    var btmLeft = GeoPoint(btmLeftLat, btmLeftLng);

    double btmRightLat = centerLat - (distToDeg);
    double bRRatio = 1 / cos(radians(btmRightLat));
    double btmRightLng = centerLng + (distToDeg * bRRatio);
    var btmRight = GeoPoint(btmRightLat, btmRightLng);

    await postMarkersCollection.get().then((value) {
      //all markerss
      value.docs.forEach((snapshot) {
        String markerId = snapshot['markerID'];
        double nearbyLat = snapshot['location'][0];
        double nearbyLng = snapshot['location'][1];

        print("MarkerId " + markerId.toString());
        print("Coordinates " +
            nearbyLat.toString() +
            " " +
            nearbyLng.toString()); //displays all markers

        if (nearbyLat <= topLeftLat &&
            nearbyLat <= topRightLat &&
            nearbyLat <= btmLeftLat &&
            nearbyLat <= btmRightLat) {
          if (nearbyLng >= topLeftLng &&
              nearbyLng <= topRightLng &&
              nearbyLng >= btmLeftLng &&
              nearbyLng <= btmRightLng) {
            String markerId = snapshot['markerID'];
            RouteCoordinates coordinates = RouteCoordinates(
                geoHash: snapshot['position']['geohash'],
                geoPoint: snapshot['position']['geopoint']);

            LatLng location = LatLng(nearbyLat, nearbyLng);

            RouteMarker value = RouteMarker(
                markerID: markerId,
                coordinates: coordinates,
                location: location);

            // add to the list if its nearby coordinates!
            allNearbyMarkers.add(value);
            print("number of nearby markers found: " +
                allNearbyMarkers.length.toString());
          }
        }
      });
    });
    return allNearbyMarkers;
  }

  //working but only latitude. firestore ignores longitude
  static Future<List<RouteMarker>> getNearbyFPs(GeoPoint center) async {
    List<RouteMarker> allNearbyMarkers = [];

    double centerLat = center.latitude;
    double centerLng = center.longitude;

    double earthRad = 6371; //earth mean radius in km

    double distance = 2;
    //1km/40,000km * 360 degrees
    double adjust = .008983112; // 1km in degrees at equator

    //do calculation here
    double north = centerLat + (distance * adjust);
    var _north = GeoPoint(north, 0);
    double south = centerLat - (distance * adjust);
    var _south = GeoPoint(south, 0);

    double lngRatio = 1 / cos(radians(centerLat));

    double east = centerLng + (distance * adjust) * lngRatio;
    var _east = GeoPoint(0, east);
    double west = centerLng - (distance * adjust) * lngRatio;
    var _west = GeoPoint(0, west);

    await postMarkersCollection
        .where('position.geopoint', isGreaterThanOrEqualTo: _north)
        .get()
        .then((value) {
      value.docs.forEach((snapshot) {
        String markerId = snapshot['markerID'];
        RouteCoordinates coordinates = RouteCoordinates(
            geoHash: snapshot['position']['geohash'],
            geoPoint: snapshot['position']['geopoint']);

        RouteMarker value =
            RouteMarker(markerID: markerId, coordinates: coordinates);

        // add to the list if its nearby coordinates!
        allNearbyMarkers.add(value);
        print(allNearbyMarkers.length);
      });
    });
    return allNearbyMarkers;
  }
}
