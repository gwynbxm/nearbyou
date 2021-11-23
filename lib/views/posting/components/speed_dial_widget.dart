/*
 * Created by Gwyn Bong Xiao Min
 * Copyright (c) 2021. All rights reserved.
 * Last modified 16/7/21 3:32 PM
 */

import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:nearbyou/utilities/ui/palette.dart';

class SpeedDialWidget extends StatelessWidget {
  const SpeedDialWidget({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SpeedDial(
      animatedIcon: AnimatedIcons.menu_close,
      animatedIconTheme: IconThemeData(size: 28),
      backgroundColor: primaryColor,
      visible: true,
      curve: Curves.bounceInOut,
      children: [
        SpeedDialChild(
          child: Icon(
            Icons.photo,
            color: Colors.white,
          ),
          backgroundColor: primaryColor,
          label: "Add photos",
          onTap: () {},
        ),
        SpeedDialChild(
          child: Icon(
            Icons.videocam,
            color: Colors.white,
          ),
          backgroundColor: primaryColor,
          label: "Add video",
          onTap: () {},
        ),
        SpeedDialChild(
          child: Icon(
            Icons.mic,
            color: Colors.white,
          ),
          backgroundColor: primaryColor,
          label: "Add audio",
          onTap: () {},
        ),
      ],
    );
  }
}
