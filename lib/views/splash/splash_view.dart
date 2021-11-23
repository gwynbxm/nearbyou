/*
 * Created by Gwyn Bong Xiao Min
 * Copyright (c) 2021. All rights reserved.
 * Last modified 5/7/21 11:46 AM
 */

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:nearbyou/views/home/home_view.dart';
import 'package:nearbyou/views/signin/signin_view.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashView extends StatefulWidget {
  // const SplashView({Key key}) : super(key: key);

  @override
  _SplashViewState createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> {
  SharedPreferences sharedPreferences;
  bool newUser;

  @override
  void initState() {
    super.initState();

    Timer(
      Duration(seconds: 3),
      () => checkIfSignedIn(),
      //   Navigator.pushReplacement(
      // context,
      // MaterialPageRoute(
      //   builder: (context) => HomeView(),
      // ),
      // ),
    );
  }

  void checkIfSignedIn() async {
    sharedPreferences = await SharedPreferences.getInstance();
    newUser = (sharedPreferences.getBool('login') ?? true);

    if (newUser == false) {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => HomeScreen()));
    } else {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => SignInView()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Center(
        child:
            Image.asset("assets/images/app-logo.png", width: 300, height: 300),
      ),
      // child: FlutterLogo(size: MediaQuery.of(context).size.height),
    );
  }
}
