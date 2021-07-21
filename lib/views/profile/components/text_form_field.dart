/*
 * Created by Gwyn Bong Xiao Min
 * Copyright (c) 2021. All rights reserved.
 * Last modified 21/7/21 7:08 PM
 */

import 'package:flutter/material.dart';
import 'package:nearbyou/utilities/ui/palette.dart';

class ProfileInputField extends StatelessWidget {
  final String hintText;
  final String labelText;
  final IconData icon;
  final ValueChanged<String> onChanged;
  final FocusNode focusNode;
  final TextEditingController controller;
  final FormFieldValidator<String> validator;

  const ProfileInputField(
      {Key key,
      this.hintText,
      this.labelText,
      this.icon,
      this.onChanged,
      this.focusNode,
      this.controller,
      this.validator})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Container(
      width: size.width * 0.8,
      child: TextFormField(
        controller: controller,
        onChanged: onChanged,
        focusNode: focusNode,
        cursorColor: Colors.black,
        autofocus: false,
        decoration: InputDecoration(
            icon: Icon(
              icon,
              color: primaryColor,
            ),
            hintText: hintText,
            hintStyle: TextStyle(color: Colors.grey),
            labelText: labelText,
            labelStyle: TextStyle(color: textDarkColor),
            border: InputBorder.none,
            errorStyle: TextStyle(color: Colors.red)),
        validator: validator,
      ),
    );
  }
}
