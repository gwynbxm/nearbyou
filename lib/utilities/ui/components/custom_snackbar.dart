/*
 * Created by Gwyn Bong Xiao Min
 * Copyright (c) 2021. All rights reserved.
 * Last modified 2/10/21 2:58 PM
 */

import 'package:flutter/material.dart';

class CustomErrorBox {
  static SnackBar displaySnackBar(
      String msg, String actionMsg, VoidCallback onClick) {
    return SnackBar(
      content: Text(
        msg,
        style: TextStyle(color: Colors.white, fontSize: 14.0),
      ),
      action: (actionMsg != null)
          ? SnackBarAction(
              label: actionMsg,
              onPressed: () {
                return onClick();
              },
            )
          : null,
      duration: Duration(seconds: 2),
      backgroundColor: Colors.grey,
    );
  }
}
