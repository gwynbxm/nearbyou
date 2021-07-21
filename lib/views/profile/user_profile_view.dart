/*
 * Created by Gwyn Bong Xiao Min
 * Copyright (c) 2021. All rights reserved.
 * Last modified 14/7/21 5:58 PM
 */

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:nearbyou/models/user_profile_model.dart';
import 'package:nearbyou/utilities/services/firebase_services/firestore.dart';
import 'package:nearbyou/utilities/ui/components/rounded_button.dart';
import 'package:nearbyou/utilities/ui/components/rounded_icon_button.dart';
import 'package:nearbyou/utilities/ui/palette.dart';
import 'package:nearbyou/views/posting/add_post_view.dart';
import 'package:nearbyou/views/home/home_view.dart';
import 'package:nearbyou/views/profile/user_edit_profile_view.dart';

import 'components/divider_widget.dart';
import 'components/profile_number.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;

class ProfileView extends StatelessWidget {
  // const ProfileView({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: ManageProfile(),
      ),
    );
  }
}

class ManageProfile extends StatefulWidget {
  // const ManageProfile({Key key}) : super(key: key);

  @override
  _ManageProfileState createState() => _ManageProfileState();
}

class _ManageProfileState extends State<ManageProfile> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(
          onPressed: () => Navigator.push(
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
                    MaterialPageRoute(builder: (context) => EditProfileView()),
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
      body: FutureBuilder(
        future: DatabaseServices.getUser(_auth.currentUser.uid),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Container(
                alignment: FractionalOffset.center,
                child: CircularProgressIndicator());
          }

          UserProfile userProfile = UserProfile.fromDocument(snapshot.data);

          return ListView(
            physics: BouncingScrollPhysics(),
            children: [
              Center(
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 48,
                      backgroundImage:
                          userProfile?.profilePhoto?.isEmpty ?? true
                              ? AssetImage('assets/images/default-profile.png')
                              : NetworkImage(userProfile.profilePhoto),
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 24,
              ),
              Center(
                child: Column(
                  children: [
                    Text(
                      userProfile.username,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                      ),
                    ),
                    const SizedBox(
                      height: 4,
                    ),
                    Text(
                      userProfile.emailAddress,
                      style: TextStyle(color: Colors.grey),
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
                      value: '122',
                    ),
                    buildDivider(),
                    ProfileNoButton(
                      text: 'Followers',
                      value: '145',
                    ),
                    buildDivider(),
                    ProfileNoButton(
                      text: 'Following',
                      value: '155',
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
