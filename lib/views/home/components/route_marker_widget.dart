/*
 * Created by Gwyn Bong Xiao Min
 * Copyright (c) 2021. All rights reserved.
 * Last modified 13/11/21 10:10 AM
 */

import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:nearbyou/models/route_marker_model.dart';
import 'package:nearbyou/models/route_post_model.dart';
import 'package:nearbyou/models/user_profile_model.dart';
import 'package:nearbyou/utilities/constants/constants.dart';
import 'package:nearbyou/utilities/services/firebase_services/firestore.dart';
import 'package:nearbyou/utilities/ui/palette.dart';
import 'package:nearbyou/utilities/ui/components/image_full_view.dart';
import 'package:nearbyou/views/home/components/home_carousel_widget.dart';
import 'package:nearbyou/views/posting/post_view.dart';

class RouteMarkerWidget extends StatefulWidget {
  final RouteMarker marker;

  const RouteMarkerWidget(this.marker);

  @override
  _RouteMarkerWidgetState createState() => _RouteMarkerWidgetState();
}

class _RouteMarkerWidgetState extends State<RouteMarkerWidget> {
  RoutePost relatedPost;
  UserData postOwner;

  bool isLoading = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    getRelatedPost();
  }

//   // find post according to the markerId
  getRelatedPost() async {
    setState(() {
      isLoading = true;
    });
    final result = await DatabaseServices.getAllPosts();
    final data = result.where((element) =>
        element.routeMarkerIds.contains(widget.marker.routeMarkerDocID));
    if (data.length > 0) {
      setState(() {
        isLoading = false;
        relatedPost = data.first;
      });
    }
    getOwner(relatedPost.createdBy);
  }

// find the user details of this marker according to post
  getOwner(String creator) async {
    setState(() {
      isLoading = true;
    });
    if (relatedPost != null) {
      DocumentSnapshot snap = await profileCollection.doc(creator).get();

      UserData user = UserData.fromDocument(snap);
      setState(() {
        isLoading = false;
        postOwner = user;
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
                backgroundImage: postOwner?.profilePhoto?.isEmpty ?? true
                    ? AssetImage('assets/images/default-profile.png')
                    : NetworkImage(postOwner.profilePhoto),
              ),
              title: postOwner.name == null
                  ? Text(
                      postOwner.username,
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    )
                  : Text(
                      postOwner.name,
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
                  onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              PostView(post: relatedPost, owner: postOwner))),
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
