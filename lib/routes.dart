/*
 * Created by Gwyn Bong Xiao Min
 * Copyright (c) 2021. All rights reserved.
 * Last modified 22/6/21 6:19 PM
 */

import 'package:flutter/widgets.dart';
import 'package:nearbyou/views/home/home_view.dart';
import 'package:nearbyou/views/login/login_view.dart';
import 'package:nearbyou/views/profile/user_profile_view.dart';
import 'package:nearbyou/views/register/register_view.dart';
import 'package:nearbyou/views/splash/splash_view.dart';

final Map<String, WidgetBuilder> routes = <String, WidgetBuilder>{
  '/': (context) => SplashView(),
  // '/home': (context, {retrievedUser}) => HomeScreen(user: retrievedUser),
  '/home': (context) => HomeScreen(),
  '/login': (context) => LoginView(),
  '/register': (context) => RegisterView(),
  '/profile': (context) => ProfileView(),
};
