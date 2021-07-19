/*
 * Created by Gwyn Bong Xiao Min
 * Copyright (c) 2021. All rights reserved.
 * Last modified 5/7/21 11:46 AM
 */

import 'package:cloud_firestore/cloud_firestore.dart';

class UserData {
  final int id;
  final String username;
  final String email;
  final String profilePhoto;

  UserData({this.id, this.username, this.email, this.profilePhoto});

  factory UserData.fromMap(Map<String, dynamic> json) => new UserData(
        id: json["id"],
        username: json["username"],
        email: json["emailAddress"],
        profilePhoto: json["profilePhoto"],
      );

  Map<String, dynamic> toMap() => {
        'username': username,
        'emailAddress': email,
        'profilePhoto': profilePhoto,
      };

  factory UserData.fromDocument(DocumentSnapshot snapshot) {
    return UserData.fromMap(snapshot.data());
  }
}
