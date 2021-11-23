/*
 * Created by Gwyn Bong Xiao Min
 * Copyright (c) 2021. All rights reserved.
 * Last modified 16/7/21 1:08 PM
 */
import 'package:flutter/material.dart';
import 'package:nearbyou/utilities/ui/palette.dart';

class SearchFieldContainer extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final String labelText;
  final String hintText;
  final IconData prefixIcon;
  final IconData suffixIcon;
  final GestureTapCallback suffixIconOnPressed;
  final GestureTapCallback onTap;
  final TextStyle labelStyle;
  final TextStyle hintStyle;

  const SearchFieldContainer(
      {Key key,
      this.controller,
      this.focusNode,
      this.labelText,
      this.hintText,
      this.prefixIcon,
      this.suffixIcon,
      this.suffixIconOnPressed,
      this.onTap,
      this.labelStyle,
      this.hintStyle})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Container(
      width: size.width * 0.8,
      child: TextField(
        keyboardType: TextInputType.text,
        controller: controller,
        focusNode: focusNode,
        cursorColor: Colors.black,
        autofocus: false,
        decoration: InputDecoration(
          labelText: labelText,
          labelStyle: TextStyle(color: textDarkColor),
          hintText: hintText,
          hintStyle: TextStyle(color: Colors.grey),
          prefixIcon: Icon(
            prefixIcon,
            color: textLightColor,
          ),
          suffixIcon: IconButton(
            icon: Icon(
              suffixIcon,
              color: primaryColor,
            ),
            onPressed: suffixIconOnPressed,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(30.0),
            ),
            borderSide: BorderSide(
              color: Colors.grey,
              width: 2,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(30.0),
            ),
            borderSide: BorderSide(
              color: textLightColor,
              width: 2,
            ),
          ),
          contentPadding: EdgeInsets.symmetric(horizontal: 15),
        ),
        onTap: onTap,
      ),
    );
  }
}
