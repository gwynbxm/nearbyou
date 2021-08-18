/*
 * Created by Gwyn Bong Xiao Min
 * Copyright (c) 2021. All rights reserved.
 * Last modified 18/8/21 4:44 PM
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
import 'package:nearbyou/models/user_profile_model.dart';
import 'package:nearbyou/utilities/constants/constants.dart';
import 'package:nearbyou/utilities/services/firebase_services/firestore.dart';
import 'package:nearbyou/utilities/ui/components/rounded_navi_icon_button.dart';
import 'package:nearbyou/utilities/ui/components/rounded_icon_button.dart';
import 'package:nearbyou/utilities/ui/palette.dart';
import 'package:nearbyou/views/posting/add_route_details_view.dart';
import 'package:nearbyou/views/posting/components/speed_dial_widget.dart';
import 'package:nearbyou/views/home/components/address_search.dart';
import 'package:nearbyou/views/home/home_view.dart';
import 'package:nearbyou/views/posting/edit_route_view.dart';
import 'package:uuid/uuid.dart';

import 'components/divider_widget.dart';
import 'components/search_text_field.dart';

class AddPostView extends StatefulWidget {
  final String currentUser;
  final RouteMarker destPointData;

  const AddPostView({
    Key key,
    this.destPointData,
    this.currentUser,
  }) : super(key: key);

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
  List<Marker> markerList = [];
  RouteMarker routeMarker;
  List<RouteMarker> routeMarkerList = [];
  List<RoutePost> routePostList = [];

  bool selectedLocation = false;

  @override
  void initState() {
    // TODO: implement initState
    if (widget.destPointData != null) {
      selectedLocation = true;
      _destPointCon.text = widget.destPointData.coordinates.toString();

      setState(() {
        _onAddMarker(widget.destPointData.coordinates);
        animateCamera(widget.destPointData.coordinates);
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
    final uuId = Uuid().v4();
    final uniqueId = uuId + markers;
    final MarkerId markerId = MarkerId(uniqueId);
    final Marker marker = Marker(
        markerId: markerId,
        position: coordinates,
        onTap: () =>
            _manageMarkerData(context, markerId, coordinates, markerCount));
    setState(() {
      markerList.add(marker); //marker to the map
      routeMarker = RouteMarker(
          routeMarkerID: markerId.toString(),
          coordinates: coordinates,
          routeOrder: markerCount);
      routeMarkerList.add(routeMarker);
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

  _manageMarkerData(context, MarkerId id, LatLng coordinates, int routeOrder) {
    RouteMarker routeMarker = RouteMarker(
        routeMarkerID: id.toString(),
        coordinates: coordinates,
        routeOrder: routeOrder);
    showModalBottomSheet(
        context: context,
        builder: (builder) {
          return SafeArea(
            child: Container(
              child: Wrap(
                children: [
                  ListTile(
                    leading: Icon(
                      Icons.add,
                      color: iconColor,
                    ),
                    title: Text('Add Details'),
                    onTap: () {
                      _addRouteData(context);
                    },
                  ),
                  ListTile(
                    leading: Icon(
                      Icons.edit,
                      color: iconColor,
                    ),
                    title: Text('Edit Details'),
                    onTap: () {
                      // _editMarkerData();
                    },
                  ),
                  ListTile(
                    leading: Icon(
                      Icons.swap_horiz,
                      color: primaryColor,
                    ),
                    title: Text('Change Marker Position'),
                    onTap: () {
                      // _editMarkerData();
                    },
                  ),
                  ListTile(
                    leading: Icon(
                      Icons.delete,
                      color: Colors.red,
                    ),
                    title: Text('Delete marker'),
                    onTap: () {},
                  )
                ],
              ),
            ),
          );
        });
  }

  void _addRouteData(BuildContext context) async {
    final updatedMarkerData = await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => AddRouteDetailsView(routeMarker: routeMarker)),
    ) as RouteMarker;

    if (updatedMarkerData != null) {
      for (var item in routeMarkerList) {
        final index = routeMarkerList.indexOf(item);
        if (updatedMarkerData.routeMarkerID ==
            routeMarkerList[index].routeMarkerID) {
          setState(() {
            routeMarkerList[index].title = updatedMarkerData.title;
            routeMarkerList[index].caption = updatedMarkerData.caption;
            routeMarkerList[index].imageList = updatedMarkerData.imageList;
            print(updatedMarkerData.caption);
          });
        }
      }
    }
  }

  void _savePost() async {
    String description = _postDescCon.text;

    final RoutePost post = RoutePost(
      userId: widget.currentUser,
      description: description,
      routeMarkers: routeMarkerList,
    );
    await DatabaseServices.addPost(post);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        destPointFocus.unfocus();
        postDescFocus.unfocus();
      },
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          leading: CloseButton(
            onPressed: () => Navigator.of(context).pop(),
            color: Colors.black,
          ),
          title: Text(
            'Create Post',
            style: TextStyle(color: Colors.black),
          ),
          actions: [
            IconButton(
                icon: Icon(
                  Icons.check,
                  color: Colors.black,
                ),
                onPressed: _savePost)
          ],
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: Stack(
          children: [
            buildGoogleMap(),
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                margin: EdgeInsets.symmetric(vertical: 30),
                // decoration: BoxDecoration(
                //   color: Colors.white60,
                //   borderRadius: BorderRadius.circular(20.0),
                // ),
                width: MediaQuery.of(context).size.width * 0.9,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // Container(
                    //   // color: Colors.white60,
                    //   decoration: BoxDecoration(
                    //     color: Colors.white,
                    //     borderRadius: BorderRadius.circular(20.0),
                    //   ),
                    //   child: TextField(
                    //     keyboardType: TextInputType.text,
                    //     controller: _destPointCon,
                    //     readOnly: true,
                    //     focusNode: destPointFocus,
                    //     decoration: InputDecoration(
                    //       hintText: "Where are you going?",
                    //       hintStyle: TextStyle(color: Colors.grey),
                    //       suffixIcon: selectedLocation
                    //           ? IconButton(
                    //               onPressed: clearSearch,
                    //               icon: Icon(Icons.clear),
                    //               color: Colors.grey,
                    //             )
                    //           : IconButton(
                    //               onPressed: () {},
                    //               icon: Icon(Icons.search),
                    //               color: Colors.grey,
                    //             ),
                    //       border: InputBorder.none,
                    //       contentPadding: EdgeInsets.symmetric(
                    //           horizontal: 15, vertical: 15),
                    //     ),
                    //     onTap: () async {
                    //       final place = await searchPlaces();
                    //       setState(() {
                    //         _destPointCon.text = place;
                    //         selectedLocation = true;
                    //       });
                    //     },
                    //   ),
                    // ),
                    // SizedBox(
                    //   height: 15,
                    // ),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white60,
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                      child: TextField(
                        keyboardType: TextInputType.multiline,
                        focusNode: postDescFocus,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Write something here ....',
                          hintMaxLines: 4,
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.all(
                              Radius.circular(20.0),
                            ),
                            borderSide: BorderSide(
                              color: Colors.grey,
                              width: 2,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.all(
                              Radius.circular(20.0),
                            ),
                            borderSide: BorderSide(
                              color: textLightColor,
                              width: 2,
                            ),
                          ),
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 20, vertical: 20),
                        ),
                        controller: _postDescCon,
                        maxLines: 4,
                      ),
                    ),
                  ],
                ),
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
