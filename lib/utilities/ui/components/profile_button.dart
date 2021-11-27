/*
 * Created by Gwyn Bong Xiao Min
 * Copyright (c) 2021. All rights reserved.
 * Last modified 26/11/21 1:06 AM
 */

import 'package:flutter/material.dart';

class ProfileButton extends StatelessWidget {
  final String text;
  final Color bgColor;
  final Color textColor;
  final Color borderColor;
  final GestureTapCallback onPressed;

  const ProfileButton({
    Key key,
    this.text,
    this.bgColor,
    this.textColor,
    this.onPressed,
    this.borderColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      width: size.width * 0.4,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            primary: bgColor,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            side: BorderSide(color: borderColor),
            padding: EdgeInsets.symmetric(vertical: 10),
          ),
          onPressed: onPressed,
          child: Text(
            text,
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
