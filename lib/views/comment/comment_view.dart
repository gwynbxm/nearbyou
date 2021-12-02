/*
 * Created by Gwyn Bong Xiao Min
 * Copyright (c) 2021. All rights reserved.
 * Last modified 27/11/21 4:54 PM
 */

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:nearbyou/models/post_comment_model.dart';
import 'package:nearbyou/models/route_marker_model.dart';
import 'package:nearbyou/models/route_post_model.dart';
import 'package:nearbyou/models/user_profile_model.dart';
import 'package:nearbyou/utilities/constants/constants.dart';
import 'package:nearbyou/utilities/services/firebase_services/firestore.dart';
import 'package:nearbyou/utilities/ui/components/progress_icon.dart';
import 'package:nearbyou/utilities/ui/palette.dart';
import 'package:nearbyou/utilities/ui/components/carousel_widget.dart';
import 'package:timeago/timeago.dart' as timeAgo;

final FirebaseAuth _auth = FirebaseAuth.instance;

class CommentView extends StatefulWidget {
  final RoutePost routePost;
  final List<RouteMarker> postMarkers;
  final UserData userData;

  CommentView({this.routePost, this.postMarkers, this.userData});

  @override
  _CommentViewState createState() => _CommentViewState();
}

class _CommentViewState extends State<CommentView> {
  TextEditingController commentCon = TextEditingController();
  final commentFocus = FocusNode();

  bool isLoading = false;

  UserData commentator;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getComments();
  }

  currentUserId() {
    return _auth.currentUser.uid; //get current signed in user
  }

  Future<List<PostComment>> getComments() async {
    List<PostComment> commentList = [];
    QuerySnapshot snap = await postCollection
        .doc(widget.routePost.routePostId)
        .collection(comments)
        .orderBy('dateTimeCommented', descending: true)
        .get();

    setState(() {
      isLoading = false;
      commentList =
          snap.docs.map((doc) => PostComment.fromDocument(doc)).toList();
    });
    return commentList;
  }

  Future<UserData> getCommentatorData(String commentedBy) async {
    DocumentSnapshot snap = await profileCollection.doc(commentedBy).get();

    UserData user = UserData.fromDocument(snap);

    return user;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        commentFocus.unfocus();
      },
      child: Scaffold(
        appBar: AppBar(
          leading: BackButton(
            onPressed: () =>
                // TODO: implement proper pop of the screen
                Navigator.pop(context),
            color: Colors.black,
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Text(
            'Comments',
            style: TextStyle(color: Colors.black),
          ),
        ),
        body: Stack(
          children: [
            Column(
              children: [
                Flexible(
                  child: ListView(
                    children: [
                      buildPost(),
                      Divider(
                        thickness: 1.5,
                      ),
                      buildComments(),
                    ],
                  ),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    decoration: BoxDecoration(color: Colors.white),
                    padding: EdgeInsets.all(5),
                    child: ListTile(
                      contentPadding: EdgeInsets.all(10),
                      title: TextField(
                        textCapitalization: TextCapitalization.sentences,
                        controller: commentCon,
                        focusNode: commentFocus,
                        style: TextStyle(
                          fontSize: 15,
                        ),
                        decoration: InputDecoration(
                            focusColor: primaryColor,
                            border: InputBorder.none,
                            hintText: "Write your comment..",
                            hintStyle:
                                TextStyle(fontSize: 15, color: Colors.grey)),
                      ),
                      trailing: GestureDetector(
                        onTap: () async {
                          PostComment comment = PostComment(
                              comment: commentCon.text,
                              dateTimeCommented: timestamp,
                              commentedBy: currentUserId());
                          await DatabaseServices.uploadComment(
                              widget.routePost.routePostId, comment);

                          //clear textfield
                          commentCon.clear();
                        },
                        child: Icon(
                          Icons.send,
                          color: primaryColor,
                        ),
                      ),
                    ),
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }

  buildPost() {
    return Container(
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: [
            ListTile(
              leading: CircleAvatar(
                radius: 24,
                backgroundImage: widget.userData?.profilePhoto?.isEmpty ?? true
                    ? AssetImage('assets/images/default-profile.png')
                    : NetworkImage(widget.userData.profilePhoto),
              ),
              title: widget.userData.name == null
                  ? Text(
                      widget.userData.username,
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    )
                  : Text(
                      widget.userData.name,
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
              // Text(
              //   // _auth.currentUser.displayName,
              //   widget.userData.name,
              //   style: TextStyle(
              //       fontSize: 20, fontWeight: FontWeight.bold, color: bgColor),
              // ),
              subtitle: Text(
                  timeAgo.format(widget.routePost.dateTimePosted.toDate())),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(widget.routePost.description)),
            ),
          ],
        ),
      ),
    );
  }

  buildComments() {
    return FutureBuilder<List<PostComment>>(
        future: getComments(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return circularProgressIndicator();
          } else {
            if (snapshot.data.length == 0) {
              return Container(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(top: 20.0),
                      child: Text(
                        "No comments",
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 18.0,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }
            return ListView.builder(
              reverse: true,
              scrollDirection: Axis.vertical,
              itemCount: snapshot.data.length,
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemBuilder: (BuildContext context, int index) {
                return buildComment(snapshot.data[index], currentUserId());
              },
            );
          }
        });
  }

  buildComment(PostComment comment, String currentUserId) {
    return FutureBuilder(
      future: getCommentatorData(comment.commentedBy),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return SizedBox.shrink();
        }
        UserData commentator = snapshot.data;

        return Card(
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              ListTile(
                leading: CircleAvatar(
                  radius: 20,
                  backgroundImage: commentator?.profilePhoto?.isEmpty ?? true
                      ? AssetImage('assets/images/default-profile.png')
                      : NetworkImage(commentator.profilePhoto),
                ),
                title: Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: Text(
                        commentator.username,
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: textLightColor),
                      ),
                    ),
                    // SizedBox(width: 5),
                    Expanded(
                      flex: 3,
                      child: Text(
                        comment.comment,
                        style: TextStyle(fontSize: 15),
                      ),
                    )
                  ],
                ),
                subtitle:
                    Text(timeAgo.format(comment.dateTimeCommented.toDate())),
              ),

              // Container(
              //   alignment: Alignment.centerLeft,
              //   child: Text(
              //     comment.comment,
              //     style: TextStyle(
              //       fontSize: 10,
              //     ),
              //   ),
              // )
            ],
          ),
        );
      },
    );
  }
}
