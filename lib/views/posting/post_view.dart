/*
 * Created by Gwyn Bong Xiao Min
 * Copyright (c) 2021. All rights reserved.
 * Last modified 2/12/21 5:09 PM
 */

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:nearbyou/models/route_marker_model.dart';
import 'package:nearbyou/models/route_post_model.dart';
import 'package:nearbyou/models/user_profile_model.dart';
import 'package:nearbyou/utilities/constants/constants.dart';
import 'package:nearbyou/utilities/ui/components/carousel_widget.dart';
import 'package:nearbyou/views/comment/comment_view.dart';
import 'package:timeago/timeago.dart' as timeAgo;

class PostView extends StatefulWidget {
  final RoutePost post;
  final UserData owner;

  const PostView({Key key, this.post, this.owner}) : super(key: key);

  @override
  _PostViewState createState() => _PostViewState();
}

class _PostViewState extends State<PostView> {
  List<RouteMarker> postMarkers = [];

  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    getPostMarkers();
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
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(
          onPressed: () =>
              // TODO: implement proper pop of the screen
              Navigator.pop(context),
          color: Colors.black,
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Post',
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: Container(
        child: Card(
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              ListTile(
                leading: CircleAvatar(
                  radius: 24,
                  backgroundImage: widget.owner?.profilePhoto?.isEmpty ?? true
                      ? AssetImage('assets/images/default-profile.png')
                      : NetworkImage(widget.owner.profilePhoto),
                ),
                title: widget.owner.name == null
                    ? Text(
                        widget.owner.username,
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      )
                    : Text(
                        widget.owner.name,
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                // Text(
                //   // _auth.currentUser.displayName,
                //   widget.userData.name,
                //   style: TextStyle(
                //       fontSize: 20, fontWeight: FontWeight.bold, color: bgColor),
                // ),
                subtitle:
                    Text(timeAgo.format(widget.post.dateTimePosted.toDate())),
              ),
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
              ButtonBar(
                alignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                      icon: Icon(Icons.thumb_up_alt_outlined),
                      onPressed: () {}),
                  IconButton(
                    icon: Icon(Icons.comment),
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => CommentView(
                              routePost: widget.post,
                              postMarkers: postMarkers,
                              userData: widget.owner)),
                    ),
                  ),
                  IconButton(
                      icon: Icon(Icons.bookmark_border_outlined),
                      onPressed: () {}),
                  IconButton(icon: Icon(Icons.share), onPressed: () {}),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
