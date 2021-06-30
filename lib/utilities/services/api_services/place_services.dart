/*
 * Created by Gwyn Bong Xiao Min
 * Copyright (c) 2021. All rights reserved.
 * Last modified 28/6/21 1:29 PM
 */

import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart';
import 'package:nearbyou/models/places_model.dart';
import 'package:nearbyou/models/suggestions_model.dart';

class PlaceApiProvider {
  final client = Client();
  PlaceApiProvider(this.sessionToken);

  final sessionToken;

  static final String androidKey = '';
  static final String iosKey = '';

  final apiKey = Platform.isAndroid ? androidKey : iosKey;

  Future<List<Suggestions>> fetchSuggestions(String input, String lang) async {
    final request = '';
    final response = await client.get(Uri.parse(request));

    if (response.statusCode == 200) {
      final result = json.decode(response.body);
      if (result['status'] == 'OK') {
        // List<Suggestions> suggestion =
        //     result.map((result) => Suggestions.fromJson(result)).toList();
        // return suggestion;
        return result['predictions']
            .map<Suggestions>(
                (p) => Suggestions(p['place_id'], p['description']))
            .toList();
      }
      if (result['status'] == 'ZERO_RESULTS') {
        return [];
      }
      throw Exception(result['error_message']);
    } else {
      throw Exception('Failed to fetch suggestion');
    }
  }
}
