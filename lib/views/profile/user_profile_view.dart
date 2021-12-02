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
import 'package:nearbyou/utilities/ui/components/profile_button.dart';
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
  final String
      profileId; // access an account profile page (can be owner/visitor)

  ProfileView({this.profileId});

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

  int followingCount = 0;
  int followerCount = 0;

  @override
  void initState() {
    super.initState();
    checkIsFollowing();
    getCounts();
    getUserProfile();
    getProfilePosts(); //display user profile info and posts each time this screen is being called
  }

  currentUserId() {
    return _auth.currentUser.uid; //get current signed in user
  }

  // check if current signed in user is following this profile user
  checkIsFollowing() async {
    final following =
        await DatabaseServices.isFollowing(widget.profileId, currentUserId());
    setState(() async {
      isFollowing = following;
    });
  }

  //
  getUserProfile() async {
    setState(() {
      isLoading = true;
    });
    DocumentSnapshot snap = await profileCollection.doc(widget.profileId).get();

    UserData user = UserData.fromDocument(snap);
    setState(() {
      isLoading = false;
      userData = user;
    });
  }

  getProfilePosts() async {
    setState(() {
      isLoading = true;
    });

    // final routePosts = await DatabaseServices.getProfilePosts(user.toString());
    QuerySnapshot snap = await postCollection
        .where('createdBy', isEqualTo: widget.profileId)
        .get();

    setState(() {
      isLoading = false;
      routePostsList =
          snap.docs.map((doc) => RoutePost.fromDocument(doc)).toList();
      print('Number of Post ' + routePostsList.length.toString());
    });
  }

  followUser() {
    setState(() {
      isFollowing = true;
    });
    DatabaseServices.followUser(currentUserId(), widget.profileId);
  }

  unFollowUser() {
    setState(() {
      isFollowing = false;
    });
    DatabaseServices.unFollowUser(currentUserId(), widget.profileId);
  }

  getCounts() async {
    final fwerCount = await DatabaseServices.followerNum(widget.profileId);
    final fwingCount = await DatabaseServices.followingNum(widget.profileId);
    setState(() async {
      followerCount = fwerCount;
      followingCount = fwingCount;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          leading: BackButton(
            onPressed: () {
              Navigator.pop(context);
            },
            // TODO: implement proper pop of the screen
            //     Navigator.push(
            //   context,
            //   MaterialPageRoute(builder: (context) => HomeScreen()),
            // ),
            color: Colors.black,
          ),
          actions: [
            IconButton(
                icon: Icon(Icons.edit, color: Colors.black),
                onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              EditProfileView(userId: widget.profileId)),
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
    if (isLoading) {
      return circularProgressIndicator();
    } else {
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
                  userData.name == null
                      ? SizedBox.shrink()
                      : Text(
                          userData.name,
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
                  userData.biography == null
                      ? SizedBox.shrink()
                      : Text(
                          userData.biography,
                          style: TextStyle(
                            fontStyle: FontStyle.italic,
                            fontSize: 15,
                          ),
                        ),
                ],
              ),
            ),
//             Center(
//               child: Column(
//                 children: [
//                   Text(
//                     _auth.currentUser.displayName,
//                     style: TextStyle(
//                       fontWeight: FontWeight.bold,
//                       fontSize: 28,
//                     ),
//                   ),
//                   Text(
//                     '@' + userData.username,
//                     style: TextStyle(
//                       fontSize: 20,
//                     ),
//                   ),
//                   SizedBox(
//                     height: 10,
//                   ),
//                   Text(
//                     userData.biography,
//                     style: TextStyle(
//                       fontStyle: FontStyle.italic,
//                       fontSize: 15,
//                     ),
//                   ),
//                 ],
//               ),
// >>>>>>> 347ba64752c7ed248ed41bad57690e79dc0010c0
//             ),
            const SizedBox(
              height: 10,
            ),
            buildProfileButton(),
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
                    value: routePostsList.length,
                  ),
                  buildDivider(),
                  ProfileNoButton(
                    text: 'Followers',
                    value: followerCount,
                  ),
                  buildDivider(),
                  ProfileNoButton(
                    text: 'Following',
                    value: followingCount,
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }
  }

  buildProfileButton() {
    //if its owner
    bool isOwner = widget.profileId == _auth.currentUser.uid;

    if (isOwner) {
      return ProfileButton(
        text: "Edit Profile",
        bgColor: Colors.white,
        textColor: bgColor,
        borderColor: bgColor,
        onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    EditProfileView(userId: widget.profileId))),
      );
    } else if (isFollowing) {
      return ProfileButton(
        text: "Unfollow",
        bgColor: Colors.black12,
        textColor: Colors.black,
        borderColor: Colors.black12,
        onPressed: () => unFollowUser(),
      );
    } else if (!isFollowing) {
      return ProfileButton(
        text: "Follow",
        bgColor: Colors.white,
        textColor: Colors.white,
        borderColor: primaryColor,
        onPressed: () => followUser(),
      );
    }
  }

  // Container buildButton(
  //     {String text, Color bgColor, Color textColor, Function onPressed}) {
  //   return Container(
  //     child: ClipRRect(
  //       borderRadius: BorderRadius.circular(15),
  //       child: ElevatedButton(
  //         style: ElevatedButton.styleFrom(
  //           primary: isFollowing ? primaryColor : Colors.grey,
  //           padding: EdgeInsets.symmetric(vertical: 10, horizontal: 30),
  //         ),
  //         onPressed: () => onPressed,
  //         child: Text(
  //           text,
  //           style: TextStyle(color: Colors.white),
  //         ),
  //       ),
  //     ),
  //   );
  // }

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
            // return RoutePostWidget(userData, routePostsList[index]);
            print(routePostsList.length);
            return RoutePostWidget(
              userData,
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
