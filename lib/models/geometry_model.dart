/*
 * Created by Gwyn Bong Xiao Min
 * Copyright (c) 2021. All rights reserved.
 * Last modified 19/7/21 1:09 PM
 */

import 'package:nearbyou/models/location_model.dart';

class Geometry {
  final LocationData locationData;

  Geometry({this.locationData});

  Geometry.fromMap(Map<dynamic, dynamic> parsedJson)
      : locationData = LocationData.fromMap(parsedJson['location']);
}
