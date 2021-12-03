/*
 * Created by Gwyn Bong Xiao Min
 * Copyright (c) 2021. All rights reserved.
 * Last modified 24/11/21 1:03 PM
 */

import 'dart:collection';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nearbyou/models/route_marker_model.dart';
import 'package:nearbyou/models/user_profile_model.dart';

class RoutePost {
  final String routePostId;
  final String description;
  final List<String> routeMarkerIds;
  final String createdBy;
  final Timestamp dateTimePosted;

  RoutePost({
    this.routePostId,
    this.description,
    this.routeMarkerIds,
    this.createdBy,
    this.dateTimePosted,
  });

  Map<String, dynamic> toMap() => {
        'description': description ?? '',
        'routeMarkers': routeMarkerIds ?? '',
        'createdBy': createdBy,
        'dateTimePosted': dateTimePosted,
      };

  factory RoutePost.fromMap(Map<String, dynamic> json) {
    return RoutePost(
      routePostId: json['postId'],
      description: json['description'] ?? '',
      routeMarkerIds: List<String>.from(json['routeMarkers']).toList(),
      createdBy: json['createdBy'],
      dateTimePosted: json['dateTimePosted'],
    );
  }

  factory RoutePost.fromDocument(DocumentSnapshot snapshot) {
    return RoutePost.fromMap(snapshot.data());
  }
}
