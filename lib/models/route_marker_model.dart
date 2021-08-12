/*
 * Created by Gwyn Bong Xiao Min
 * Copyright (c) 2021. All rights reserved.
 * Last modified 12/8/21 5:35 PM
 */

import 'dart:io';

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:nearbyou/models/route_marker_img_model.dart';

class RouteMarker {
  String routeMarkerID;
  String caption;
  // List<ImageData> imageList;
  LatLng coordinates;
  int routeOrder;

  RouteMarker({
    this.routeMarkerID,
    this.caption,
    // this.imageList,
    this.coordinates,
    this.routeOrder,
  });

  RouteMarker.withoutData(
    this.coordinates,
  );

  Map<String, dynamic> toMap() => {
        'routeMarkerId': routeMarkerID,
        'caption': caption,
        // 'imageList': imageList.map((e) => e.toMap()).toList(),
        'coordinates': coordinates.toJson(),
        'routeOrder': routeOrder,
      };

  factory RouteMarker.fromMap(Map<dynamic, dynamic> json) {
    return RouteMarker(
      routeMarkerID: json['routeMarkerId'],
      caption: json['caption'],
      // imageList: json['imageList'],
      coordinates: json['coordinates'],
      routeOrder: json['routeOrder'],
    );
  }
}
