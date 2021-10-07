/*
 * Created by Gwyn Bong Xiao Min
 * Copyright (c) 2021. All rights reserved.
 * Last modified 7/10/21 3:56 PM
 */

import 'package:flutter/material.dart';
import 'package:nearbyou/utilities/ui/palette.dart';

// decoration for round buttons
class SocialRoundedButton extends StatelessWidget {
  final String text;
  final GestureTapCallback onPressed;
  final Color color, textColor;
  final ImageProvider icon;

  const SocialRoundedButton(
      {Key key,
      this.text,
      this.onPressed,
      this.color,
      this.textColor,
      this.icon})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      width: size.width * 0.8,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(29),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            primary: color,
            padding: EdgeInsets.symmetric(vertical: 20, horizontal: 40),
          ),
          onPressed: onPressed,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image(
                image: icon,
                height: 24,
              ),
              Padding(
                padding: EdgeInsets.only(left: 12),
                child: Text(
                  text,
                  style: TextStyle(color: textColor),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
