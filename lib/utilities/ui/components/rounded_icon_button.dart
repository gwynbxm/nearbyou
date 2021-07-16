/*
 * Created by Gwyn Bong Xiao Min
 * Copyright (c) 2021. All rights reserved.
 * Last modified 5/7/21 11:46 AM
 */
import 'package:flutter/material.dart';

import '../palette.dart';

class RoundedIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;

  const RoundedIconButton({
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
          color: Colors.white,
        ),
        style: ButtonStyle(
          shape: MaterialStateProperty.all(CircleBorder()),
          padding: MaterialStateProperty.all(EdgeInsets.all(20)),
          backgroundColor: MaterialStateProperty.all(primaryColor),
          overlayColor: MaterialStateProperty.resolveWith<Color>((states) =>
              states.contains(MaterialState.pressed) ? color4 : null),
        ));
  }
}
