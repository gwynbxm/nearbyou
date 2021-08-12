/*
 * Created by Gwyn Bong Xiao Min
 * Copyright (c) 2021. All rights reserved.
 * Last modified 12/8/21 6:47 PM
 */

import 'dart:collection';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nearbyou/models/post_comment_model.dart';
import 'package:nearbyou/models/route_marker_model.dart';
import 'package:nearbyou/models/user_profile_model.dart';

class RoutePost {
  final String routePostId;
  final String description;
  final List<RouteMarker> routeMarkers;
  final String userId;
  // final int likeCount;
  // final List<PostComment> comments;
  // final bool isLiked;
  // final bool isSaved;
  // final Timestamp uploadDT;
  RoutePost({this.routePostId, this.description, this.routeMarkers, this.userId
      // this.likeCount,
      // this.comments,
      // this.isLiked,
      // this.isSaved,
      // this.uploadDT,
      });

  Map<String, dynamic> toMap() => {
        'description': description,
        'routeMarkers': routeMarkers.map((e) => e.toMap()).toList(),
        'createdBy': userId,
      };

  factory RoutePost.fromMap(Map<dynamic, dynamic> json) {
    return RoutePost(
      routePostId: json['routePostId'],
      description: json['description'],
      routeMarkers: json['routeMarkers'],
      userId: json['createdBy'],
    );
  }

  factory RoutePost.fromDocument(DocumentSnapshot snapshot) {
    return RoutePost.fromMap(snapshot.data());
  }
}
