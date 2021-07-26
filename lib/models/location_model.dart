/*
 * Created by Gwyn Bong Xiao Min
 * Copyright (c) 2021. All rights reserved.
 * Last modified 19/7/21 1:05 PM
 */
import 'dart:convert';

class LocationData {
  final double lat;
  final double lng;

  LocationData({
    this.lat,
    this.lng,
  });

  factory LocationData.fromMap(Map<dynamic, dynamic> json) {
    return LocationData(
      lat: json['lat'],
      lng: json['lng'],
    );
  }
}
