/*
 * Created by Gwyn Bong Xiao Min
 * Copyright (c) 2021. All rights reserved.
 * Last modified 16/7/21 11:42 PM
 */

import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:nearbyou/models/route_marker_model.dart';
import 'package:nearbyou/models/suggestions_model.dart';
import 'package:nearbyou/utilities/constants/constants.dart';
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
  final String endPoint;

  const AddPostView({Key key, this.endPoint}) : super(key: key);

  @override
  _AddPostViewState createState() => _AddPostViewState();
}

class _AddPostViewState extends State<AddPostView> {
  TextEditingController _startPointCon = TextEditingController();
  TextEditingController _endPointCon = TextEditingController();
  TextEditingController _postDescCon = TextEditingController();

  final startPointFocus = FocusNode();
  final endPointFocus = FocusNode();
  final postDescFocus = FocusNode();

  GoogleMapController googleMapController;
  LatLng _lastMapPosition = initialPosition;
  Set<Marker> _markers = HashSet<Marker>();

  @override
  void initState() {
    // TODO: implement initState
    _endPointCon.text = widget.endPoint;
    super.initState();
  }

  void _onMapCreated(GoogleMapController controller) {
    googleMapController = controller;
  }

  void _onCameraMove(CameraPosition position) {
    _lastMapPosition = position.target;
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

  void _onAddMarker(LatLng coordinates) {
    _markers.add(
      Marker(
        markerId: MarkerId(initialPosition.toString()),
        position: coordinates,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        startPointFocus.unfocus();
        endPointFocus.unfocus();
        postDescFocus.unfocus();
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          //Before closing, prompt user if want to save as draft or discard post
          leading: CloseButton(
            onPressed: () => Navigator.of(context).pop(),
            color: Colors.black,
          ),
          title: Text(
            'Create Post',
            style: TextStyle(color: Colors.black),
          ),
          actions: [
            //this should save to firestore
            IconButton(
                icon: Icon(Icons.check, color: Colors.black), onPressed: () {}),
          ],
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        // floatingActionButton: RoundedIconButton(
        //   icon: Icons.add,
        //   onPressed: () {},
        // ),
        // SpeedDialWidget(),
        body: Center(
          child: Container(
            padding: EdgeInsets.all(15),
            height: MediaQuery.of(context).size.height,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  SearchFieldContainer(
                    controller: _startPointCon,
                    focusNode: startPointFocus,
                    labelText: "Start",
                    hintText: "Choose starting point",
                    prefixIcon: Icon(
                      Icons.location_on_rounded,
                      color: textLightColor,
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(Icons.my_location),
                      color: primaryColor,
                      onPressed: () {},
                    ),
                    onTap: () async {
                      final place = await searchPlaces();
                      setState(() {
                        _startPointCon.text = place;
                      });
                    },
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  SearchFieldContainer(
                    controller: _endPointCon,
                    focusNode: endPointFocus,
                    labelText: "Destination",
                    hintText: "Choose destination point",
                    prefixIcon: Icon(
                      Icons.flag,
                      color: textLightColor,
                    ),
                    onTap: () async {
                      final place = await searchPlaces();
                      setState(() {
                        _endPointCon.text = place;
                      });
                    },
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  buildDivider(),
                  Container(
                    margin: EdgeInsets.only(left: 30, right: 30),
                    child: TextFormField(
                      focusNode: postDescFocus,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Write something here ....',
                        hintMaxLines: 4,
                      ),
                      controller: _postDescCon,
                      keyboardType: TextInputType.multiline,
                      maxLines: 3,
                    ),
                  ),
                  buildDivider(),
                  SizedBox(
                    height: 15,
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width,
                    height: 550,
                    child: buildGoogleMap(),
                  ),
                ],
              ),
            ),
          ),
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
        zoom: 15.0,
      ),
      mapType: MapType.normal,
      markers: _markers,
      onCameraMove: _onCameraMove,
      // onTap: _handleTap,
    );
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _startPointCon.dispose();
    _endPointCon.dispose();
    _postDescCon.dispose();
    super.dispose();
  }
}
