/*
 * Created by Gwyn Bong Xiao Min
 * Copyright (c) 2021. All rights reserved.
 * Last modified 7/7/21 10:18 PM
 */

import 'package:flutter/widgets.dart';
import 'package:nearbyou/views/home/home_view.dart';
import 'package:nearbyou/views/signin/signin_view.dart';
import 'package:nearbyou/views/profile/user_profile_view.dart';
import 'package:nearbyou/views/signup/signup_view.dart';
import 'package:nearbyou/views/splash/splash_view.dart';

final Map<String, WidgetBuilder> routes = <String, WidgetBuilder>{
  '/': (context) => SplashView(),
  // '/home': (context, {retrievedUser}) => HomeScreen(user: retrievedUser),
  '/home': (context) => HomeScreen(),
  '/login': (context) => SignInView(),
  '/register': (context) => SignUpView(),
  '/profile': (context) => ProfileView(),
};
