/*
 * Created by Gwyn Bong Xiao Min
 * Copyright (c) 2021. All rights reserved.
 * Last modified 1/11/21 10:46 AM
 */

import 'dart:convert';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:nearbyou/models/route_marker_model.dart';
import 'package:nearbyou/models/route_post_model.dart';
import 'package:nearbyou/utilities/constants/constants.dart';
import 'package:nearbyou/utilities/ui/components/custom_dialog_box.dart';
import 'package:nearbyou/utilities/ui/components/progress_icon.dart';
import 'package:nearbyou/utilities/ui/components/image_full_view.dart';
import 'package:nearbyou/views/profile/components/profile_carousel_widget.dart';

class RoutePostWidget extends StatefulWidget {
  final User user;
  final RoutePost post;

  const RoutePostWidget(this.user, this.post);

  @override
  _RoutePostWidgetState createState() => _RoutePostWidgetState();
}

class _RoutePostWidgetState extends State<RoutePostWidget> {
  List<RouteMarker> postMarkers = [];
  List<String> images = [];

  int _onSelectedItem = 1;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    getPostMarkers();
    // getImages();
  }

  getPostMarkers() async {
    setState(() {
      isLoading = true;
    });

    if (widget.post != null) {
      QuerySnapshot snap = await postMarkersCollection
          .where('routeMarkerDocID', whereIn: widget.post.routeMarkerIds)
          .get();
      setState(() {
        isLoading = false;

        postMarkers =
            snap.docs.map((doc) => RouteMarker.fromDocument(doc)).toList();
        print('Number of Markers ' + postMarkers.length.toString());
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        child: Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          ListTile(
            leading: CircleAvatar(
              radius: 24,
              backgroundImage: widget.user.photoURL.isEmpty ?? true
                  ? AssetImage('assets/images/default-profile.png')
                  : NetworkImage(widget.user.photoURL),
            ),
            title: Text(
              widget.user.displayName,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            subtitle: Text('12/08/2021, 10:52 AM'),
            trailing: PopupMenuButton(
              itemBuilder: (context) {
                return [
                  PopupMenuItem(
                    value: 1,
                    child: ListTile(
                      leading: Icon(Icons.bookmark_border_outlined),
                      title: Text('Save'),
                    ),
                  ),
                  PopupMenuItem(
                    value: 2,
                    child: ListTile(
                      leading: Icon(Icons.edit),
                      title: Text('Edit'),
                    ),
                  ),
                  PopupMenuItem(
                    value: 3,
                    child: ListTile(
                      leading: Icon(Icons.delete),
                      title: Text('Delete'),
                    ),
                  ),
                ];
              },
              onSelected: (int value) {
                setState(() {
                  _onSelectedItem = value;
                });
              },
              //  onPressed: () {},
            ),
          ),
          // buildPostContent(post),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            child: Align(
                alignment: Alignment.centerLeft,
                child: Text(widget.post.description)),
          ),
          postMarkers.isEmpty
              ? Container(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.only(top: 20.0),
                        child: Text(
                          "This post has no images",
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 18.0,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              : CarouselWidget(postMarkers),
          // CarouselSlider(
          //     items: images.map((url) {
          //       return Container(
          //         width: MediaQuery.of(context).size.width,
          //         margin: EdgeInsets.symmetric(horizontal: 5.0),
          //         child: GestureDetector(
          //           child: new Image.memory(
          //             base64Decode(url),
          //             fit: BoxFit.cover,
          //           ),
          //           // Image(
          //           // image: File(url),
          //           // fit: BoxFit.cover,
          //           // ),
          //           onTap: () => Navigator.push(
          //               context,
          //               MaterialPageRoute(
          //                   builder: (context) => ImageFullView(url))),
          //         ),
          //       );
          //     }).toList(),
          //     options: CarouselOptions(autoPlay: false)),
          ButtonBar(
            alignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                  icon: Icon(Icons.thumb_up_alt_outlined), onPressed: () {}),
              IconButton(icon: Icon(Icons.comment), onPressed: () {}),
              IconButton(
                  icon: Icon(Icons.bookmark_border_outlined), onPressed: () {}),
              IconButton(icon: Icon(Icons.share), onPressed: () {}),
            ],
          )
        ],
      ),
    ));
  }
}
