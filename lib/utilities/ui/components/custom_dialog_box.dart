/*
 * Created by Gwyn Bong Xiao Min
 * Copyright (c) 2021. All rights reserved.
 * Last modified 9/10/21 5:35 PM
 */

import 'package:flutter/material.dart';
import 'package:nearbyou/utilities/ui/palette.dart';

class CustomDialogBox extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressedLeftButton;
  final VoidCallback onPressedRightButton;
  final String dialogTitle;
  final String dialogSubtitle;
  final String leftButtonText;
  final String rightButtonText;
  final Color bgAvatarColor;
  final Color iconColor;
  final Color leftButtonTextColor;
  final Color rightButtonTextColor;
  final Widget widget;

  const CustomDialogBox({
    Key key,
    this.icon,
    this.leftButtonText,
    this.rightButtonText,
    this.dialogTitle,
    this.dialogSubtitle,
    this.onPressedLeftButton,
    this.onPressedRightButton,
    this.bgAvatarColor,
    this.iconColor,
    this.leftButtonTextColor,
    this.rightButtonTextColor,
    this.widget,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Stack(
        overflow: Overflow.visible,
        alignment: Alignment.topCenter,
        children: [
          // Container(
          //   height: 220,
          //   child:
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 50),
            child: IntrinsicWidth(
              child: IntrinsicHeight(
                child: Column(
                  children: [
                    SizedBox(
                      height: 15,
                    ),
                    Text(
                      dialogTitle ?? '',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 25,
                          color: bgColor),
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    Text(
                      dialogSubtitle ?? '',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 18),
                    ),
                    widget ?? Container(),
                    SizedBox(
                      height: 25,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: onPressedLeftButton,
                          child: Text(
                            leftButtonText ?? '',
                            style: TextStyle(
                                color: leftButtonTextColor ?? Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                        SizedBox(
                          width: 10.0,
                        ),
                        TextButton(
                          onPressed: onPressedRightButton,
                          child: Text(
                            rightButtonText ?? '',
                            style: TextStyle(
                                color: rightButtonTextColor ?? Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold),
                          ),
                        )
                      ],
                    )
                  ],
                ),
              ),
            ),
          ),
          // ),
          Positioned(
              top: -50,
              child: CircleAvatar(
                backgroundColor: bgAvatarColor,
                radius: 50,
                child: Icon(
                  icon,
                  color: iconColor,
                  size: 50,
                ),
              )),
        ],
      ),
    );
  }
}
