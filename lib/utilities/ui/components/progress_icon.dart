/*
 * Created by Gwyn Bong Xiao Min
 * Copyright (c) 2021. All rights reserved.
 * Last modified 7/10/21 10:55 PM
 */

import 'package:flutter/material.dart';

import '../palette.dart';

Container circularProgressIndicator() {
  return Container(
    alignment: Alignment.center,
    padding: EdgeInsets.only(top: 10),
    child: CircularProgressIndicator(
      valueColor: AlwaysStoppedAnimation(textLightColor),
    ),
  );
}
