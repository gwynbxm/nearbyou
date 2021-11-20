/*
 * Created by Gwyn Bong Xiao Min
 * Copyright (c) 2021. All rights reserved.
 * Last modified 25/7/21 5:35 PM
 */

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nearbyou/models/route_post_model.dart';

class UserData {
  // String userId;
  String name;
  String username;
  // String emailAddress;
  String profilePhoto;
  String biography;
  // List<UserData> friends;
  // List<RoutePost> savedPosts;

  UserData({
    // this.userId,
    this.username,
    this.name,
    // this.emailAddress,
    this.profilePhoto,
    this.biography,
    // this.friends,
    // this.savedPosts,
  });

  UserData.withoutEmail(
    this.name,
    this.username,
    this.biography,
    this.profilePhoto,
  );

  // factory UserData.fromMap(Map<String, dynamic> json) => new UserData(
  //       // userId: json["id"],
  //       username: json["username"],
  //       name: json["name"],
  //       profilePhoto: json["profilePhoto"],
  //       biography: json["biography"],
  //     );

  factory UserData.fromMap(Map<String, dynamic> json) {
    return UserData(
        username: json['username'],
        name: json['name'],
        profilePhoto: json['profilePhoto'],
        biography: json['biography']);
  }

  Map<String, dynamic> signUpToJson() => {
        // 'email': emailAddress,
        'username': username,
        'profilePhoto': profilePhoto,
      };

  Map<String, dynamic> editProfiletoJson() => {
        'biography': biography,
        'name': name,
        'username': username,
        'profilePhoto': profilePhoto,
      };

  factory UserData.fromDocument(DocumentSnapshot snapshot) {
    return UserData.fromMap(snapshot.data());
  }
}
