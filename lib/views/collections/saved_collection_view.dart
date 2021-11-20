/*
 * Created by Gwyn Bong Xiao Min
 * Copyright (c) 2021. All rights reserved.
 * Last modified 9/10/21 5:38 PM
 */
import 'package:flutter/material.dart';
import 'package:nearbyou/utilities/ui/components/custom_dialog_box.dart';
import 'package:nearbyou/views/home/home_view.dart';

class SavedCollectionView extends StatefulWidget {
  const SavedCollectionView({Key key}) : super(key: key);

  @override
  _SavedCollectionViewState createState() => _SavedCollectionViewState();
}

class _SavedCollectionViewState extends State<SavedCollectionView> {
  ScrollController scrollController = ScrollController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(
          onPressed: () =>
              // TODO: implement proper pop of the screen
              Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => HomeScreen()),
          ),
          color: Colors.black,
        ),
        title: Text(
          'Saved Collections',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView(
        children: [
          buildSavedPosts(),
        ],
      ),
    );
  }

  buildSavedPosts() {
    return SingleChildScrollView(
      child: ListView.builder(
        controller: scrollController,
        physics: NeverScrollableScrollPhysics(),
        primary: false,
        scrollDirection: Axis.vertical,
        shrinkWrap: true,
        itemCount: 2,
        itemBuilder: (context, index) {
          return buildPostCards(context, index);
        },
      ),
    );
  }

  buildPostCards(BuildContext context, int index) {
    return GestureDetector(
      onTap: () {},
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: Row(
          children: [
            Expanded(
              flex: 5,
              child: Column(
                children: [
                  ListTile(
                    title: Text(
                      'Post Title',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text('Saved 15 hours ago'),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 1,
              child: Icon(Icons.more_vert),
            ),
          ],
        ),
      ),
    );
  }
}
