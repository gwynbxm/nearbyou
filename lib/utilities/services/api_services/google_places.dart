/*
 * Created by Gwyn Bong Xiao Min
 * Copyright (c) 2021. All rights reserved.
 * Last modified 16/7/21 10:54 AM
 */

import 'dart:convert';
import 'dart:io';

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart';
import 'package:nearbyou/models/places_model.dart';
import 'package:nearbyou/models/suggestions_model.dart';
import 'package:nearbyou/utilities/constants/api_key.dart';
import 'package:geolocator/geolocator.dart';

class PlaceApiProvider {
  final client = Client();
  PlaceApiProvider(this.sessionToken);

  //this affects billing behaviour
  //should not use same session token for every request by the app
  //best practice: generate a new token for every request every search session
  final sessionToken;

  final apiKey = Platform.isAndroid
      ? SecretKey.ANDROID_MAPS_API_KEY
      : SecretKey.IOS_MAPS_API_KEY;

  Future<List<Suggestions>> fetchSuggestions(String input, String lang) async {
    final request =
        'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$input&types=&components=country:sg&language=$lang&key=$apiKey&sessiontoken=$sessionToken';
    final response = await client.get(Uri.parse(request));

    if (response.statusCode == 200) {
      final result = json.decode(response.body);
      if (result['status'] == 'OK') {
        // return result['predictions']
        //     .map<Suggestions>((p) => Suggestions(
        //         p['place_id'],
        //         p['structured_formatting']['main_text'],
        //         p['structured_formatting']['secondary_text']))
        //     .toList();

        final value = result['predictions'] as List;
        return value.map((place) => Suggestions.fromMap(place)).toList();
      }
      //means the call was successful but no results
      if (result['status'] == 'ZERO_RESULTS') {
        return [];
      }
      throw Exception(result['error_message']);
    } else {
      throw Exception('Failed to fetch suggestion');
    }
  }

  // Future<List<Places>> getNearby(
  //     {LatLng userLocation, double radius, String type, String keyword}) async {
  //   String url =
  //       'https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=${userLocation.latitude},${userLocation.longitude}&radius=$radius&type=$type&keyword=$keyword&key=$apiKey';
  //   final response = await client.get(Uri.parse(url));
  //   final values = jsonDecode(response.body);
  //   final List result = values['results'];
  //   return result.map((e) => Places.fromMap(e)).toList();
  // }

  Future<Places> getPlacesDetails(String placeID) async {
    String url =
        'https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeID&key=$apiKey&sessiontoken=$sessionToken';
    final response = await client.get(Uri.parse(url));
    final values = json.decode(response.body);
    final result = values['result'] as Map<String, dynamic>;
    return Places.fromMap(result);
  }

  Future<Places> getDetailsByCoordinates(double lat, double lng) async {
    String url = '';
    final response = await client.get(Uri.parse(url));
    final values = json.decode(response.body);
    final result = values['result'] as Map<String, dynamic>;
    return Places.fromMap(result);
  }
}
