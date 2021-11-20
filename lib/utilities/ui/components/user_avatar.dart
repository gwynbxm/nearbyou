/*
 * Created by Gwyn Bong Xiao Min
 * Copyright (c) 2021. All rights reserved.
 * Last modified 3/10/21 9:38 PM
 */

import 'package:flutter/material.dart';

class UserAvatar extends StatelessWidget {
  final String profileImg;

  const UserAvatar({Key key, this.profileImg}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: CircleAvatar(
        backgroundImage: NetworkImage(profileImg),
      ),
      width: 40,
      height: 40,
    );
  }
}
