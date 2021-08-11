/*
 * Created by Gwyn Bong Xiao Min
 * Copyright (c) 2021. All rights reserved.
 * Last modified 16/7/21 11:42 PM
 */

import 'dart:async';
import 'dart:collection';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:nearbyou/models/places_model.dart';
import 'package:nearbyou/models/route_marker_model.dart';
import 'package:nearbyou/models/route_post_model.dart';
import 'package:nearbyou/models/suggestions_model.dart';
import 'package:nearbyou/utilities/constants/constants.dart';
import 'package:nearbyou/utilities/ui/components/rounded_navi_icon_button.dart';
import 'package:nearbyou/utilities/ui/components/rounded_icon_button.dart';
import 'package:nearbyou/utilities/ui/palette.dart';
import 'package:nearbyou/views/posting/add_route_view.dart';
import 'package:nearbyou/views/posting/components/speed_dial_widget.dart';
import 'package:nearbyou/views/home/components/address_search.dart';
import 'package:nearbyou/views/home/home_view.dart';
import 'package:nearbyou/views/posting/edit_route_view.dart';
import 'package:uuid/uuid.dart';

import 'components/divider_widget.dart';
import 'components/search_text_field.dart';

class AddPostView extends StatefulWidget {
  final RouteMarker destPointData;

  const AddPostView({Key key, this.destPointData}) : super(key: key);

  @override
  _AddPostViewState createState() => _AddPostViewState();
}

class _AddPostViewState extends State<AddPostView> {
  static const LatLng initialPosition = const LatLng(1.3649170, 103.8228720);

  TextEditingController _destPointCon = TextEditingController();
  TextEditingController _postDescCon = TextEditingController();

  final destPointFocus = FocusNode();
  final postDescFocus = FocusNode();

  GoogleMapController googleMapController;
  Completer<GoogleMapController> _completer = Completer();

  LatLng _lastMapPosition = initialPosition;
  // Set<Marker> markerSet = HashSet<Marker>();
  List<Marker> markerList = [];
  List<RoutePost> routePostList = [];

  bool selectedLocation = false;

  @override
  void initState() {
    // TODO: implement initState
    if (widget.destPointData != null) {
      selectedLocation = true;
      _destPointCon.text = widget.destPointData.location.toString();

      setState(() {
        _onAddMarker(widget.destPointData.location);
        animateCamera(widget.destPointData.location);
      });
    }

    super.initState();
  }

  void _onMapCreated(GoogleMapController controller) {
    _completer.complete(controller);
    googleMapController = controller;
  }

  void _onCameraMove(CameraPosition position) {
    _lastMapPosition = position.target;
  }

  void _onAddMarker(LatLng coordinates) {
    var markerCount = markerList.length + 1;
    String markers = markerCount.toString();
    final MarkerId markerId = MarkerId(markers);
    final Marker marker = Marker(markerId: markerId, position: coordinates);
    setState(() {
      markerList.add(marker);
    });
  }

  Future<void> animateCamera(LatLng position) async {
    final GoogleMapController googleMapController = await _completer.future;
    googleMapController.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: position,
          zoom: 18,
        ),
      ),
    );
  }

  Future<String> searchPlaces() async {
    final sessionToken = Uuid().v4();
    final Suggestions result = await showSearch(
      context: context,
      delegate: PlacesSearch(sessionToken),
    );
    if (result != null) {
      return result.placeDesc;
    }
    return result.placeDesc;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        destPointFocus.unfocus();
        postDescFocus.unfocus();
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        floatingActionButton: RoundedIconButton(
          icon: Icons.add,
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddRouteDataView()),
          ),
        ),
        // SpeedDialWidget(),
        body: Stack(
          children: [
            buildGoogleMap(),
            SafeArea(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Container(
                    margin: EdgeInsets.symmetric(vertical: 15, horizontal: 5),
                    child: RoundedBasicIconButton(
                      icon: Icons.close,
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ),
                  Expanded(
                    // margin: EdgeInsets.all(16),
                    // color: Colors.white,
                    child: Container(
                      color: Colors.white,
                      // margin: EdgeInsets.all(5),
                      child: TextField(
                        keyboardType: TextInputType.text,
                        controller: _destPointCon,
                        readOnly: true,
                        focusNode: destPointFocus,
                        decoration: InputDecoration(
                          hintText: "Where are you going?",
                          hintStyle: TextStyle(color: Colors.grey),
                          suffixIcon: selectedLocation
                              ? IconButton(
                                  onPressed: clearSearch,
                                  icon: Icon(Icons.clear),
                                  color: Colors.grey,
                                )
                              : IconButton(
                                  onPressed: () {},
                                  icon: Icon(Icons.search),
                                  color: Colors.grey,
                                ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 15, vertical: 15),
                        ),
                        onTap: () async {
                          final place = await searchPlaces();
                          setState(() {
                            _destPointCon.text = place;
                            selectedLocation = true;
                          });
                        },
                      ),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.symmetric(vertical: 15, horizontal: 5),
                    child: RoundedBasicIconButton(
                      icon: Icons.check,
                      onPressed: () {},
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  GoogleMap buildGoogleMap() {
    return GoogleMap(
      onMapCreated: _onMapCreated,
      myLocationButtonEnabled: false,
      myLocationEnabled: false,
      zoomGesturesEnabled: true,
      zoomControlsEnabled: false,
      mapToolbarEnabled: false,
      initialCameraPosition: CameraPosition(
        target: initialPosition,
        zoom: 11.0,
      ),
      mapType: MapType.normal,
      markers: Set<Marker>.of(markerList),
      onCameraMove: _onCameraMove,
      onTap: _onAddMarker,
    );
  }

  void clearSearch() {
    setState(() {
      _destPointCon.clear();
      selectedLocation = false;
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _destPointCon.dispose();
    _postDescCon.dispose();
    super.dispose();
  }
}
