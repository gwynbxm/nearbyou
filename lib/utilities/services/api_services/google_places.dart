/*
 * Created by Gwyn Bong Xiao Min
 * Copyright (c) 2021. All rights reserved.
 * Last modified 28/6/21 1:29 PM
 */

import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart';
import 'package:nearbyou/models/suggestions_model.dart';
import 'package:nearbyou/utilities/constants/api_key.dart';

class PlaceApiProvider {
  final client = Client();
  PlaceApiProvider(this.sessionToken);

  final sessionToken;

  final apiKey = Platform.isAndroid
      ? SecretKey.ANDROID_MAPS_API_KEY
      : SecretKey.IOS_MAPS_API_KEY;

  Future<List<Suggestions>> fetchSuggestions(String input, String lang) async {
    final request = '';
    final response = await client.get(Uri.parse(request));

    if (response.statusCode == 200) {
      final result = json.decode(response.body);
      if (result['status'] == 'OK') {
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
