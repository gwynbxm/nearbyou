/*
 * Created by Gwyn Bong Xiao Min
 * Copyright (c) 2021. All rights reserved.
 * Last modified 14/7/21 5:58 PM
 */

import 'dart:convert';
import 'dart:io';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nearbyou/models/route_marker_model.dart';
import 'package:nearbyou/models/route_post_model.dart';
import 'package:nearbyou/models/user_profile_model.dart';
import 'package:nearbyou/utilities/constants/constants.dart';
import 'package:nearbyou/utilities/services/firebase_services/firestore.dart';
import 'package:nearbyou/utilities/ui/components/custom_dialog_box.dart';
import 'package:nearbyou/utilities/ui/components/progress_icon.dart';
import 'package:nearbyou/utilities/ui/components/rounded_button.dart';
import 'package:nearbyou/utilities/ui/components/rounded_icon_button.dart';
import 'package:nearbyou/utilities/ui/palette.dart';
import 'package:nearbyou/utilities/ui/components/image_full_view.dart';
import 'package:nearbyou/views/posting/add_post_view.dart';
import 'package:nearbyou/views/home/home_view.dart';
import 'package:nearbyou/views/profile/user_edit_profile_view.dart';

import 'components/divider_widget.dart';
import 'components/profile_number.dart';
import 'components/route_post_widget.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;

class ProfileView extends StatefulWidget {
  final String userId;

  ProfileView({this.userId});

  @override
  _ProfileViewState createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  List<RoutePost> routePostsList = [];
  List<RouteMarker> markerList = [];

  bool isLoading = false;
  UserData userData;

  int _onSelectedItem = 1;

  ScrollController scrollController = ScrollController();

  bool isFollowing = false;

  @override
  void initState() {
    super.initState();
    getUserProfile();
    getProfilePosts(); //display user profile info and posts each time this screen is being called
  }

  getUserProfile() async {
    DocumentSnapshot snap = await profileCollection.doc(widget.userId).get();

    UserData user = UserData.fromDocument(snap);
    setState(() {
      userData = user;
    });
  }

  getProfilePosts() async {
    setState(() {
      isLoading = true;
    });

    // final routePosts = await DatabaseServices.getProfilePosts(user.toString());
    QuerySnapshot snap =
        await postCollection.where('createdBy', isEqualTo: widget.userId).get();

    setState(() {
      isLoading = false;
      routePostsList =
          snap.docs.map((doc) => RoutePost.fromDocument(doc)).toList();
      print('Number of Post ' + routePostsList.length.toString());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          leading: BackButton(
            onPressed: () =>
                // TODO: implement proper pop of the screen
                Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => HomeScreen()),
            ),
            color: Colors.black,
          ),
          actions: [
            IconButton(
                icon: Icon(Icons.edit, color: Colors.black),
                onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              EditProfileView(userId: widget.userId)),
                    )),
          ],
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        floatingActionButton: RoundedIconButton(
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddPostView()),
          ),
          icon: Icons.add_location_alt,
        ),
        body: ListView(
          children: [
            buildProfileHeader(),
            const SizedBox(
              height: 24,
            ),
            Divider(
              height: 10,
              thickness: 1,
            ),
            const SizedBox(
              height: 15,
            ),
            buildProfilePosts(),
          ],
        ));
  }

  buildProfileHeader() {
    return Container(
      child: Column(
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 48,
                backgroundImage: userData?.profilePhoto?.isEmpty ?? true
                    ? AssetImage('assets/images/default-profile.png')
                    : NetworkImage(userData.profilePhoto),
              ),
            ],
          ),
          const SizedBox(
            height: 24,
          ),
          Center(
            child: Column(
              children: [
                Text(
                  _auth.currentUser.displayName,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 28,
                  ),
                ),
                Text(
                  '@' + userData.username,
                  style: TextStyle(
                    fontSize: 20,
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Text(
                  userData.biography,
                  style: TextStyle(
                    fontStyle: FontStyle.italic,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          IntrinsicHeight(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              mainAxisSize: MainAxisSize.min,
              children: [
                ProfileNoButton(
                  text: 'Posts',
                  value: routePostsList.length.toString(),
                ),
                buildDivider(),
                ProfileNoButton(
                  text: 'Followers',
                  value: '20 ',
                ),
                buildDivider(),
                ProfileNoButton(
                  text: 'Following',
                  value: '25',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  buildProfilePosts() {
    if (isLoading) {
      return circularProgressIndicator();
    } else if (routePostsList.isEmpty) {
      return Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(top: 20.0),
              child: Text(
                "You haven't made any posts yet",
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 18.0,
                  fontWeight: FontWeight.normal,
                ),
              ),
            ),
          ],
        ),
      );
    } else {
      return SingleChildScrollView(
        child: ListView.builder(
          controller: scrollController,
          physics: NeverScrollableScrollPhysics(),
          primary: false,
          scrollDirection: Axis.vertical,
          shrinkWrap: true,
          itemCount: routePostsList.length,
          itemBuilder: (context, index) {
            print(routePostsList.length);
            return RoutePostWidget(
              _auth.currentUser,
              routePostsList[index],
              onDelete: () => removeItem(index),
            );
          },
        ),
      );
    }
    // });
  }

  void removeItem(int index) {
    //ask if they are sure they want to delete the post
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return CustomDialogBox(
            icon: Icons.warning,
            bgAvatarColor: Colors.redAccent,
            iconColor: Colors.white,
            dialogTitle: 'Delete Post?',
            dialogSubtitle: 'Do you want to delete this post?',
            leftButtonText: 'Cancel',
            leftButtonTextColor: Colors.black,
            onPressedLeftButton: () => Navigator.of(context).pop(),
            rightButtonText: 'Delete',
            rightButtonTextColor: primaryColor,
            onPressedRightButton: () async {
              print(index);
              await DatabaseServices.deletePostData(
                  routePostsList.elementAt(index).routePostId,
                  routePostsList.elementAt(index).routeMarkerIds);
              Navigator.of(context).pop();
              showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return CustomDialogBox(
                      icon: Icons.done,
                      bgAvatarColor: Colors.green,
                      iconColor: Colors.white,
                      dialogTitle: 'Post deleted!',
                      dialogSubtitle: 'The post has been deleted successfully!',
                      rightButtonText: 'Dismiss',
                      rightButtonTextColor: primaryColor,
                      onPressedRightButton: () {
                        Navigator.of(context).pop();
                        setState(() {
                          routePostsList = List.from(routePostsList)
                            ..removeAt(index);
                        });
                      },
                    );
                  });
            },
          );
        });
  }
}
