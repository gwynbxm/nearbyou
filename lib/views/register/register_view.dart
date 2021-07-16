/*
 * Created by Gwyn Bong Xiao Min
 * Copyright (c) 2021. All rights reserved.
 * Last modified 16/7/21 12:45 PM
 */

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:nearbyou/utilities/helper/validator.dart';
import 'package:nearbyou/utilities/services/firebase_services/authentication.dart';
import 'package:nearbyou/utilities/ui/components/rounded_button.dart';
import 'package:nearbyou/utilities/ui/components/rounded_input_field.dart';
import 'package:nearbyou/utilities/ui/components/rounded_pwd_field.dart';
import 'package:nearbyou/utilities/ui/palette.dart';
import 'package:nearbyou/views/home/home_view.dart';
import 'package:nearbyou/views/login/login_view.dart';

class RegisterView extends StatelessWidget {
  const RegisterView({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: RegisterAcc(),
      ),
    );
  }
}

class RegisterAcc extends StatefulWidget {
  const RegisterAcc({Key key}) : super(key: key);

  @override
  _RegisterAccState createState() => _RegisterAccState();
}

class _RegisterAccState extends State<RegisterAcc> {
  final _formKey = GlobalKey<FormState>();

  final _focusUsername = FocusNode();
  final _focusEmail = FocusNode();
  final _focusPwd = FocusNode();
  final _focusCfmPwd = FocusNode();

  TextEditingController _usernameCon = TextEditingController();
  TextEditingController _emailCon = TextEditingController();
  TextEditingController _pwdCon = TextEditingController();
  TextEditingController _cfmPwdCon = TextEditingController();

  bool _isHidden = true;

  void _toggle() {
    setState(() {
      _isHidden = !_isHidden;
    });
  }

  void validateRegister() async {
    FormState form = _formKey.currentState;
    if (form.validate()) {
      User user = await Auth().register(_emailCon.text, _pwdCon.text);
      if (user != null) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen()),
        );
      }
    } else {
      print('Form is invalid');
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return GestureDetector(
      onTap: () {
        _focusUsername.unfocus();
        _focusEmail.unfocus();
        _focusPwd.unfocus();
        _focusCfmPwd.unfocus();
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Container(
            alignment: Alignment.center,
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    child: Center(
                      child: Image.asset("assets/images/app-logo.png",
                          width: 250, height: 250),
                    ),
                  ),
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        RoundedInputField(
                          controller: _usernameCon,
                          focusNode: _focusUsername,
                          hintText: "Username",
                          labelText: "Username",
                          onChanged: (value) {},
                          validator: (value) =>
                              value.isEmpty ? 'Username cannot be blank' : null,
                        ),
                        RoundedInputField(
                          controller: _emailCon,
                          focusNode: _focusEmail,
                          hintText: "Email Address",
                          labelText: "Email Address",
                          onChanged: (value) {},
                          validator: (value) =>
                              value.isEmpty ? 'Email cannot be blank' : null,
                        ),
                        RoundedPasswordField(
                          controller: _pwdCon,
                          obscureText: _isHidden,
                          onChanged: (value) {},
                          focusNode: _focusPwd,
                          hintText: "Password",
                          labelText: "Password",
                          suffixIcon: IconButton(
                            icon: Icon(_isHidden
                                ? Icons.visibility
                                : Icons.visibility_off),
                            color: primaryColor,
                            onPressed: () => _toggle(),
                          ),
                          validator: (value) =>
                              Validator.validatePassword(value),
                        ),
                        RoundedPasswordField(
                          controller: _cfmPwdCon,
                          obscureText: _isHidden,
                          onChanged: (value) {},
                          focusNode: _focusCfmPwd,
                          hintText: "Confirm Password",
                          labelText: "Confirm Password",
                          suffixIcon: IconButton(
                            icon: Icon(_isHidden
                                ? Icons.visibility
                                : Icons.visibility_off),
                            color: primaryColor,
                            onPressed: () => _toggle(),
                          ),
                          validator: (value) => Validator.validateCfmPassword(
                              _pwdCon.text, _cfmPwdCon.text),
                        ),
                        RoundedButton(
                          onPressed: () => validateRegister(),
                          text: "SIGN UP",
                        ),
                        SizedBox(height: 15.0),
                        // CheckSignInOrSignUp(
                        //   onTap: () => Navigator.push(
                        //       context,
                        //       new MaterialPageRoute(
                        //           builder: (context) => new LoginView())),
                        // )

                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Already have an Account? ",
                              style: TextStyle(color: Colors.black),
                            ),
                            GestureDetector(
                              onTap: () => Navigator.push(
                                  context,
                                  new MaterialPageRoute(
                                      builder: (context) => new LoginView())),
                              child: Text(
                                "Sign In",
                                style: TextStyle(
                                    color: primaryColor,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _usernameCon.dispose();
    _emailCon.dispose();
    _pwdCon.dispose();
    _cfmPwdCon.dispose();
  }
}
