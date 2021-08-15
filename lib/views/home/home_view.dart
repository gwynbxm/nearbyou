/*
 * Created by Gwyn Bong Xiao Min
 * Copyright (c) 2021. All rights reserved.
 * Last modified 15/8/21 9:00 PM
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
import 'package:nearbyou/models/geometry_model.dart';
import 'package:nearbyou/models/places_model.dart';
import 'package:nearbyou/models/route_marker_model.dart';
import 'package:nearbyou/models/suggestions_model.dart';
import 'package:nearbyou/models/user_profile_model.dart';
import 'package:nearbyou/utilities/constants/constants.dart';
import 'package:nearbyou/utilities/services/firebase_services/authentication.dart';
import 'package:nearbyou/utilities/services/api_services/google_places.dart';
import 'package:nearbyou/utilities/services/firebase_services/firestore.dart';
import 'package:nearbyou/utilities/ui/components/panel_widget.dart';
import 'package:nearbyou/utilities/ui/components/rounded_icon_button.dart';
import 'package:nearbyou/utilities/ui/palette.dart';
import 'package:nearbyou/views/home/route_details_view.dart';
import 'package:nearbyou/views/posting/add_post_view.dart';
import 'package:nearbyou/views/home/components/address_search.dart';
import 'package:nearbyou/views/profile/user_profile_view.dart';
import 'package:nearbyou/views/settings/main_settings_view.dart';
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
  static const double fabHeightClosed = 135.0;
  double fabHeight = fabHeightClosed;

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  // FloatingSearchBarController searchBarCon = FloatingSearchBarController();
  final _searchCon = TextEditingController();
  final searchLocFocus = FocusNode();

  var geoLocator = Geolocator();
  GoogleMapController googleMapController;
  Completer<GoogleMapController> _completer = Completer();

  static const LatLng initialPosition = const LatLng(1.3649170, 103.8228720);
  LatLng _lastMapPosition = initialPosition;
  Set<Marker> _markers = Set<Marker>();

  final ScrollController scrollController = ScrollController();

  String _placeName = '';
  String _placeAdd = '';
  bool selectedLocation = false;
  SharedPreferences sharedPreferences;
  String displayEmail;

  RouteMarker routeMarker;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    // getCurrentUser();
    _getUserCurrentLocation();
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

  getCurrentUser() async {
    sharedPreferences = await SharedPreferences.getInstance();
    setState(() {
      displayEmail = sharedPreferences.getString('email');
    });
  }

  void _onMapCreated(GoogleMapController controller) {
    _completer.complete(controller);
    googleMapController = controller;
  }

  void _onCameraMove(CameraPosition position) {
    _lastMapPosition = position.target;
  }

  void _onAddMarker(LatLng coordinates) {
    _markers.clear();
    _markers.add(
      Marker(
        markerId: MarkerId(initialPosition.toString()),
        position: coordinates,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
      ),
    );
    selectedLocation = true;
    setState(() {
      routeMarker = RouteMarker.withoutData(coordinates);
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

  void _getUserCurrentLocation() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    LatLng currLatLngPosition = LatLng(position.latitude, position.longitude);

    setState(() {
      _getDetailsFromCoordinates(currLatLngPosition);
      _onAddMarker(currLatLngPosition);
      animateCamera(currLatLngPosition);
      // _getNearbyFeeds(currLatLngPosition);
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
        _getPlacesDetailsFromSearch(placesDetails);
      });
    }
  }

  void _getPlacesDetailsFromSearch(Places places) async {
    var lat = places.geometry.locationData.lat;
    var lng = places.geometry.locationData.lng;

    LatLng coordinates = LatLng(lat, lng);

    setState(() {
      _onAddMarker(coordinates);
      animateCamera(coordinates);
      // _getNearbyFeeds(coordinates);
    });
  }

  void clearSearch() {
    _searchCon.clear();
    _markers.clear();
    selectedLocation = false;
    panelController.close();
  }

  Future<void> _handleTap(LatLng point) async {
    setState(() {
      _getDetailsFromCoordinates(point);
      _onAddMarker(point);
      animateCamera(point);
      // _getNearbyFeeds(point);
    });
  }

  void _getDetailsFromCoordinates(LatLng point) async {
    double lat = point.latitude;
    double lng = point.longitude;

    Coordinates coordinates = Coordinates(lat, lng);

    var address =
        await Geocoder.local.findAddressesFromCoordinates(coordinates);

    setState(() {
      _placeName = address.first.featureName;
      _placeAdd = address.first.addressLine;
      _searchCon.text = address.first.addressLine;
    });
  }

  void createPost() {
    selectedLocation
        ? Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => AddPostView(
                      destPointData: routeMarker,
                      currentUser: _auth.currentUser.uid,
                    )),
          )
        : Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => AddPostView(
                      currentUser: _auth.currentUser.uid,
                    )),
          );
  }

  // _getNearbyFeeds() async {
  //   Stream<List<DocumentSnapshot>> stream = ;
  // }

  void togglePanel() => panelController.isPanelOpen
      ? panelController.close()
      : panelController.open();

  @override
  Widget build(BuildContext context) {
    final panelHeightOpen = MediaQuery.of(context).size.height * 0.65;
    final panelHeightClosed = MediaQuery.of(context).size.height * 0.13;
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: GestureDetector(
        onTap: () {
          searchLocFocus.unfocus();
        },
        child: Scaffold(
          key: _scaffoldKey,
          drawer: buildDrawer(context),
          resizeToAvoidBottomInset: false,
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
                  onTap: () => togglePanel(),
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
                right: 25,
                bottom: fabHeight,
                child: RoundedIconButton(
                  onPressed: _getUserCurrentLocation,
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
                          color: textLightColor,
                          icon: Icon(Icons.menu),
                          onPressed: () {
                            _scaffoldKey.currentState.openDrawer();
                            // if (panelController.isPanelOpen) {
                            //   panelController.close();
                            // }
                          }),
                      Expanded(
                        child: TextField(
                          keyboardType: TextInputType.text,
                          controller: _searchCon,
                          readOnly: true,
                          focusNode: searchLocFocus,
                          onTap: _searchPlace,
                          decoration: InputDecoration(
                            hintText: "Search ....",
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
                                horizontal: 10, vertical: 15),
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(right: 8),
                        child: IconButton(
                          icon: Icon(Icons.filter_alt_outlined),
                          color: textLightColor,
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
      ),
    );
  }

  Column buildPostFeed(BuildContext context) {
    return selectedLocation
        ? Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Wrap(
                children: [
                  Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: Padding(
                            padding:
                                EdgeInsets.only(top: 10, left: 30, right: 30),
                            child: SingleChildScrollView(
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
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      '$_placeAdd',
                                      style: TextStyle(fontSize: 15),
                                    ),
                                  ),
                                ],
                              ),
                            )),
                      ),
                      buildPostButton(context),
                    ],
                  ),
                ],
              ),
              SizedBox(
                width: 15,
                height: 15,
              ),
              Divider(
                thickness: 1,
                indent: 30,
                endIndent: 30,
              ),
              SizedBox(
                width: 15,
                height: 15,
              ),
              Flexible(
                child: Container(),
              )
            ],
          )
        : Column(
            children: [
              Wrap(
                children: [
                  buildStartingSlideUpInfo(context),
                ],
              ),
            ],
          );
  }

  Row buildStartingSlideUpInfo(BuildContext context) {
    return Row(
      // mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
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
        onPressed: createPost,
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
        target: initialPosition,
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

                UserData userData = UserData.fromDocument(snapshot.data);
                return UserAccountsDrawerHeader(
                  currentAccountPicture: CircleAvatar(
                    backgroundColor: Colors.white,
                    backgroundImage: userData?.profilePhoto?.isEmpty ?? true
                        ? AssetImage('assets/images/default-profile.png')
                        : NetworkImage(userData.profilePhoto),
                  ),
                  accountName: Text(userData.username),
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
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => MainSettingsView()),
              ),
            ),
            Divider(
              height: 20,
              thickness: 1,
              indent: 20,
              endIndent: 20,
            ),
            // DrawerItem(
            //   icon: Icons.info_outline,
            //   text: 'Help ',
            // ),
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
    // searchBarCon.dispose();
    _searchCon.dispose();
    googleMapController.dispose();
    super.dispose();
  }
}
