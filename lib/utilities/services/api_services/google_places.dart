/*
 * Created by Gwyn Bong Xiao Min
 * Copyright (c) 2021. All rights reserved.
 * Last modified 16/7/21 10:54 AM
 */

import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart';
import 'package:nearbyou/models/places_model.dart';
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
        //either way works
        // return result['predictions']
        //     .map<Suggestions>((p) => Suggestions(
        //         p['place_id'],
        //         p['structured_formatting']['main_text'],
        //         p['structured_formatting']['secondary_text']))
        //     .toList();

        final value = result['predictions'] as List;
        return value.map((place) => Suggestions.fromMap(place)).toList();
      }
      if (result['status'] == 'ZERO_RESULTS') {
        return [];
      }
      throw Exception(result['error_message']);
    } else {
      throw Exception('Failed to fetch suggestion');
    }
  }

  Future<Places> getPlacesDetails(String placeID) async {
    String url = '';
    final response = await client.get(Uri.parse(url));
    final values = json.decode(response.body);
    final result = values['result'] as Map<String, dynamic>;
    return Places.fromMap(result);
  }
}
