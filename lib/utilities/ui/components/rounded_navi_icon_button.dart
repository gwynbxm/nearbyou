/*
 * Created by Gwyn Bong Xiao Min
 * Copyright (c) 2021. All rights reserved.
 * Last modified 10/8/21 4:56 PM
 */

import 'package:flutter/material.dart';

import '../palette.dart';

class RoundedBasicIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;

  const RoundedBasicIconButton({
    Key key,
    this.icon,
    this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
        onPressed: onPressed,
        child: Icon(
          icon,
          color: textLightColor,
        ),
        style: ButtonStyle(
          shape: MaterialStateProperty.all(CircleBorder(side: BorderSide.none)),
          padding: MaterialStateProperty.all(EdgeInsets.all(10)),
          backgroundColor: MaterialStateProperty.all(Colors.white),
          overlayColor: MaterialStateProperty.resolveWith<Color>((states) =>
              states.contains(MaterialState.pressed) ? textDarkColor : null),
        ));
  }
}
