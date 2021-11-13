/*
 * Created by Gwyn Bong Xiao Min
 * Copyright (c) 2021. All rights reserved.
 * Last modified 13/11/21 10:29 AM
 */

import 'dart:convert';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:nearbyou/models/route_marker_model.dart';
import 'package:nearbyou/utilities/ui/components/image_full_view.dart';

class CarouselWidget extends StatefulWidget {
  final List<String> imgList;
  const CarouselWidget(this.imgList);

  @override
  _CarouselWidgetState createState() => _CarouselWidgetState();
}

class _CarouselWidgetState extends State<CarouselWidget> {
  @override
  Widget build(BuildContext context) {
    return CarouselSlider(
        items: widget.imgList.map((url) {
          return Container(
            width: MediaQuery.of(context).size.width,
            margin: EdgeInsets.symmetric(horizontal: 5.0),
            child: GestureDetector(
              child: Image.memory(
                base64Decode(url),
                fit: BoxFit.cover,
              ),
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
