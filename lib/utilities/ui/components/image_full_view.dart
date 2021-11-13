/*
 * Created by Gwyn Bong Xiao Min
 * Copyright (c) 2021. All rights reserved.
 * Last modified 9/10/21 9:43 PM
 */

import 'package:flutter/material.dart';

class ImageFullView extends StatefulWidget {
  final String imgUrl;

  const ImageFullView(
    this.imgUrl,
  );

  @override
  _ImageFullViewState createState() => _ImageFullViewState();
}

class _ImageFullViewState extends State<ImageFullView> {
  @override
  Widget build(BuildContext context) {
    TransformationController controller = TransformationController();
    String velocity = "VELOCITY";
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(
          onPressed: () =>
              // TODO: implement proper pop of the screen
              Navigator.pop(context),
          color: Colors.black,
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        child: InteractiveViewer(
          transformationController: controller,
          panEnabled: true,
          minScale: 0.5,
          maxScale: 5.0,
          child: GestureDetector(
            child: Center(
              child: Image.network(
                widget.imgUrl,
                width: double.infinity,
              ),
            ),
            // onTap: () => buildSlideUpPanel,
            onTap: () => print('tapped'),
          ),
          onInteractionEnd: (ScaleEndDetails endDetails) {
            print(endDetails);
            print(endDetails.velocity);
            controller.value = Matrix4.identity();
            setState(() {
              velocity = endDetails.velocity.toString();
            });
          },
        ),
      ),
    );
  }
}
