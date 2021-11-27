/*
 * Created by Gwyn Bong Xiao Min
 * Copyright (c) 2021. All rights reserved.
 * Last modified 9/7/21 1:03 PM
 */

import 'package:flutter/material.dart';
import 'package:nearbyou/utilities/ui/palette.dart';

class ProfileNoButton extends StatelessWidget {
  final int value;
  final String text;
  const ProfileNoButton({Key key, this.value, this.text}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      // padding: EdgeInsets.symmetric(vertical: 4),
      onPressed: () {},
      child: Column(
        children: [
          Text(
            value.toString(),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 24,
            ),
          ),
          SizedBox(
            height: 2,
          ),
          Text(
            text,
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
