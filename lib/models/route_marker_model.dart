/*
 * Created by Gwyn Bong Xiao Min
 * Copyright (c) 2021. All rights reserved.
 * Last modified 18/8/21 4:49 PM
 */

import 'package:google_maps_flutter/google_maps_flutter.dart';

class RouteMarker {
  String routeMarkerID;
  String title;
  String caption;
  List<String> imageList;
  LatLng coordinates;
  int routeOrder;

  RouteMarker({
    this.routeMarkerID,
    this.title,
    this.caption,
    this.imageList,
    this.coordinates,
    this.routeOrder,
  });

  RouteMarker.withoutData(
    this.coordinates,
  );

  Map<String, dynamic> toMap() => {
        'routeMarkerId': routeMarkerID,
        'title': title,
        'caption': caption,
        'imageList': imageList,
        'coordinates': coordinates.toJson(),
        'routeOrder': routeOrder,
      };

  factory RouteMarker.fromMap(Map<dynamic, dynamic> json) {
    return RouteMarker(
      routeMarkerID: json['routeMarkerId'],
      title: json['title'],
      caption: json['caption'],
      imageList: json['imageList'],
      coordinates: json['coordinates'],
      routeOrder: json['routeOrder'],
    );
  }
}
