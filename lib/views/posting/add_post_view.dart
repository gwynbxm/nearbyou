/*
 * Created by Gwyn Bong Xiao Min
 * Copyright (c) 2021. All rights reserved.
 * Last modified 24/11/21 3:10 PM
 */

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:nearbyou/models/route_coordinates_model.dart';
import 'package:nearbyou/models/route_marker_model.dart';
import 'package:nearbyou/models/route_post_model.dart';
import 'package:nearbyou/models/suggestions_model.dart';
import 'package:nearbyou/utilities/services/firebase_services/firestore.dart';
import 'package:nearbyou/utilities/ui/components/custom_dialog_box.dart';
import 'package:nearbyou/utilities/ui/palette.dart';
import 'package:nearbyou/views/posting/add_route_details_view.dart';
import 'package:nearbyou/views/home/components/address_search.dart';
import 'package:uuid/uuid.dart';

class AddPostView extends StatefulWidget {
  final String
      currentUser; //TODO: cannot capture user id to save into firestore!!!
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
  List<Marker> markerIconList = [];
  Map<MarkerId, Marker> _markers = <MarkerId, Marker>{};
  RouteMarker routeMarker;
  List<RouteMarker> routeMarkerList = [];
  String markerDocId;
  List<String> routeMarkerIdsList = [];
  List<RoutePost> routePostList = [];

  MarkerId selectedMarker;

  bool isLocationSelected = false;
  bool isMarkerAdded = false;
  bool isMarkerPosted = false;
  bool isPosted = false;

