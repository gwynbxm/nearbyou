/*
 * Created by Gwyn Bong Xiao Min
 * Copyright (c) 2021. All rights reserved.
 * Last modified 28/6/21 1:18 PM
 */

class Places {
  String streetNo;
  String street;
  String city;
  String zipCode;

  Places({this.streetNo, this.street, this.city, this.zipCode});

  @override
  String toString() {
    // TODO: implement toString
    return 'Places(streetNumber: $streetNo, street: $street, city: $city, zipCode: $zipCode)';
  }
}
