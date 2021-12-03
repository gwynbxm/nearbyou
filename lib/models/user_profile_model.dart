/*
 * Created by Gwyn Bong Xiao Min
 * Copyright (c) 2021. All rights reserved.
 * Last modified 25/7/21 5:35 PM
 */

import 'package:cloud_firestore/cloud_firestore.dart';

class UserData {
  String name;
  String username;
  String emailAddress;
  String profilePhoto;
  String biography;

  UserData({
    this.username,
    this.name,
    this.emailAddress,
    this.profilePhoto,
    this.biography,
  });

  UserData.withoutEmail(
    this.name,
    this.username,
    this.biography,
    this.profilePhoto,
  );

  factory UserData.fromMap(Map<String, dynamic> json) {
    return UserData(
        username: json['username'],
        name: json['name'],
        emailAddress: json['emailAddress'],
        profilePhoto: json['profilePhoto'],
        biography: json['biography']);
  }

  Map<String, dynamic> signUpToJson() => {
        'username': username,
        'profilePhoto': profilePhoto,
        'emailAddress': emailAddress,
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
