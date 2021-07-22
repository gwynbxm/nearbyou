/*
 * Created by Gwyn Bong Xiao Min
 * Copyright (c) 2021. All rights reserved.
 * Last modified 14/7/21 12:10 PM
 */

import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nearbyou/models/user_profile_model.dart';
import 'package:nearbyou/utilities/services/firebase_services/firestore.dart';
import 'package:nearbyou/utilities/services/firebase_services/storage.dart';
import 'package:nearbyou/utilities/ui/palette.dart';
import 'package:nearbyou/views/profile/user_profile_view.dart';

import 'components/text_form_field.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;

class EditProfileView extends StatefulWidget {
  const EditProfileView({Key key}) : super(key: key);

  @override
  _EditProfileViewState createState() => _EditProfileViewState();
}

class _EditProfileViewState extends State<EditProfileView> {
  File _pickedFile;
  String _currentImg;

  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController _editUsernameCon = TextEditingController();
  TextEditingController _editEmailCon = TextEditingController();

  final _focusEditUsername = FocusNode();

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

  void updateProfile() async {
    String pickedFileUrl = '';

    if (_formKey.currentState.validate()) {
      if (_pickedFile != null) {
        pickedFileUrl = await StorageService.uploadProfilePhoto(
            _pickedFile.path, _pickedFile, _auth.currentUser.uid);
      } else {
        pickedFileUrl = _currentImg;
      }
      UserProfile userProfile =
          UserProfile.withoutEmail(_editUsernameCon.text, pickedFileUrl);

      await DatabaseServices.updateUser(userProfile, _auth.currentUser.uid);
      Navigator.popAndPushNamed(context, '/');
    } else {
      print('unable to update form');
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _focusEditUsername.unfocus();
      },
      child: Scaffold(
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
                icon: Icon(Icons.check, color: Colors.black),
                onPressed: updateProfile),
          ],
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: FutureBuilder(
          future: DatabaseServices.getUser(_auth.currentUser.uid),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Container(
                  alignment: FractionalOffset.center,
                  child: CircularProgressIndicator());
            }

            UserProfile userProfile = UserProfile.fromDocument(snapshot.data);
            _editUsernameCon.text = userProfile.username;
            _editEmailCon.text = userProfile.emailAddress;
            _currentImg = userProfile.profilePhoto;

            return ListView(
              physics: BouncingScrollPhysics(),
              children: [
                Container(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        GestureDetector(
                          onTap: () => _showPicker(context),
                          child: CircleAvatar(
                            radius: 48,
                            backgroundImage:
                                userProfile?.profilePhoto?.isEmpty ?? true
                                    ? AssetImage(
                                        'assets/images/default-profile.png')
                                    : NetworkImage(userProfile.profilePhoto),
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
                                        borderRadius:
                                            BorderRadius.circular(50)),
                                    width: 100,
                                    height: 100,
                                    child: Icon(
                                      Icons.camera_alt_outlined,
                                      color: Colors.black,
                                    ),
                                  ),
                          ),
                        ),
                        SizedBox(
                          height: 24,
                        ),
                        Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              ProfileInputField(
                                  controller: _editUsernameCon,
                                  focusNode: _focusEditUsername,
                                  hintText: 'Username',
                                  labelText: 'Username',
                                  icon: Icons.person_rounded,
                                  validator: (value) => value.isEmpty
                                      ? 'Username cannot be blank'
                                      : null),
                              ProfileInputField(
                                  controller: _editEmailCon,
                                  hintText: 'Email Address',
                                  labelText: 'Email Address',
                                  icon: Icons.person_rounded,
                                  validator: (value) => value.isEmpty
                                      ? 'Email cannot be blank'
                                      : null),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                )
              ],
            );
          },
        ),
      ),
    );
  }
}
