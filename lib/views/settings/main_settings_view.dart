/*
 * Created by Gwyn Bong Xiao Min
 * Copyright (c) 2021. All rights reserved.
 * Last modified 26/7/21 4:58 PM
 */
import 'package:flutter/material.dart';
import 'package:nearbyou/utilities/ui/palette.dart';

import 'components/settings_item.dart';

class MainSettingsView extends StatefulWidget {
  const MainSettingsView({Key key}) : super(key: key);

  @override
  _MainSettingsViewState createState() => _MainSettingsViewState();
}

class _MainSettingsViewState extends State<MainSettingsView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        //Before closing, prompt user if want to save as draft or discard post
        leading: BackButton(
          onPressed: () => Navigator.of(context).pop(),
          color: Colors.black,
        ),
        title: Text(
          'Settings',
          style: TextStyle(color: Colors.black),
        ),
        actions: [],
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        padding: EdgeInsets.only(left: 30, right: 30, top: 20),
        child: ListView(
          children: [
            Row(
              children: [
                Text(
                  'Account',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: bgColor,
                  ),
                ),
              ],
            ),
            Divider(
              height: 15,
              thickness: 2,
              color: bgColor,
            ),
            SizedBox(
              height: 12,
            ),
            SettingsItem(
              title: 'Manage Account',
              onTap: () {},
            ),
            SizedBox(
              height: 12,
            ),
            SettingsItem(
              title: 'Privacy & Security',
              onTap: () {},
            ),
            SizedBox(
              height: 12,
            ),
            SettingsItem(
              title: 'Language',
              onTap: () {},
            ),
            SizedBox(
              height: 40,
            ),
            Row(
              children: [
                Text(
                  'General',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: bgColor,
                  ),
                ),
              ],
            ),
            Divider(
              height: 15,
              thickness: 2,
              color: bgColor,
            ),
            SizedBox(
              height: 12,
            ),
            SettingsItem(
              title: 'Notifications',
              onTap: () {},
            ),
            SizedBox(
              height: 12,
            ),
            SettingsItem(
              title: 'Help Center',
              onTap: () {},
            ),
            SizedBox(
              height: 12,
            ),
            SettingsItem(
              title: 'About Nearbyou',
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }
}
