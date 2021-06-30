/*
 * Created by Gwyn Bong Xiao Min
 * Copyright (c) 2021. All rights reserved.
 * Last modified 22/6/21 6:19 PM
 */

class Validator {
  static String validateEmail(String value) {
    Pattern pattern = r'^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+';
    RegExp regex = new RegExp(pattern);
    if (value.isEmpty)
      return 'Email cannot be blank';
    else if (!regex.hasMatch(value))
      return 'Please enter a valid email address.';
    else
      return null;
  }

  static String validatePassword(String value) {
    Pattern pattern = r'^.{6,}$';
    RegExp regex = new RegExp(pattern);
    if (value.isEmpty)
      return 'Password cannot be blank';
    else if (!regex.hasMatch(value))
      return 'Password must be at least 6 characters.';
    else
      return null;
  }

  static String validateCfmPassword(String pwd, String cfmPwd) {
    if (cfmPwd.isEmpty)
      return 'Please enter to confirm password';
    else if (cfmPwd != pwd)
      return 'Password is not matching';
    else
      return null;
  }
}
