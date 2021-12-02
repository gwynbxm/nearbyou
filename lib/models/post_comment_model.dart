/*
 * Created by Gwyn Bong Xiao Min
 * Copyright (c) 2021. All rights reserved.
 * Last modified 25/7/21 12:24 AM
 */

import 'package:cloud_firestore/cloud_firestore.dart';

class PostComment {
  final String postCommentId;
  final String comment;
  final Timestamp dateTimeCommented;
  final String commentedBy;

  PostComment({
    this.postCommentId,
    this.comment,
    this.dateTimeCommented,
    this.commentedBy,
  });

  Map<String, dynamic> toMap() => {
        'postCommentId': postCommentId,
        'comment': comment,
        'dateTimeCommented': dateTimeCommented,
        'commentedBy': commentedBy,
      };

  factory PostComment.fromMap(Map<String, dynamic> json) {
    return PostComment(
        postCommentId: json['postCommentId'],
        comment: json['comment'],
        commentedBy: json['commentedBy'],
        dateTimeCommented: json['dateTimeCommented']);
  }

  factory PostComment.fromDocument(DocumentSnapshot snapshot) {
    return PostComment.fromMap(snapshot.data());
  }
}
