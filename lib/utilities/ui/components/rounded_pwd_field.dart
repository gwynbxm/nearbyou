/*
 * Created by Gwyn Bong Xiao Min
 * Copyright (c) 2021. All rights reserved.
 * Last modified 21/6/21 9:32 PM
 */
import 'package:flutter/material.dart';
import 'package:nearbyou/utilities/ui/components/text_field_container.dart';

import '../palette.dart';

class RoundedPasswordField extends StatelessWidget {
  final ValueChanged<String> onChanged;
  final FocusNode focusNode;
  final IconButton suffixIcon;
  final bool obscureText;
  final TextEditingController controller;
  final FormFieldValidator<String> validator;
  final String hintText;

  const RoundedPasswordField({
    Key key,
    this.onChanged,
    this.focusNode,
    this.suffixIcon,
    this.obscureText,
    this.controller,
    this.validator,
    this.hintText,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFieldContainer(
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        onChanged: onChanged,
        focusNode: focusNode,
        autofocus: false,
        cursorColor: Colors.black,
        decoration: InputDecoration(
          hintText: hintText,
          icon: Icon(
            Icons.lock_outline,
            color: primaryColor,
          ),
          suffixIcon: suffixIcon,
          // Icon(
          //   Icons.visibility,
          //   color: primaryColor,
          // ),
          border: InputBorder.none,
        ),
        validator: validator,
      ),
    );
  }
}
