/*
 * Created by Gwyn Bong Xiao Min
 * Copyright (c) 2021. All rights reserved.
 * Last modified 22/6/21 6:19 PM
 */

import 'package:flutter/material.dart';
import 'package:nearbyou/routes.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(LaunchApp());
}

class LaunchApp extends StatelessWidget {
  // const LaunchApp({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(primarySwatch: Colors.red),
      debugShowCheckedModeBanner: false,
      // do not put home and initialRoute property as they conflict each other
      initialRoute: '/',
      routes: routes,
    );
  }
}
