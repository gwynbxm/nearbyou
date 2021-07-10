/*
 * Created by Gwyn Bong Xiao Min
 * Copyright (c) 2021. All rights reserved.
 * Last modified 29/6/21 11:42 AM
 */

import 'package:flutter/material.dart';
import 'package:nearbyou/models/suggestions_model.dart';
import 'package:nearbyou/utilities/services/api_services/google_places.dart';

class PlacesSearch extends SearchDelegate<Suggestions> {
  PlacesSearch(this.sessionToken) {
    apiClient = PlaceApiProvider(sessionToken);
  }

  final sessionToken;
  PlaceApiProvider apiClient;

  @override
  List<Widget> buildActions(BuildContext context) {
    // return null;
    return [
      IconButton(
        tooltip: 'Clear',
        icon: Icon(Icons.clear),
        onPressed: () => query = '',
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () => close(context, null),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return null;
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return FutureBuilder(
      future: query.isEmpty
          ? null
          : apiClient.fetchSuggestions(
              query, Localizations.localeOf(context).languageCode),
      builder: (context, snapshot) => query.isEmpty
          ? Container(
              padding: EdgeInsets.all(16.0),
              child: Text('hello'),
            )
          : snapshot.hasData
              ? ListView.builder(
                  itemBuilder: (context, index) => ListTile(
                    //display data returned from our future
                    title:
                        Text((snapshot.data[index] as Suggestions).placeDesc),
                    onTap: () {
                      close(context, snapshot.data[index] as Suggestions);
                    },
                  ),
                  itemCount: snapshot.data.length,
                )
              : Container(child: Text('Loading .....')),
    );
  }
}
