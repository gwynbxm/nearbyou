/*
 * Created by Gwyn Bong Xiao Min
 * Copyright (c) 2021. All rights reserved.
 * Last modified 5/7/21 11:46 AM
 */

class Validator {
  static String validateEmail(String email) {
    Pattern pattern = r'^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+';
    RegExp regex = new RegExp(pattern);
    if (email.isEmpty)
      return 'Email cannot be blank';
    else if (!regex.hasMatch(email))
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
      return 'Password cannot be blank';
    else if (cfmPwd != pwd)
      return 'Password is not matching';
    else
      return null;
  }
}
