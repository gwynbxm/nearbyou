/*
 * Created by Gwyn Bong Xiao Min
 * Copyright (c) 2021. All rights reserved.
 * Last modified 1/11/21 10:58 AM
 */

import 'dart:convert';
import 'dart:io';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:nearbyou/models/route_marker_model.dart';
import 'package:nearbyou/utilities/constants/constants.dart';
import 'package:nearbyou/utilities/ui/components/image_full_view.dart';

class CarouselWidget extends StatefulWidget {
  final List<RouteMarker> postMarkers;
  const CarouselWidget(this.postMarkers);

  @override
  _CarouselWidgetState createState() => _CarouselWidgetState();
}

class _CarouselWidgetState extends State<CarouselWidget> {
  bool isLoading = false;
  List<String> images = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getImages();
  }

  getImages() async {
    setState(() {
      isLoading = true;
    });

    //in a list of markers
    for (int i = 0; i < widget.postMarkers.length; i++) {
      //get their images
      for (int j = 0; j < widget.postMarkers[i].imageList.length; j++) {
        setState(() {
          isLoading = false;
          //combine all images into a list
          images.add(widget.postMarkers[i].imageList[
              j]); //TODO: didnt combine with other route marker data!!
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return CarouselSlider(
        items: images.map((url) {
          return Container(
            width: MediaQuery.of(context).size.width,
            margin: EdgeInsets.symmetric(horizontal: 5.0),
            child: GestureDetector(
              child: Image.memory(
                base64Decode(url),
                fit: BoxFit.cover,
              ),
              // Image(
              // image: File(url),
              // fit: BoxFit.cover,
              // ),
              onTap: () => Navigator.push(context,
                  MaterialPageRoute(builder: (context) => ImageFullView(url))),
            ),
          );
        }).toList(),
        options: CarouselOptions(
            autoPlay: false,
            enableInfiniteScroll: false,
            viewportFraction: 0.95));
  }
}
