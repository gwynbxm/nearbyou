/*
 * Created by Gwyn Bong Xiao Min
 * Copyright (c) 2021. All rights reserved.
 * Last modified 18/8/21 4:54 PM
 */

import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nearbyou/models/route_marker_model.dart';
import 'package:nearbyou/utilities/ui/components/custom_dialog_box.dart';
import 'package:nearbyou/utilities/ui/components/rounded_icon_button.dart';
import 'package:nearbyou/utilities/ui/palette.dart';

import 'components/appbar_text_button.dart';

class AddRouteDetailsView extends StatefulWidget {
  final RouteMarker routeMarker;

  const AddRouteDetailsView({Key key, this.routeMarker}) : super(key: key);

  @override
  _AddRouteDetailsViewState createState() => _AddRouteDetailsViewState();
}

class _AddRouteDetailsViewState extends State<AddRouteDetailsView> {
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController _titleCon = TextEditingController();
  TextEditingController _captionCon = TextEditingController();

  final _titleFocus = FocusNode();
  final _captionFocus = FocusNode();

  List<File> _pickedImages = [];
  List<String> images = [];

  ScrollController _imageScrollCon = ScrollController();

  @override
  void initState() {
    setState(() {
      print(widget.routeMarker);
    });
    super.initState();
  }

  void _showDialog() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Discard draft?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text('CANCEL'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text('DISCARD'),
              ),
            ],
          );
        });
  }

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
      _pickedImages.add(File(img.path));
      final bytes = File(img.path).readAsBytesSync();
      String imgIn64 = base64Encode(bytes);
      images.add(imgIn64);
    });
  }

  _galleryImage() async {
    PickedFile img = await ImagePicker().getImage(source: ImageSource.gallery);
    setState(() {
      _pickedImages.add(File(img.path));
      // images.add(File(img.path).toString());
      final bytes = File(img.path).readAsBytesSync();
      String imgIn64 = base64Encode(bytes);
      images.add(imgIn64);
    });
  }

  void reorderRouteData(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) {
        newIndex -= 1;
      }
      final items = _pickedImages.removeAt(oldIndex);
      _pickedImages.insert(newIndex, items);
    });
  }

  _buildImagesCard(File pickedImages, int index) {
    final image = _pickedImages[index];
    return Card(
      color: Colors.white,
      key: ValueKey(index),
      elevation: 2,
      child: ExpansionTile(
        title: Text(''),
        children: [
          GestureDetector(
            onTap: () => print('card tapped'),
            onLongPress: () => print('card long pressed'),
            child: Image(
              image: FileImage(image),
              fit: BoxFit.cover,
            ),
          ),
        ],
      ),
    );
  }

  _saveRouteData() {
    widget.routeMarker.title = _titleCon.text ?? '';
    widget.routeMarker.caption = _captionCon.text ?? '';
    widget.routeMarker.imageList = images ?? '';

    //check for blank. if blank
    if (_titleCon.text.isEmpty || _captionCon.text.isEmpty || images.isEmpty) {
      return showDialog(
          context: context,
          builder: (BuildContext context) {
            return CustomDialogBox(
              icon: Icons.warning,
              bgAvatarColor: Colors.redAccent,
              iconColor: Colors.white,
              dialogTitle: 'Oh no!',
              dialogSubtitle:
                  'Noticed there are fields left blank, are you sure you want to save with empty fields?',
              leftButtonText: 'Cancel',
              rightButtonText: 'Save',
              leftButtonTextColor: Colors.black,
              rightButtonTextColor: primaryColor,
              onPressedLeftButton: () => Navigator.of(context).pop(),
              onPressedRightButton: () {
                Navigator.of(context).pop();
                Navigator.pop(context, widget.routeMarker);
              },
            );
          });
    } else {
      return showDialog(
          context: context,
          builder: (BuildContext context) {
            return CustomDialogBox(
              icon: Icons.auto_awesome,
              bgAvatarColor: iconColor,
              iconColor: Colors.white,
              dialogTitle: 'Awesome!',
              dialogSubtitle:
                  'Thank you for your insightful details! You may come back to edit it later!',
              rightButtonText: 'Dismiss',
              rightButtonTextColor: primaryColor,
              onPressedRightButton: () {
                Navigator.pop(context, widget.routeMarker);
                Navigator.of(context).pop();
              },
            );
          });
    }
    //else
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _titleFocus.unfocus();
        _captionFocus.unfocus();
      },
      child: Scaffold(
        appBar: AppBar(
          leading: CloseButton(
            onPressed: _showDialog,
            color: Colors.black,
          ),
          title: Text(
            'Add Route Details',
            style: TextStyle(color: Colors.black),
          ),
          actions: [
            AppBarTextButton(
              text: 'SAVE',
              onPressed: _saveRouteData,
            ),
          ],
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        floatingActionButton: RoundedIconButton(
          icon: Icons.add,
          onPressed: () => _showPicker(context),
        ),
        body: Container(
          padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  TextFormField(
                      controller: _titleCon,
                      focusNode: _titleFocus,
                      decoration: InputDecoration(
                        hintText: 'Title',
                      ),
                      validator: (value) => value.isEmpty
                          ? 'Location name cannot be blank'
                          : null),
                  SizedBox(
                    height: 15,
                  ),
                  TextFormField(
                      controller: _captionCon,
                      focusNode: _captionFocus,
                      decoration: InputDecoration(
                        hintText: 'Caption',
                      ),
                      validator: (value) =>
                          value.isEmpty ? 'Caption cannot be blank' : null),
                  SizedBox(
                    height: 15,
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height,
                    padding: EdgeInsets.all(4),
                    child: ListView.builder(
                      controller: _imageScrollCon,
                      scrollDirection: Axis.vertical,
                      physics: const AlwaysScrollableScrollPhysics(),
                      itemBuilder: (context, index) {
                        return _buildImagesCard(_pickedImages[index], index);
                      },
                      itemCount: _pickedImages.length,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
