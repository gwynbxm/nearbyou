/*
 * Created by Gwyn Bong Xiao Min
 * Copyright (c) 2021. All rights reserved.
 * Last modified 13/11/21 10:10 AM
 */

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:nearbyou/models/route_marker_model.dart';
import 'package:nearbyou/utilities/ui/palette.dart';
import 'package:nearbyou/utilities/ui/components/image_full_view.dart';
import 'package:nearbyou/views/home/components/home_carousel_widget.dart';

class RouteMarkerWidget extends StatefulWidget {
  final RouteMarker marker;

  const RouteMarkerWidget(this.marker);

  @override
  _RouteMarkerWidgetState createState() => _RouteMarkerWidgetState();
}

class _RouteMarkerWidgetState extends State<RouteMarkerWidget> {
  // find the user details of this marker

  // check if its only 1 image

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
                // backgroundImage: _auth.currentUser.photoURL.isEmpty ?? true
                //     ? AssetImage('assets/images/default-profile.png')
                //     : NetworkImage(_auth.currentUser.photoURL),
              ),
              title: Text(
                // _auth.currentUser.displayName,
                'name',
                style: TextStyle(
                    fontSize: 20, fontWeight: FontWeight.bold, color: bgColor),
              ),
              trailing: IconButton(
                // TODO: implement allow current user to edit post
                icon: Icon(Icons.more_vert),
                onPressed: () {},
              ),
            ),
            Container(
              padding: EdgeInsets.only(
                left: 20.0,
                right: 30.0,
                top: 20,
                bottom: 20,
              ),
              alignment: Alignment.centerLeft,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.marker.title,
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  Text(widget.marker.caption),
                ],
              ),
            ),
            widget.marker.imageList.isEmpty
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
                : widget.marker.imageList.length == 1
                    ? Container(
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.height,
                        margin: EdgeInsets.symmetric(horizontal: 5.0),
                        child: GestureDetector(
                          child: Image.memory(
                            base64Decode(widget.marker.imageList.first),
                            fit: BoxFit.cover,
                          ),
                          onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => ImageFullView(
                                      widget.marker.imageList.single))),
                        ),
                      )
                    : CarouselWidget(widget.marker.imageList),
            ButtonBar(
              alignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton(
                  child: Text(
                    'View Post',
                    style: TextStyle(
                        color: primaryColor,
                        fontSize: 18,
                        fontWeight: FontWeight.bold),
                  ),
                  onPressed: () {},
                )
                // IconButton(
                //     icon: Icon(Icons.thumb_up_alt_outlined), onPressed: () {}),
                // IconButton(icon: Icon(Icons.comment), onPressed: () {}),
                // IconButton(
                //     icon: Icon(Icons.bookmark_border_outlined), onPressed: () {}),
                // IconButton(icon: Icon(Icons.share), onPressed: () {}),
              ],
            )
          ],
        ),
      ),
    );
  }
}
