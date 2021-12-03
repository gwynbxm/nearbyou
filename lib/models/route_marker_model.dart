/*
 * Created by Gwyn Bong Xiao Min
 * Copyright (c) 2021. All rights reserved.
 * Last modified 24/11/21 2:07 PM
 */

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:nearbyou/models/route_coordinates_model.dart';

class RouteMarker {
  String routeMarkerDocID;
  String markerID;
  String title;
  String caption;
  List<String> imageList;
  RouteCoordinates coordinates;
  LatLng location;
  int routeOrder;

  RouteMarker({
    this.routeMarkerDocID,
    this.markerID,
    this.title,
    this.caption,
    this.imageList,
    this.coordinates,
    this.routeOrder,
    this.location,
  });

  RouteMarker.withoutData(
    this.coordinates,
  );

  Map<String, dynamic> toMap() => {
        'routeMarkerDocID': routeMarkerDocID ?? '',
        'markerID': markerID,
        'title': title ?? '',
        'caption': caption ?? '',
        'imageList': imageList ?? '',
        'position': coordinates.toMap(),
        'location': location.toJson(),
        'routeOrder': routeOrder,
      };

  factory RouteMarker.fromMap(Map<dynamic, dynamic> json) {
    return RouteMarker(
      //TODO: check if the fields are empty when storing?
      routeMarkerDocID: json['routeMarkerDocID'],
      markerID: json['markerID'],
      title: json['title'] ?? '',
      caption: json['caption'] ?? '',
      imageList: List<String>.from(json['imageList']).toList(),
      coordinates: RouteCoordinates.fromMap(json['position']),
      location: LatLng.fromJson(json['location']),
      routeOrder: json['routeOrder'],
    );
  }

  factory RouteMarker.fromDocument(DocumentSnapshot snapshot) {
    return RouteMarker.fromMap(snapshot.data());
  }
}
