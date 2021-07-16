/*
 * Created by Gwyn Bong Xiao Min
 * Copyright (c) 2021. All rights reserved.
 * Last modified 16/7/21 12:48 PM
 */
import 'package:flutter/material.dart';
import 'package:nearbyou/utilities/ui/components/text_field_container.dart';
import 'package:nearbyou/utilities/ui/palette.dart';

class RoundedInputField extends StatelessWidget {
  final String hintText;
  final String labelText;
  final IconData icon;
  final ValueChanged<String> onChanged;
  final FocusNode focusNode;
  final TextEditingController controller;
  final FormFieldValidator<String> validator;

  const RoundedInputField({
    Key key,
    this.hintText,
    this.icon = Icons.alternate_email,
    this.onChanged,
    this.focusNode,
    this.controller,
    this.validator,
    this.labelText,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFieldContainer(
      child: TextFormField(
        keyboardType: TextInputType.emailAddress,
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
            labelText: labelText,
            border: InputBorder.none,
            errorStyle: TextStyle(color: Colors.red)),
        validator: validator,
      ),
    );
  }
}
