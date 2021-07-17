/*
 * Created by Gwyn Bong Xiao Min
 * Copyright (c) 2021. All rights reserved.
 * Last modified 14/7/21 12:10 PM
 */

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nearbyou/utilities/ui/palette.dart';
import 'package:nearbyou/views/profile/user_profile_view.dart';

class EditProfileView extends StatefulWidget {
  const EditProfileView({Key key}) : super(key: key);

  @override
  _EditProfileViewState createState() => _EditProfileViewState();
}

class _EditProfileViewState extends State<EditProfileView> {
  File _pickedFile;

  _showPicker(context) {
    showModalBottomSheet(
        context: context,
        builder: (builder) {
          return SafeArea(
            child: Container(
              child: Wrap(
                children: [
                  ListTile(
                    leading: Icon(
                      Icons.photo_camera_outlined,
                      color: iconColor,
                    ),
                    title: Text('Take photo'),
                    onTap: () {
                      _cameraImage();
                      Navigator.of(context).pop();
                    },
                  ),
                  ListTile(
                    leading: Icon(
                      Icons.photo_library_outlined,
                      color: iconColor,
                    ),
                    title: Text('Choose existing photo'),
                    onTap: () {
                      _galleryImage();
                      Navigator.of(context).pop();
                    },
                  ),
                  ListTile(
                    leading: Icon(
                      Icons.highlight_remove_outlined,
                      color: Colors.red,
                    ),
                    title: Text('Remove photo'),
                    onTap: () {},
                  )
                ],
              ),
            ),
          );
        });
  }

  _cameraImage() async {
    PickedFile img = await ImagePicker().getImage(source: ImageSource.camera);
    setState(() {
      _pickedFile = File(img.path);
    });
  }

  _galleryImage() async {
    PickedFile img = await ImagePicker().getImage(source: ImageSource.gallery);
    setState(() {
      _pickedFile = File(img.path);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(
          // before going back, prompt user whether they want to save or not
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ProfileView()),
          ),
          color: Colors.black,
        ),
        actions: [
          //save profile details
          IconButton(
              icon: Icon(Icons.check, color: Colors.black), onPressed: () {}),
        ],
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView(
        physics: BouncingScrollPhysics(),
        children: [
          Center(
            child: Stack(
              children: [
                GestureDetector(
                  onTap: () => _showPicker(context),
                  child: CircleAvatar(
                    radius: 48,
                    backgroundImage:
                        AssetImage('assets/images/default-profile.png'),
                    child: _pickedFile != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(50),
                            child: Image.file(
                              _pickedFile,
                              width: 100,
                              height: 100,
                              fit: BoxFit.fitHeight,
                            ))
                        : Container(
                            decoration: BoxDecoration(
                                color: Colors.white24,
                                borderRadius: BorderRadius.circular(50)),
                            width: 100,
                            height: 100,
                            child: Icon(
                              Icons.camera_alt_outlined,
                              color: Colors.black,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
