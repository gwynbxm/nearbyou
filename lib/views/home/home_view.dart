/*
 * Created by Gwyn Bong Xiao Min
 * Copyright (c) 2021. All rights reserved.
 * Last modified 2/6/21 3:22 PM
 */

import 'dart:async';
import 'dart:collection';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:material_floating_search_bar/material_floating_search_bar.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
// import 'package:geocoder/geocoder.dart';
import 'package:nearbyou/models/suggestions_model.dart';
import 'package:nearbyou/utilities/services/database_services/authentication.dart';
import 'package:nearbyou/utilities/services/api_services/place_services.dart';
import 'package:nearbyou/views/home/components/address_search.dart';
import 'package:uuid/uuid.dart';

// class HomeView extends StatelessWidget {
//   const HomeView({Key key}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//         debugShowCheckedModeBanner: false,
//         home: Scaffold(
//           // appBar: AppBar(
//           //   title: Text('Home'),
//           //   backgroundColor: Colors.red,
//           // ),
//           body: HomeScreen(),
//         ));
//   }
// }

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  User cUser;

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  FloatingSearchBarController searchBarCon = FloatingSearchBarController();

  // Position currPosition;
  var geoLocator = Geolocator();
  GoogleMapController googleMapController;

  // Completer<GoogleMapController> _gMapCon = Completer();
  static const LatLng _center = const LatLng(1.3649170, 103.8228720);
  LatLng _lastMapPosition = _center;
  Set<Marker> _markers = HashSet<Marker>();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    getCurrentUser();
    locatePosition();
  }

  void getCurrentUser() {
    User currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      setState(() {
        cUser = currentUser;
      });
    }
  }

  //create map
  void _onMapCreated(GoogleMapController controller) {
    googleMapController = controller;
    // _gMapCon.complete(controller);
    // _onAddMarker();
    // locatePosition();
  }

  void _onCameraMove(CameraPosition position) {
    _lastMapPosition = position.target;
  }

  void _onAddMarker() {
    _markers.add(
      Marker(
        markerId: MarkerId(_center.toString()),
        position: _center,
        infoWindow: InfoWindow(title: 'Singapore', snippet: 'Little Red Dot'),
        icon: BitmapDescriptor.defaultMarker,
      ),
    );
  }

  void locatePosition() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    // currPosition = position;

    LatLng latLngPosition = LatLng(position.latitude, position.longitude);

    CameraPosition cameraPosition =
        new CameraPosition(target: latLngPosition, zoom: 14);

    setState(() {
      googleMapController
          .animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
          key: _scaffoldKey,
          drawer: buildDrawer(context),
          body: Stack(
            children: [
              buildGoogleMap(),
              FloatingSearchBar(
                hint: 'Search here',
                controller: searchBarCon,
                // width: 300,
                onFocusChanged: (query) async {
                  // final sessionToken = Uuid().v4();
                  // final Suggestions result = (await showSearch(
                  //   context: context,
                  //   delegate: PlacesSearch(sessionToken),
                  // ))!;
                  // final placeDetails = await PlaceApiProvider(sessionToken)
                  //     .getPlaceDetailFromId(result.placeId);
                  // setState(() {});
                },
                onQueryChanged: (query) async {},
                transition: CircularFloatingSearchBarTransition(),
                actions: [
                  FloatingSearchBarAction(
                    showIfOpened: false,
                    child: CircularButton(
                      icon: const Icon(Icons.search),
                      onPressed: () {},
                    ),
                  ),
                  FloatingSearchBarAction.searchToClear(
                    showIfClosed: false,
                  ),
                  IconButton(
                    icon: Icon(Icons.chat),
                    color: Colors.blueAccent,
                    onPressed: () {},
                  ),
                ],
                builder: (context, transition) {
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Material(
                      color: Colors.white,
                      child: Container(
                        child: Column(
                          children: [
                            ListTile(
                              title: Text('Name of Place'),
                              subtitle: Text('Place address'),
                            )
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          )),
    );
  }

  GoogleMap buildGoogleMap() {
    return GoogleMap(
      onMapCreated: _onMapCreated,
      myLocationButtonEnabled: true,
      myLocationEnabled: true, // shows user location
      zoomGesturesEnabled: true,
      zoomControlsEnabled: true,
      mapToolbarEnabled: false,
      initialCameraPosition: CameraPosition(
        target: _center,
        zoom: 11.0,
      ),
      mapType:
          MapType.normal, // google map type: satellite/hybrid/normal/terrain
      markers: _markers,
      onCameraMove: _onCameraMove,
    );
  }

  Drawer buildDrawer(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: ListView(
          children: [
            UserAccountsDrawerHeader(
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white,
              ),
              accountName: (Text('Gwyn')),
              accountEmail: Text(cUser.email),
              arrowColor: Colors.white,
              onDetailsPressed: () {},
              decoration: BoxDecoration(
                  color: Colors.blue[300],
                  borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(20),
                      bottomRight: Radius.circular(20))),
            ),
            _drawerItem(
              icon: Icons.star_border_outlined,
              text: 'My Shortcuts',
              // pushReplacementNamed will replace current route of navigator
              // that tightly encloses the given context by pushing the given
              // route and then disposing previous route once the new route
              // finishes animating in
              onTap: () => Navigator.pushReplacementNamed(context, '/shortcut'),
            ),
            _drawerItem(
              icon: Icons.people_alt_outlined,
              text: 'Friends',
              onTap: () => Navigator.pushReplacementNamed(context, '/friends'),
            ),
            _drawerItem(
              icon: Icons.bookmark_border_outlined,
              text: 'Saved Collections',
              onTap: () =>
                  Navigator.pushReplacementNamed(context, '/collections'),
            ),
            Divider(
              height: 20,
              thickness: 2,
              indent: 20,
              endIndent: 20,
            ),
            _drawerItem(
              icon: Icons.settings_outlined,
              text: 'Settings',
              onTap: () => Navigator.pushReplacementNamed(context, '/settings'),
            ),
            _drawerItem(
              icon: Icons.add_alert_outlined,
              text: 'Notifications',
              onTap: () =>
                  Navigator.pushReplacementNamed(context, '/notifications'),
            ),
            Divider(
              height: 20,
              thickness: 2,
              indent: 20,
              endIndent: 20,
            ),
            _drawerItem(
                icon: Icons.logout,
                text: 'Log Out',
                onTap: () async {
                  await Auth().signOut();
                  Navigator.popAndPushNamed(context, '/login');
                }),
          ],
        ),
      ),
    );
  }

  Widget _drawerItem({IconData icon, String text, GestureTapCallback onTap}) {
    return ListTile(
      title: Row(
        children: [
          Icon(icon),
          Padding(
            padding: EdgeInsets.only(left: 8.0),
            child: Text(text),
          )
        ],
      ),
      onTap: onTap,
    );
  }

  @override
  void dispose() {
    // TODO: implement dispose
    searchBarCon.dispose();
    super.dispose();
  }
}
