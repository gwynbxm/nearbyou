/*
 * Created by Gwyn Bong Xiao Min
 * Copyright (c) 2021. All rights reserved.
 * Last modified 15/8/21 9:00 PM
 */

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
// import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:geocoder/geocoder.dart' as geocoder;
import 'package:nearbyou/models/places_model.dart';
import 'package:nearbyou/models/route_coordinates_model.dart';
import 'package:nearbyou/models/route_marker_model.dart';
import 'package:nearbyou/models/suggestions_model.dart';
import 'package:nearbyou/utilities/constants/constants.dart';
import 'package:nearbyou/utilities/services/firebase_services/authentication.dart';
import 'package:nearbyou/utilities/services/api_services/google_places.dart';
import 'package:nearbyou/utilities/services/firebase_services/firestore.dart';
import 'package:nearbyou/utilities/ui/components/panel_widget.dart';
import 'package:nearbyou/utilities/ui/components/rounded_icon_button.dart';
import 'package:nearbyou/utilities/ui/palette.dart';
import 'package:nearbyou/views/collections/saved_collection_view.dart';
import 'package:nearbyou/views/home/components/route_marker_widget.dart';
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

  Map<MarkerId, Marker> _markers = <MarkerId, Marker>{};
  MarkerId selectedMarker;

  // List<GeoPoint> markersFromFirestore = [];

  final ScrollController scrollController = ScrollController();

  String _placeName = '';
  String _placeAdd = '';
  bool isLocationSelected = false;
  bool isDisplayed = false;
  bool isLoading = false;
  SharedPreferences sharedPreferences;
  String displayEmail;

  RouteMarker routeMarker;
  String _markerTitle = '';
  String _markerCaption = '';

  List<RouteMarker> routeMarkerList = [];
  List<String> imgList = [];

  List<RouteMarker> relatedNearbyMarkerList = [];
  bool isNearestMarkerTapped = false;
  // RouteCoordinates routeCoordinates;

  final geo = Geoflutterfire();

  @override
  void initState() {
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

  void _onAddMarker(GeoPoint coordinates) {
    _markers.clear();

    final MarkerId id = MarkerId(initialPosition.toString());
    _markers[id] = Marker(
      markerId: id,
      position: LatLng(coordinates.latitude, coordinates.longitude),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
    );
    isLocationSelected = true;
    setState(() {
      // markersOnMap.add(userMarker);
      // routeMarker = RouteMarker.withoutData(
      //     GeoPoint(coordinates.latitude, coordinates.longitude));
      GeoFirePoint geoFirePoint = geo.point(
          latitude: coordinates.latitude, longitude: coordinates.longitude);

      routeMarker = RouteMarker.withoutData(RouteCoordinates(
          geoHash: geoFirePoint.hash, geoPoint: geoFirePoint.geoPoint));

      // routeMarker = RouteMarker.withoutData(
      //     GeoPoint(coordinates.latitude, coordinates.longitude));

      // routeMarker = RouteMarker.withoutData(geoFirePoint);
      getNearbyPlaces(coordinates);
    });
  }

  void addNearestMarker(RouteMarker routeMarker) {
    // double lat = routeMarker.coordinates.latitude;
    // double lng = routeMarker.coordinates.longitude;

    double lat = routeMarker.coordinates.geoPoint.latitude;
    double lng = routeMarker.coordinates.geoPoint.longitude;

    MarkerId id = MarkerId(routeMarker.markerID);
    final Marker marker = Marker(
        markerId: id,
        position: LatLng(lat, lng),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
        onTap: () => _onNearestMarkerTapped(id));

    setState(() {
      isLocationSelected = true;
      _markers[id] = marker;
    });
  }

  Future<void> animateCamera(GeoPoint position) async {
    final GoogleMapController googleMapController = await _completer.future;
    googleMapController.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(position.latitude, position.longitude),
          zoom: 18,
        ),
      ),
    );
  }

  void _getUserCurrentLocation() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    // LatLng currLatLngPosition = LatLng(position.latitude, position.longitude);

    GeoPoint currPosition = GeoPoint(position.latitude, position.longitude);

    setState(() {
      _getDetailsFromCoordinates(position.latitude, position.longitude);
      _onAddMarker(currPosition);
      animateCamera(currPosition);
      getNearbyPlaces(currPosition);
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
        // TODO: feature name retrieved from geocoder is different from google places
        _searchCon.text = result.placeName;
        panelController.open();
        isLocationSelected = true;
        isNearestMarkerTapped = false;
        _placeName = placesDetails.placeName;
        _placeAdd = placesDetails.placeAddress;
        _getPlacesDetailsFromSearch(placesDetails);
      });
    }
  }

  void _getPlacesDetailsFromSearch(Places places) async {
    var lat = places.geometry.locationData.lat;
    var lng = places.geometry.locationData.lng;

    GeoPoint coordinates = GeoPoint(lat, lng);
    // LatLng coordinates = LatLng(lat, lng);

    setState(() {
      _onAddMarker(coordinates);
      animateCamera(coordinates);
      getNearbyPlaces(coordinates);
    });
  }

  void clearSearch() {
    _searchCon.clear();
    _markers.clear();
    isLocationSelected = false;
    isNearestMarkerTapped = false;
    panelController.close();
  }

  Future<void> _onMapTapped(LatLng point) async {
    final coordinates = GeoPoint(point.latitude, point.longitude);
    setState(() {
      _getDetailsFromCoordinates(point.latitude, point.longitude);
      _onAddMarker(coordinates);
      animateCamera(coordinates);
      getNearbyPlaces(coordinates);
      isNearestMarkerTapped = false;
    });
  }

  _getDetailsFromCoordinates(double lat, double lng) async {
    // double lat = point.latitude;
    // double lng = point.longitude;

    final coordinates = geocoder.Coordinates(lat, lng);
    // Coordinates coordinates = Coordinates(lat, lng);

    var address =
        await geocoder.Geocoder.local.findAddressesFromCoordinates(coordinates);

    setState(() {
      // TODO: feature name retrieved from geocoder is different from google places
      _placeName = address.first.featureName;
      _placeAdd = address.first.addressLine;
      _searchCon.text = address.first.featureName;
    });
  }

  void createPost() {
    isLocationSelected
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
                      currentUser: _auth.currentUser.uid.toString(),
                    )),
          );
  }

  void togglePanel() => panelController.isPanelOpen
      ? panelController.close()
      : panelController.open();

  // retrieve markers from firestore that is nearby the center coordinates
  void getNearbyPlaces(GeoPoint center) async {
    final result = await DatabaseServices.getNearbyFBMarkers(center);
    // final result = await DatabaseServices.getNearby(center);
    for (int i = 0; i < result.length; i++) {
      final MarkerId id = MarkerId(result[i].markerID);
      addNearestMarker(result[i]);
    }
  }

  // on tap nearest route marker
  void _onNearestMarkerTapped(MarkerId markerId) {
    final Marker tappedMarker = _markers[markerId];
    if (tappedMarker != null) {
      setState(() {
        isNearestMarkerTapped = true;
        final MarkerId previousMarkerId = selectedMarker;
        if (previousMarkerId != null &&
            _markers.containsKey(previousMarkerId)) {
          final Marker resetOld = _markers[previousMarkerId].copyWith(
              iconParam: BitmapDescriptor.defaultMarkerWithHue(
                  BitmapDescriptor.hueOrange));
          _markers[previousMarkerId] = resetOld;
        }
        selectedMarker = markerId;
        final Marker newMarker = tappedMarker.copyWith(
            iconParam: BitmapDescriptor.defaultMarkerWithHue(
                BitmapDescriptor.hueGreen),
            onTapParam: () => _getDetailsFromFirestore(GeoPoint(
                tappedMarker.position.latitude,
                tappedMarker.position.longitude)));

        _markers[markerId] = newMarker;
      });
    }

    setState(() {
      _getDetailsFromCoordinates(
          tappedMarker.position.latitude, tappedMarker.position.longitude);
    });
  }

  // get nearest post marker details of the same coordinates from firestore to display on sliding panel
  _getDetailsFromFirestore(GeoPoint points) async {
    QuerySnapshot snapshot = await postMarkersCollection
        .where('position.geopoint', isEqualTo: points)
        .get();

    setState(() {
      isNearestMarkerTapped = true;
      relatedNearbyMarkerList =
          snapshot.docs.map((doc) => RouteMarker.fromDocument(doc)).toList();
    });
  }

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
                  child: buildInformation(context),
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
                            suffixIcon: isLocationSelected
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

  Container buildInformation(BuildContext context) {
    return isLocationSelected
        ?
        // Column(
        //         mainAxisSize: MainAxisSize.min,
        //         children: [
        //           Wrap(
        //             children: [
        //               Row(
        //                 children: [
        //                   Expanded(
        //                     flex: 3,
        //                     child: Padding(
        //                         padding:
        //                             EdgeInsets.only(top: 10, left: 30, right: 30),
        //                         child: SingleChildScrollView(
        //                           child: Column(
        //                             children: [
        //                               Align(
        //                                 alignment: Alignment.centerLeft,
        //                                 child: Text(
        //                                   '$_placeName',
        //                                   style: TextStyle(
        //                                     fontWeight: FontWeight.bold,
        //                                     fontSize: 24,
        //                                   ),
        //                                 ),
        //                               ),
        //                               SizedBox(
        //                                 height: 10,
        //                               ),
        //                               Align(
        //                                 alignment: Alignment.centerLeft,
        //                                 child: Text(
        //                                   '$_placeAdd',
        //                                   style: TextStyle(fontSize: 15),
        //                                 ),
        //                               ),
        //                             ],
        //                           ),
        //                         )),
        //                   ),
        //                   buildPostButton(context),
        //                 ],
        //               ),
        //             ],
        //           ),
        //           SizedBox(
        //             width: 15,
        //             height: 15,
        //           ),
        //           Divider(
        //             thickness: 1,
        //             indent: 30,
        //             endIndent: 30,
        //           ),
        //           SizedBox(
        //             width: 15,
        //             height: 15,
        //           ),
        //           Flexible(
        //             child: Container(
        //                 //place timeline of post
        //                 // child: StreamBuilder<QuerySnapshot>(
        //                 //   stream: DatabaseServices.getNearbyMarkers(),
        //                 //   builder: (context, snapshot) {
        //                 //     if (!snapshot.hasData) {
        //                 //       return Container(
        //                 //           alignment: FractionalOffset.center,
        //                 //           child: CircularProgressIndicator());
        //                 //     }
        //                 //     return Container();
        //                 //   },
        //                 // ),
        //                 ),
        //           )
        //         ],
        //       )
        Container(
            child: Stack(
              children: [
                Container(
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Padding(
                                padding: EdgeInsets.only(
                                    top: 10, left: 30, right: 30),
                                child: buildPlaceNameAndAdd(context)),
                            flex: 3,
                          ),
                          buildPostButton(context),
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
                    ],
                  ),
                ),
                isNearestMarkerTapped
                    ? Container(
                        margin: EdgeInsets.only(top: 110),
                        child: SingleChildScrollView(
                          child: ListView.builder(
                            controller: scrollController,
                            physics: NeverScrollableScrollPhysics(),
                            primary: false,
                            scrollDirection: Axis.vertical,
                            shrinkWrap: true,
                            itemCount: relatedNearbyMarkerList.length,
                            itemBuilder: (context, index) {
                              return RouteMarkerWidget(
                                  relatedNearbyMarkerList[index]);
                            },
                          ),
                          // buildRouteInfo(context),
                        ),
                      )
                    : Container(
                        margin: EdgeInsets.symmetric(vertical: 200),
                        child: Center(
                          child: Text(
                            "No related marker found",
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 18.0,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                        ),
                      )
              ],
            ),
          )
        : Container(
            child: Column(
              children: [
                Wrap(
                  children: [
                    buildStartingSlideUpInfo(context),
                  ],
                ),
              ],
            ),
          );
  }

  Column buildPlaceNameAndAdd(BuildContext context) {
    return Column(
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
    final MarkerId selectedId = selectedMarker;
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
      // markers: _marker,
      markers: Set<Marker>.of(_markers.values),
      onCameraMove: _onCameraMove,
      onTap: _onMapTapped,
    );
  }

  Drawer buildDrawer(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: ListView(
          children: [
            // FutureBuilder(
            //   future: DatabaseServices.getUser(_auth.currentUser.uid),
            //   builder: (context, snapshot) {
            //     if (!snapshot.hasData) {
            //       return Container(
            //           alignment: FractionalOffset.center,
            //           child: CircularProgressIndicator());
            //     }
            //
            //     UserData userData = UserData.fromDocument(snapshot.data);
            //     return UserAccountsDrawerHeader(
            //       currentAccountPicture: CircleAvatar(
            //         backgroundColor: Colors.white,
            //         backgroundImage: userData?.profilePhoto?.isEmpty ?? true
            //             ? AssetImage('assets/images/default-profile.png')
            //             : NetworkImage(userData.profilePhoto),
            //       ),
            //       accountName: Text(userData.username),
            //       accountEmail: Text(userData.emailAddress),
            //       arrowColor: Colors.white,
            //       onDetailsPressed: () {},
            //       decoration: BoxDecoration(
            //           color: bgColor,
            //           borderRadius: BorderRadius.only(
            //               bottomLeft: Radius.circular(20),
            //               bottomRight: Radius.circular(20))),
            //     );
            //   },
            // ),
            UserAccountsDrawerHeader(
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white,
                backgroundImage: _auth.currentUser.photoURL.isEmpty ?? true
                    ? AssetImage('assets/images/default-profile.png')
                    : NetworkImage(_auth.currentUser.photoURL),
              ),
              accountName: Text(_auth.currentUser
                  .displayName), // TODO: Resolve the problem of google sign-in & email sign-in displayname/username issue
              accountEmail: Text(_auth.currentUser.email),
              arrowColor: Colors.white,
              onDetailsPressed: () {},
              decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(20),
                      bottomRight: Radius.circular(20))),
            ),
            DrawerItem(
                icon: Icons.person_outline_outlined,
                text: 'Profile',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ProfileView(
                            userId: _auth.currentUser.uid.toString())),
                  );
                }),
            DrawerItem(
              icon: Icons.chat_outlined,
              text: 'Chat',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SavedCollectionView()),
              ),
              // Navigator.pushReplacementNamed(context, '/collections'),
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
            DrawerItem(
                icon: Icons.logout,
                text: 'Log Out',
                onTap: () async {
                  sharedPreferences.remove('email');
                  sharedPreferences.setBool('login', true);
                  await Auth().signOut();
                  Navigator.popAndPushNamed(context, '/login');
                  // Navigator.pop(context);
                }),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchCon.dispose();
    googleMapController.dispose();
    super.dispose();
  }
}
