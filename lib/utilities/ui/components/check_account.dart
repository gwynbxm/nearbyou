/*
 * Created by Gwyn Bong Xiao Min
 * Copyright (c) 2021. All rights reserved.
 * Last modified 10/7/21 11:19 AM
 */

import 'package:flutter/material.dart';

import '../palette.dart';

class CheckSignInOrSignUp extends StatelessWidget {
  final bool login;
  final GestureTapCallback onTap;
  const CheckSignInOrSignUp({
    Key key,
    this.login = true,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          login ? "Don't have an Account? " : "Already have an account? ",
          style: TextStyle(color: Colors.black),
        ),
        GestureDetector(
          onTap: onTap,
          child: Text(
            login ? "Sign Up" : "Sign In",
            style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}
