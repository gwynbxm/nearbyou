/*
 * Created by Gwyn Bong Xiao Min
 * Copyright (c) 2021. All rights reserved.
 * Last modified 11/11/21 4:08 PM
 */

import 'package:cloud_firestore/cloud_firestore.dart';

class RouteCoordinates {
  String geoHash;
  GeoPoint geoPoint;

  double distance;

  RouteCoordinates({this.geoHash, this.geoPoint});

  Map<String, dynamic> toMap() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['geohash'] = geoHash;
    data['geopoint'] = geoPoint;
    return data;
  }

  factory RouteCoordinates.fromMap(Map<dynamic, dynamic> json) =>
      RouteCoordinates(
        geoHash: json['geohash'],
        geoPoint: json['geopoint'],
      );
}
