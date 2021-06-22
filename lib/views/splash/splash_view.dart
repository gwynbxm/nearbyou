/*
 * Created by Gwyn Bong Xiao Min
 * Copyright (c) 2021. All rights reserved.
 * Last modified 2/6/21 3:41 PM
 */

import 'dart:async';

import 'package:flutter/material.dart';

class SplashView extends StatefulWidget {
  // const SplashView({Key key}) : super(key: key);

  @override
  _SplashViewState createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    Timer(
      Duration(seconds: 3),
      () => Navigator.pushNamed(context, '/login'),
      //   Navigator.pushReplacement(
      // context,
      // MaterialPageRoute(
      //   builder: (context) => HomeView(),
      // ),
      // ),
    );
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
