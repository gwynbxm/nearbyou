/*
 * Created by Gwyn Bong Xiao Min
 * Copyright (c) 2021. All rights reserved.
 * Last modified 2/6/21 4:14 PM
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
