/*
 * Created by Gwyn Bong Xiao Min
 * Copyright (c) 2021. All rights reserved.
 * Last modified 26/7/21 4:24 PM
 */
import 'package:flutter/material.dart';
import 'package:nearbyou/utilities/ui/palette.dart';

class AppBarTextButton extends StatelessWidget {
  final String text;
  final GestureTapCallback onPressed;

  const AppBarTextButton({
    Key key,
    this.text,
    this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Builder(builder: (BuildContext context) {
      return TextButton(
        child: Text(text),
        style: TextButton.styleFrom(primary: textLightColor),
        onPressed: onPressed,
      );
    });
  }
}
