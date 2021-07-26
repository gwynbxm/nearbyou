/*
 * Created by Gwyn Bong Xiao Min
 * Copyright (c) 2021. All rights reserved.
 * Last modified 15/7/21 7:29 PM
 */

import 'package:nearbyou/models/geometry_model.dart';

class Places {
  final Geometry geometry;
  final String placeName;
  final String placeAddress;

  Places({
    this.geometry,
    this.placeName,
    this.placeAddress,
  });

  factory Places.fromMap(Map<String, dynamic> json) {
    return Places(
        geometry: Geometry.fromMap(json['geometry']),
        placeName: json['name'],
        placeAddress: json['vicinity']);
  }
}
