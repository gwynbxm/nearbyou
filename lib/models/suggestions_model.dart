/*
 * Created by Gwyn Bong Xiao Min
 * Copyright (c) 2021. All rights reserved.
 * Last modified 28/6/21 1:31 PM
 */

class Suggestions {
  final String placeId;
  final String placeDesc;

  Suggestions(this.placeId, this.placeDesc);

  @override
  String toString() {
    // TODO: implement toString
    return 'Suggestions(description: $placeDesc, placeId: $placeId)';
  }
// Suggestions({this.placeId, this.placeDesc});
  // factory Suggestions.fromJson(Map<String, dynamic> json) {
  //   return Suggestions(
  //     placeId: json['place_id'],
  //     placeDesc: json['description'],
  //   );
  // }
}
