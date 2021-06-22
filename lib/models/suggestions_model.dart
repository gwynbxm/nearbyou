/*
 * Created by Gwyn Bong Xiao Min
 * Copyright (c) 2021. All rights reserved.
 * Last modified 2/6/21 4:14 PM
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
}
