/*
 * Created by Gwyn Bong Xiao Min
 * Copyright (c) 2021. All rights reserved.
 * Last modified 16/7/21 3:51 PM
 */

import 'dart:async';
import 'dart:collection';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:material_floating_search_bar/material_floating_search_bar.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:geocoder/geocoder.dart';
import 'package:nearbyou/models/places_model.dart';
import 'package:nearbyou/models/suggestions_model.dart';
import 'package:nearbyou/models/user_profile_model.dart';
import 'package:nearbyou/utilities/services/firebase_services/authentication.dart';
import 'package:nearbyou/utilities/services/api_services/google_places.dart';
import 'package:nearbyou/utilities/services/firebase_services/firestore.dart';
import 'package:nearbyou/utilities/ui/components/panel_widget.dart';
import 'package:nearbyou/utilities/ui/components/rounded_icon_button.dart';
import 'package:nearbyou/utilities/ui/palette.dart';
import 'package:nearbyou/views/posting/add_post_view.dart';
import 'package:nearbyou/views/home/components/address_search.dart';
import 'package:nearbyou/views/profile/user_profile_view.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:uuid/uuid.dart';

import 'components/drawer_item.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final panelController = PanelController();
  static const double fabHeightClosed = 160.0;
  double fabHeight = fabHeightClosed;

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  FloatingSearchBarController searchBarCon = FloatingSearchBarController();
  final _searchCon = TextEditingController();

  var geoLocator = Geolocator();
  GoogleMapController googleMapController;

  static const LatLng _center = const LatLng(1.3649170, 103.8228720);
  LatLng _lastMapPosition = _center;
  Set<Marker> _markers = HashSet<Marker>();

  final ScrollController scrollController = ScrollController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    // getCurrentUser();
    locatePosition();
    getCurrentUser();
  }

  // User cUser;
  // void getCurrentUser() {
  //   User currentUser = FirebaseAuth.instance.currentUser;
  //   if (currentUser != null) {
  //     setState(() {
  //       cUser = currentUser;
  //     });
  //   }
  // }

  SharedPreferences sharedPreferences;
  String displayEmail;

  getCurrentUser() async {
    sharedPreferences = await SharedPreferences.getInstance();
    setState(() {
      displayEmail = sharedPreferences.getString('email');
    });
  }

  void _onMapCreated(GoogleMapController controller) {
    googleMapController = controller;
  }

  void _onCameraMove(CameraPosition position) {
    _lastMapPosition = position.target;
  }

  void _onAddMarker(LatLng coordinates) {
    //always clear existing markers in order to add new marker
    _markers.clear();
    _markers.add(
      Marker(
        markerId: MarkerId(_center.toString()),
        position: coordinates,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
      ),
    );
    selectedLocation = true;
  }

  void locatePosition() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    LatLng currLatLngPosition = LatLng(position.latitude, position.longitude);

    CameraPosition cameraPosition =
        new CameraPosition(target: currLatLngPosition, zoom: 14);

    setState(() {
      _onAddMarker(currLatLngPosition);
      googleMapController
          .animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
    });
  }

  void _handleTap(LatLng point) {
    setState(() {
      _onAddMarker(point);
    });
  }

  bool selectedLocation = false;
  String _placeName = '';
  String _placeAdd = '';

  void _goToPlace(Places places) async {
    var lat = places.geometry.locationData.lat;
    var lng = places.geometry.locationData.lng;

    LatLng coordinates = LatLng(lat, lng);

    setState(() {
      _onAddMarker(coordinates);
      googleMapController.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: coordinates, zoom: 14.0),
        ),
      );
    });
  }

  void _searchPlace() async {
    final sessionToken = Uuid().v4();
    final Suggestions result = await showSearch(
      context: context,
      delegate: PlacesSearch(sessionToken),
    );
    if (result != null) {
      final placesDetails =
          await PlaceApiProvider(sessionToken).getPlacesDetails(result.placeId);

      setState(() {
        _searchCon.text = result.placeDesc;
        panelController.open();
        selectedLocation = true;
        _placeName = placesDetails.placeName;
        _placeAdd = placesDetails.placeAddress;
        _goToPlace(placesDetails);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final panelHeightOpen = MediaQuery.of(context).size.height * 0.6;
    final panelHeightClosed = MediaQuery.of(context).size.height * 0.15;
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        key: _scaffoldKey,
        drawer: buildDrawer(context),
        body: Stack(
          children: [
            SlidingUpPanel(
              body: buildGoogleMap(),
              controller: panelController,
              minHeight: panelHeightClosed,
              maxHeight: panelHeightOpen,
              parallaxEnabled: true,
              parallaxOffset: .5,
              panelBuilder: (controller) => PanelWidget(
                controller: controller,
                panelController: panelController,
                child: buildPostFeed(context),
              ),
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(18),
              ),
              onPanelSlide: (position) => setState(() {
                final panelMaxScrollExtent =
                    panelHeightOpen - panelHeightClosed;
                fabHeight = position * panelMaxScrollExtent + fabHeightClosed;
              }),
            ),
            Positioned(
              right: 20,
              bottom: fabHeight,
              child: RoundedIconButton(
                onPressed: locatePosition,
                icon: Icons.my_location,
              ),
            ),
            SafeArea(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(29),
                ),
                margin: EdgeInsets.all(16),
                child: Row(
                  children: [
                    IconButton(
                        padding: EdgeInsets.only(left: 10),
                        color: Colors.black,
                        icon: Icon(Icons.menu),
                        onPressed: () =>
                            _scaffoldKey.currentState.openDrawer()),
                    Expanded(
                      child: TextField(
                        keyboardType: TextInputType.text,
                        controller: _searchCon,
                        readOnly: true,
                        onTap: _searchPlace,
                        decoration: InputDecoration(
                          hintText: "Search ....",
                          hintStyle: TextStyle(color: Colors.grey),
                          suffixIcon: selectedLocation
                              ? IconButton(
                                  onPressed: () {
                                    _searchCon.clear();
                                    _markers.clear();
                                    selectedLocation = false;
                                    panelController.close();
                                  },
                                  icon: Icon(Icons.clear),
                                )
                              : null,
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(vertical: 15),
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(right: 8),
                      child: IconButton(
                        icon: Icon(Icons.filter_alt_outlined),
                        color: Colors.black,
                        onPressed: () {},
                      ),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Column buildPostFeed(BuildContext context) {
    return selectedLocation
        ? Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: 65,
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      flex: 3,
                      child: Padding(
                          padding:
                              EdgeInsets.only(top: 10, left: 30, right: 30),
                          child: Column(
                            children: [
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  '$_placeName',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 24,
                                  ),
                                ),
                              ),
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  '$_placeAdd',
                                  style: TextStyle(fontSize: 15),
                                ),
                              ),
                            ],
                          )),
                    ),
                    buildPostButton(context),
                  ],
                ),
              ),
              Divider(
                height: 1,
                color: primaryColor,
              ),
              Flexible(
                child: Container(
                  child: ListView.builder(
                      controller: scrollController,
                      physics: AlwaysScrollableScrollPhysics(),
                      primary: false,
                      scrollDirection: Axis.vertical,
                      // separatorBuilder: (context, index) => Divider(
                      //       height: 0.5,
                      //     ),
                      shrinkWrap: true,
                      itemCount: 10,
                      itemBuilder: (BuildContext context, int index) =>
                          buildCards(context, index)),
                ),
              )
            ],
          )
        : Column(
            children: [
              Container(
                height: 100,
                child: buildStartingSlideUpInfo(context),
              ),
            ],
          );
  }

  Row buildStartingSlideUpInfo(BuildContext context) {
    return Row(
      // mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          flex: 3,
          child: Padding(
            padding: EdgeInsets.only(left: 30, right: 30),
            child: Text(
              'Create & share your very own shortcuts with Nearbyou! >>>',
              style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: primaryDarkColor),
            ),
          ),
        ),
        buildPostButton(context),
      ],
    );
  }

  Expanded buildPostButton(BuildContext context) {
    return Expanded(
      flex: 1,
      child: RoundedIconButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => AddPostView()),
        ),
        icon: Icons.add_location_alt,
      ),
    );
  }

  GoogleMap buildGoogleMap() {
    return GoogleMap(
      onMapCreated: _onMapCreated,
      myLocationButtonEnabled: false,
      myLocationEnabled: false,
      // shows user location
      zoomGesturesEnabled: true,
      zoomControlsEnabled: false,
      mapToolbarEnabled: false,
      initialCameraPosition: CameraPosition(
        target: _center,
        zoom: 11.0,
      ),
      mapType: MapType.normal,
      // google map type: satellite/hybrid/normal/terrain
      markers: _markers,
      onCameraMove: _onCameraMove,
      onTap: _handleTap,
    );
  }

  Drawer buildDrawer(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: ListView(
          children: [
            FutureBuilder(
              future: DatabaseServices.getUser(_auth.currentUser.uid),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Container(
                      alignment: FractionalOffset.center,
                      child: CircularProgressIndicator());
                }

                UserProfile userProfile =
                    UserProfile.fromDocument(snapshot.data);
                return UserAccountsDrawerHeader(
                  currentAccountPicture: CircleAvatar(
                    backgroundColor: Colors.white,
                  ),
                  accountName: Text(userProfile.username),
                  accountEmail: Text(displayEmail),
                  arrowColor: Colors.white,
                  onDetailsPressed: () {},
                  decoration: BoxDecoration(
                      color: bgColor,
                      borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(20),
                          bottomRight: Radius.circular(20))),
                );
              },
            ),
            // UserAccountsDrawerHeader(
            //   currentAccountPicture: CircleAvatar(
            //     backgroundColor: Colors.white,
            //   ),
            //   accountName: Text('gwyn'),
            //   accountEmail: Text(displayEmail),
            //   arrowColor: Colors.white,
            //   onDetailsPressed: () {},
            //   decoration: BoxDecoration(
            //       color: bgColor,
            //       borderRadius: BorderRadius.only(
            //           bottomLeft: Radius.circular(20),
            //           bottomRight: Radius.circular(20))),
            // ),
            DrawerItem(
              icon: Icons.person_outline_outlined,
              text: 'Profile',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ProfileView()),
              ),
            ),
            // DrawerItem(
            //   icon: Icons.star_border_outlined,
            //   text: 'Feed',
            //   onTap: () {},
            // ),
            DrawerItem(
              icon: Icons.bookmark_border_outlined,
              text: 'Saved Collections',
              onTap: () =>
                  Navigator.pushReplacementNamed(context, '/collections'),
            ),
            Divider(
              height: 20,
              thickness: 1,
              indent: 20,
              endIndent: 20,
            ),
            DrawerItem(
              icon: Icons.add_alert_outlined,
              text: 'Notifications',
              onTap: () =>
                  Navigator.pushReplacementNamed(context, '/notifications'),
            ),
            DrawerItem(
              icon: Icons.settings_outlined,
              text: 'Settings',
              onTap: () => Navigator.pushReplacementNamed(context, '/settings'),
            ),
            Divider(
              height: 20,
              thickness: 1,
              indent: 20,
              endIndent: 20,
            ),
            DrawerItem(
              icon: Icons.info_outline,
              text: 'About Nearbyou',
            ),
            DrawerItem(
                icon: Icons.logout,
                text: 'Log Out',
                onTap: () async {
                  sharedPreferences.remove('email');
                  sharedPreferences.setBool('login', true);
                  await Auth().signOut();
                  Navigator.popAndPushNamed(context, '/login');
                }),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    // TODO: implement dispose
    // _searchCon.dispose();
    searchBarCon.dispose();
    googleMapController.dispose();
    super.dispose();
  }

  buildCards(BuildContext context, int index) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 20.0, right: 15.0),
              child: CircleAvatar(
                radius: 24,
                backgroundImage:
                    AssetImage('assets/images/default-profile.png'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
