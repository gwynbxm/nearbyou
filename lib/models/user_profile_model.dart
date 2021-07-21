/*
 * Created by Gwyn Bong Xiao Min
 * Copyright (c) 2021. All rights reserved.
 * Last modified 5/7/21 11:46 AM
 */

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';

class UserProfile {
  final int id;
  final String username;
  final String emailAddress;
  final String profilePhoto;

  UserProfile({this.id, this.username, this.emailAddress, this.profilePhoto});

  factory UserProfile.fromMap(Map<String, dynamic> json) => new UserProfile(
        id: json["id"],
        emailAddress: json["email"],
        username: json["username"],
        profilePhoto: json["profilePhoto"],
      );

  Map<String, dynamic> toMap() => {
        'email': emailAddress,
        'username': username,
        'profilePhoto': profilePhoto,
      };

  factory UserProfile.fromDocument(DocumentSnapshot snapshot) {
    return UserProfile.fromMap(snapshot.data());
  }
}
