/*
 * Created by Gwyn Bong Xiao Min
 * Copyright (c) 2021. All rights reserved.
 * Last modified 14/7/21 5:58 PM
 */

import 'package:flutter/material.dart';
import 'package:nearbyou/utilities/ui/components/rounded_button.dart';
import 'package:nearbyou/utilities/ui/components/rounded_icon_button.dart';
import 'package:nearbyou/utilities/ui/palette.dart';
import 'package:nearbyou/views/geopost/add_post_view.dart';
import 'package:nearbyou/views/home/home_view.dart';
import 'package:nearbyou/views/profile/user_edit_profile_view.dart';

import 'components/divider_widget.dart';
import 'components/profile_number.dart';

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
      body: ListView(
        physics: BouncingScrollPhysics(),
        children: [
          Center(
            child: Stack(
              children: [
                CircleAvatar(
                  radius: 48,
                  backgroundImage:
                      AssetImage('assets/images/default-profile.png'),
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
                  'Gwyn',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                  ),
                ),
                const SizedBox(
                  height: 4,
                ),
                Text(
                  '@gwyngwyn',
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
      ),
    );
  }
}
