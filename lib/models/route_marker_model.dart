/*
 * Created by Gwyn Bong Xiao Min
 * Copyright (c) 2021. All rights reserved.
 * Last modified 25/7/21 6:13 PM
 */

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:nearbyou/models/route_image_data_model.dart';

class RouteMarker {
  String routeMarkerID;
  List<ImageData> imageData;
  LatLng location;
  int routeOrder;

  RouteMarker(
    this.routeMarkerID,
    this.imageData,
    this.location,
    this.routeOrder,
  );
}
