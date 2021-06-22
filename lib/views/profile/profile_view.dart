/*
 * Created by Gwyn Bong Xiao Min
 * Copyright (c) 2021. All rights reserved.
 * Last modified 28/5/21 12:59 PM
 */

import 'package:flutter/material.dart';

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
    return Container();
  }
}
