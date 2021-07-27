/*
 * Created by Gwyn Bong Xiao Min
 * Copyright (c) 2021. All rights reserved.
 * Last modified 16/7/21 11:42 PM
 */

import 'package:flutter/material.dart';
import 'package:nearbyou/models/route_data_model.dart';
import 'package:nearbyou/models/suggestions_model.dart';
import 'package:nearbyou/utilities/ui/components/rounded_icon_button.dart';
import 'package:nearbyou/utilities/ui/palette.dart';
import 'package:nearbyou/views/posting/add_route_view.dart';
import 'package:nearbyou/views/posting/components/speed_dial_widget.dart';
import 'package:nearbyou/views/home/components/address_search.dart';
import 'package:nearbyou/views/home/home_view.dart';
import 'package:nearbyou/views/posting/edit_route_view.dart';
import 'package:uuid/uuid.dart';

import 'components/divider_widget.dart';
import 'components/search_text_field.dart';

class AddPostView extends StatefulWidget {
  const AddPostView({Key key}) : super(key: key);

  @override
  _AddPostViewState createState() => _AddPostViewState();
}

class _AddPostViewState extends State<AddPostView> {
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  TextEditingController _startPointCon = TextEditingController();
  TextEditingController _endPointCon = TextEditingController();
  TextEditingController _postDescCon = TextEditingController();

  TextEditingController _locationNameCon = TextEditingController();
  TextEditingController _captionCon = TextEditingController();

  final startPointFocus = FocusNode();
  final endPointFocus = FocusNode();
  final postDescFocus = FocusNode();
  final _locationNameFocus = FocusNode();
  final _captionFocus = FocusNode();

  List<RouteData> routeData = [];
  List<String> _items = [];

  Future<String> searchPlaces() async {
    final sessionToken = Uuid().v4();
    final Suggestions result = await showSearch(
      context: context,
      delegate: PlacesSearch(sessionToken),
    );
    if (result != null) {
      return result.placeDesc;
    }
    return result.placeDesc;
  }

  void reorderRouteData(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) {
        newIndex -= 1;
      }
      final items = _items.removeAt(oldIndex);
      _items.insert(newIndex, items);
    });
  }

  _buildCard(String items, int index) {
    return Card(
      color: Colors.white,
      key: ValueKey(index),
      elevation: 2,
      child: Column(
        children: [
          ExpansionTile(
            title: Text('Location name'),
            trailing: ReorderableDragStartListener(
              index: 0,
              child: Icon(Icons.drag_handle),
            ),
            children: [
              Container(
                margin: EdgeInsets.symmetric(horizontal: 25),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                          controller: _locationNameCon,
                          focusNode: _locationNameFocus,
                          decoration: InputDecoration(
                            hintText: 'Location name',
                          ),
                          validator: (value) => value.isEmpty
                              ? 'Location name cannot be blank'
                              : null),
                      SizedBox(
                        height: 10,
                      ),
                      TextFormField(
                          controller: _captionCon,
                          focusNode: _captionFocus,
                          decoration: InputDecoration(
                            hintText: 'Caption',
                          ),
                          validator: (value) =>
                              value.isEmpty ? 'Caption cannot be blank' : null),
                    ],
                  ),
                ),
              ),
              SizedBox(
                height: 10,
              ),
              // Container(
              //   alignment: Alignment.center,
              //   child: Image(
              //       image: AssetImage('assets/images/default-profile.png')),
              // ),
            ],
          ),
          ButtonTheme(
            child: ButtonBar(
              alignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  icon: Icon(Icons.edit),
                  onPressed: () {},
                ),
                IconButton(
                  icon: Icon(
                    Icons.delete,
                    color: Colors.redAccent,
                  ),
                  onPressed: () {
                    setState(() {
                      _items.removeAt(index);
                    });
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  _addRouteCard() {
    setState(() {
      _items.add('hello');
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        startPointFocus.unfocus();
        endPointFocus.unfocus();
        postDescFocus.unfocus();
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          leading: CloseButton(
            onPressed: () => Navigator.of(context).pop(),
            color: Colors.black,
          ),
          title: Text(
            'Create Post',
            style: TextStyle(color: Colors.black),
          ),
          actions: [
            IconButton(
                icon: Icon(Icons.check, color: Colors.black), onPressed: () {}),
          ],
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        floatingActionButton: RoundedIconButton(
          icon: Icons.add,
          onPressed: _addRouteCard,
        ),
        // SpeedDialWidget(),
        body: Column(
          children: [
            Expanded(
              flex: 3,
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
                          final place = await searchPlaces();
                          setState(() {
                            _startPointCon.text = place;
                          });
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
                          final place = await searchPlaces();
                          setState(() {
                            _endPointCon.text = place;
                          });
                        },
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      buildDivider(),
                      Container(
                        margin: EdgeInsets.symmetric(horizontal: 30),
                        child: SingleChildScrollView(
                          child: TextFormField(
                            focusNode: postDescFocus,
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: 'Write something here ....',
                              hintMaxLines: 4,
                            ),
                            controller: _postDescCon,
                            keyboardType: TextInputType.multiline,
                            maxLines: 5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            buildDivider(),
            Expanded(
              flex: 3,
              child: ReorderableListView.builder(
                  itemBuilder: (context, index) {
                    return _buildCard(_items[index], index);
                  },
                  itemCount: _items.length,
                  onReorder: reorderRouteData),
            ),
          ],
        ),
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
