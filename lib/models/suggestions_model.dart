/*
 * Created by Gwyn Bong Xiao Min
 * Copyright (c) 2021. All rights reserved.
 * Last modified 5/7/21 11:46 AM
 */

class Suggestions {
  final String placeId;
  final String placeName;
  final String placeDesc;

  Suggestions({this.placeId, this.placeName, this.placeDesc});

  @override
  String toString() {
    // TODO: implement toString
    return 'Suggestions(placeId: $placeId, placeName: $placeName, description: $placeDesc)';
  }

  factory Suggestions.fromMap(Map<String, dynamic> json) {
    return Suggestions(
        placeId: json['place_id'],
        placeName: json['structured_formatting']['main_text'],
        placeDesc: json['structured_formatting']['secondary_text']);
  }
}
