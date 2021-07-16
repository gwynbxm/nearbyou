/*
 * Created by Gwyn Bong Xiao Min
 * Copyright (c) 2021. All rights reserved.
 * Last modified 5/7/21 11:46 AM
 */

import 'package:flutter/material.dart';
import 'package:nearbyou/utilities/ui/palette.dart';

class DrawerItem extends StatelessWidget {
  final IconData icon;
  final String text;
  final GestureTapCallback onTap;

  const DrawerItem({
    Key key,
    this.icon,
    this.text,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Row(
        children: [
          Icon(
            icon,
            color: primaryColor,
          ),
          Padding(
            padding: EdgeInsets.only(left: 8.0),
            child: Text(
              text,
            ),
          )
        ],
      ),
      onTap: onTap,
    );
  }
}