  final geo = Geoflutterfire();

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      await showDialog(
          context: context,
          builder: (BuildContext context) {
            return CustomDialogBox(
              icon: Icons.add_location_alt,
              bgAvatarColor: primaryColor,
              iconColor: Colors.white,
              dialogTitle: 'Lets Get Started!', //lets get started!
              dialogSubtitle:
                  'Create your very own shortcut routes by tapping on the map!',
              onPressedRightButton: () => Navigator.of(context).pop(),
              rightButtonText: 'Dismiss',
              rightButtonTextColor: colorS2C1,
            );
          });
    });
    if (widget.destPointData != null) {
      isLocationSelected = true;
      _destPointCon.text = widget.destPointData.coordinates.toString();

      // double lat = widget.destPointData.coordinates.latitude;
      // double lng = widget.destPointData.coordinates.longitude;
      //
      double lat = widget.destPointData.coordinates.geoPoint.latitude;
      double lng = widget.destPointData.coordinates.geoPoint.longitude;

      setState(() {
        _onAddMarker(LatLng(lat, lng));
        // animateCamera(widget.destPointData.coordinates);
        animateCamera(widget.destPointData.coordinates.geoPoint);
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
    var markerCount = markerIconList.length + 1;
    String markers = markerCount.toString();
    final uuId = Uuid().v4();
    final uniqueMarkerId = uuId + markers;
    final MarkerId markerId = MarkerId(uniqueMarkerId);

    //creates a marker look
    final Marker marker = Marker(
      markerId: markerId,
      position: coordinates,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
      onTap: () {
        _onMarkerTapped(markerId);
      },
    );
    setState(() {
      // display added marker icon
      _markers[markerId] = marker;
      // add marker object to the map and to the temporary list of markers
      markerIconList.add(marker);

      GeoFirePoint tappedLocation = geo.point(
          latitude: coordinates.latitude, longitude: coordinates.longitude);

      //update the marker object
      routeMarker = RouteMarker(
          markerID: markerId.toString(),
          coordinates: RouteCoordinates(
              geoHash: tappedLocation.hash, geoPoint: tappedLocation.geoPoint),
          // coordinates: tappedLocation,
          routeOrder: markerCount);

      //add marker object to the list of markers
      routeMarkerList.add(routeMarker);
    });
  }

  Future<void> animateCamera(GeoPoint position) async {
    final GoogleMapController googleMapController = await _completer.future;
    googleMapController.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          // target: position,
          zoom: 18,
          target: LatLng(position.latitude, position.longitude),
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

  Future<void> _onMapTapped(LatLng coordinates) async {
    setState(() {
      //when tapped on the map, it calls onAddMarker to add marker icon on the map
      _onAddMarker(coordinates);
    });
  }

  // marker click event
  void _onMarkerTapped(MarkerId markerId) {
    final Marker tappedMarker = _markers[markerId];
    if (tappedMarker != null) {
      setState(() {
        final MarkerId previousMarkerId = selectedMarker;
        if (previousMarkerId != null &&
            _markers.containsKey(previousMarkerId)) {
          final Marker resetOld = _markers[previousMarkerId].copyWith(
              iconParam: BitmapDescriptor.defaultMarkerWithHue(
                  BitmapDescriptor.hueOrange));
          _markers[previousMarkerId] = resetOld;
        }
        //TODO : solve this cos it needs to tap 2 times in order to see the modalbottomsheet. shld be only one tap!
        selectedMarker = markerId;
        final Marker newMarker = tappedMarker.copyWith(
            iconParam: BitmapDescriptor.defaultMarkerWithHue(
                BitmapDescriptor.hueGreen),
            onTapParam: () => _manageMarkerData(context, markerId));

        _markers[markerId] = newMarker;
      });
    }
  }

  // options for creators to edit, update or delete marker
  _manageMarkerData(BuildContext context, MarkerId tappedMarkerId) {
    for (int i = 0; i < routeMarkerList.length; i++) {
      // if both id is the same, activate onTap function and enable managing of marker data
      if (MarkerId(routeMarkerList[i].markerID) == tappedMarkerId) {
        setState(() {
          routeMarker = routeMarkerList[i];
          print('markerId' + routeMarker.markerID.toString());
        });
      }
    }
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
                      _addRouteData(context, routeMarker);
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

  // add marker details received from AddRouteDetailsView screen
  void _addRouteData(BuildContext context, RouteMarker routeMarker) async {
    //this waits for the marker that is updated with data

    final updatedMarkerData = await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => AddRouteDetailsView(routeMarker: routeMarker)),
    ) as RouteMarker;

    // iterate the current list of markers to update the marker with data if id is same
    if (updatedMarkerData != null) {
      print(
          'Marker passed back from AddRouteData' + updatedMarkerData.markerID);
      print('Title passed back from AddRouteData' + updatedMarkerData.title);
      setState(() {
        final index = routeMarkerList.indexWhere(
            (marker) => marker.markerID == updatedMarkerData.markerID);
        routeMarkerList[index] = updatedMarkerData;
        print('index ' + index.toString());
        print('Title saved in respective index in the list ' +
            routeMarkerList[index].title);
      });

      // for (int i = 0; i < routeMarkerList.length; i++) {
      //   if (routeMarkerList[i].markerID ==
      //       updatedMarkerData.markerID.toString()) {
      //     setState(() {
      //       routeMarkerList[i].title = updatedMarkerData.title;
      //       routeMarkerList[i].caption = updatedMarkerData.caption;
      //       routeMarkerList[i].imageList =
      //           List.from(updatedMarkerData.imageList);
      //     });
      //   }
      // }
    }
  }

  popUpDialog() {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return CustomDialogBox(
            icon: Icons.warning,
            bgAvatarColor: Colors.redAccent,
            iconColor: Colors.white,
            dialogTitle: 'Oh no!',
            dialogSubtitle:
                'Noticed there are fields left blank, are you sure you want to post?',
            leftButtonText: 'Cancel',
            rightButtonText: 'Post',
            leftButtonTextColor: Colors.black,
            rightButtonTextColor: primaryColor,
            onPressedLeftButton: () => Navigator.of(context).pop(),
            onPressedRightButton: () {
              Navigator.of(context).pop();
              addToDatabase();
            },
          );
        });
  }

  // store into post and its respective routemarkers into firestore
  _checkPost() async {
    if (routeMarkerList.isEmpty) {
      //if either one empty, still post
      popUpDialog();
    } else if (_postDescCon.text.isEmpty) {
      popUpDialog();
    } else if (routeMarkerList.isNotEmpty) {
      //TODO: perhaps due to the image size
      for (int i = 0; i < routeMarkerList.length; i++) {
        markerDocId =
            await DatabaseServices.addMarkersToPost(routeMarkerList[i]);
        setState(() {
          if (markerDocId.isNotEmpty) {
            routeMarkerIdsList.add(markerDocId);
            isMarkerPosted = true;
          }
          print('Number of marker id ' + routeMarkerIdsList.length.toString());
        });
      }
    }

    if (isMarkerPosted) {
      addToDatabase();
    }
  }

  addToDatabase() async {
    String description = _postDescCon.text ?? '';

    //it stores in firestore using the img string passed from the other screen
    final RoutePost post = RoutePost(
      createdBy: widget.currentUser,
      routeMarkerIds: routeMarkerIdsList,
      description: description,
      dateTimePosted: Timestamp.fromDate(DateTime.now()),
    );

    await DatabaseServices.addPost(post);

    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return CustomDialogBox(
            icon: Icons.check,
            bgAvatarColor: Colors.green,
            iconColor: Colors.white,
            dialogTitle: 'Post Created!',
            dialogSubtitle: 'Awesome! Continue sharing with us more!',
            rightButtonText: 'Dismiss',
            rightButtonTextColor: primaryColor,
            onPressedRightButton: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
          );
        });
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
          // TODO: implement discard alert dialog
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
                onPressed: _checkPost)
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
    final MarkerId selectedId = selectedMarker;
    return GoogleMap(
      onMapCreated: _onMapCreated,
      myLocationButtonEnabled: false,
      myLocationEnabled: false,
      zoomGesturesEnabled: true,
      zoomControlsEnabled: false,
      mapToolbarEnabled: false,
      compassEnabled: false,
      initialCameraPosition: CameraPosition(
        target: initialPosition,
        zoom: 11.0,
      ),
      mapType: MapType.normal,
      markers: Set<Marker>.of(_markers.values),
      onCameraMove: _onCameraMove,
      onTap: _onMapTapped,
    );
  }

  void clearSearch() {
    setState(() {
      _destPointCon.clear();
      isLocationSelected = false;
      // isMarkerAdded = false;
    });
  }

  @override
  void dispose() {
    _destPointCon.dispose();
    _postDescCon.dispose();
    super.dispose();
  }
}
