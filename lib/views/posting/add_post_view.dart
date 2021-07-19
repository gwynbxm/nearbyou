/*
 * Created by Gwyn Bong Xiao Min
 * Copyright (c) 2021. All rights reserved.
 * Last modified 16/7/21 11:42 PM
 */

import 'package:flutter/material.dart';
import 'package:nearbyou/models/suggestions_model.dart';
import 'package:nearbyou/utilities/ui/components/rounded_icon_button.dart';
import 'package:nearbyou/utilities/ui/palette.dart';
import 'package:nearbyou/views/posting/components/speed_dial_widget.dart';
import 'package:nearbyou/views/home/components/address_search.dart';
import 'package:nearbyou/views/home/home_view.dart';
import 'package:uuid/uuid.dart';

import 'components/search_text_field.dart';

class AddPostView extends StatefulWidget {
  const AddPostView({Key key}) : super(key: key);

  @override
  _AddPostViewState createState() => _AddPostViewState();
}

class _AddPostViewState extends State<AddPostView> {
  TextEditingController _startPointCon = TextEditingController();
  TextEditingController _endPointCon = TextEditingController();
  final startPointFocus = FocusNode();
  final endPointFocus = FocusNode();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        //Before closing, prompt user if want to save as draft or discard post
        leading: CloseButton(
          onPressed: () => Navigator.of(context).pop(),
          color: Colors.black,
        ),
        actions: [
          //this should save to firestore
          IconButton(
              icon: Icon(Icons.check, color: Colors.black), onPressed: () {}),
        ],
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      floatingActionButton: SpeedDialWidget(),
      body: Stack(
        children: [
          SafeArea(
            child: Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: EdgeInsets.only(top: 10.0, bottom: 10.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SearchFieldContainer(
                      controller: _startPointCon,
                      focusNode: startPointFocus,
                      labelText: "Start",
                      hintText: "Choose starting point",
                      prefixIcon: Icon(
                        Icons.location_on_rounded,
                        color: textLightColor,
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(Icons.my_location),
                        color: primaryColor,
                        onPressed: () {},
                      ),
                      onTap: () async {
                        final sessionToken = Uuid().v4();
                        final Suggestions result = await showSearch(
                          context: context,
                          delegate: PlacesSearch(sessionToken),
                        );
                        if (result != null) {
                          setState(() {
                            _startPointCon.text = result.placeDesc;
                          });
                        }
                      },
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    SearchFieldContainer(
                      controller: _endPointCon,
                      focusNode: endPointFocus,
                      labelText: "Destination",
                      hintText: "Choose destination point",
                      prefixIcon: Icon(
                        Icons.flag,
                        color: textLightColor,
                      ),
                      onTap: () async {
                        final sessionToken = Uuid().v4();
                        final Suggestions result = await showSearch(
                          context: context,
                          delegate: PlacesSearch(sessionToken),
                        );
                        if (result != null) {
                          setState(() {
                            _endPointCon.text = result.placeDesc;
                          });
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _startPointCon.dispose();
    _endPointCon.dispose();
    super.dispose();
  }
}
