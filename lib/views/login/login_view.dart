/*
 * Created by Gwyn Bong Xiao Min
 * Copyright (c) 2021. All rights reserved.
 * Last modified 22/6/21 6:19 PM
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
import 'package:nearbyou/views/register/register_view.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginView extends StatelessWidget {
  const LoginView({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: LoginAuth(),
      ),
    );
  }
}

class LoginAuth extends StatefulWidget {
  const LoginAuth({Key key}) : super(key: key);

  @override
  _LoginAuthState createState() => _LoginAuthState();
}

class _LoginAuthState extends State<LoginAuth> {
  final _formKey = GlobalKey<FormState>();

  final _focusEmail = FocusNode();
  final _focusPwd = FocusNode();

  TextEditingController _emailCon = TextEditingController();
  TextEditingController _pwdCon = TextEditingController();

  bool _isHidden = true;

  void _toggle() {
    setState(() {
      _isHidden = !_isHidden;
    });
  }

  void validateLogin() async {
    _focusPwd.unfocus();
    _focusEmail.unfocus();

    FormState form = _formKey.currentState;

    if (form.validate()) {
      User result = await Auth().signIn(_emailCon.text, _pwdCon.text);
      if (result != null) {
        final SharedPreferences sharedPreferences =
            await SharedPreferences.getInstance();
        sharedPreferences.setBool('login', false);
        sharedPreferences.setString('email', result.email);

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
        _focusEmail.unfocus();
        _focusPwd.unfocus();
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
                SizedBox(height: 15.0),
                Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        RoundedInputField(
                          controller: _emailCon,
                          hintText: 'Email Address',
                          focusNode: _focusEmail,
                          onChanged: (value) {},
                          validator: (value) => Validator.validateEmail(value),
                        ),
                        RoundedPasswordField(
                          controller: _pwdCon,
                          obscureText: _isHidden,
                          onChanged: (value) {},
                          focusNode: _focusPwd,
                          hintText: "Password",
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
                        SizedBox(
                          height: 15.0,
                        ),

                        RoundedButton(
                          onPressed: () => validateLogin(),
                          text: "LOGIN",
                        ),
                        SizedBox(height: 15.0),
                        // CheckSignInOrSignUp(
                        //   onTap: () => Navigator.push(
                        //       context,
                        //       new MaterialPageRoute(
                        //           builder: (context) => new RegisterView())),
                        // ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Don't have an account? ",
                              style: TextStyle(color: Colors.black),
                            ),
                            GestureDetector(
                              onTap: () => Navigator.push(
                                  context,
                                  new MaterialPageRoute(
                                      builder: (context) =>
                                          new RegisterView())),
                              child: Text(
                                "Sign up",
                                style: TextStyle(
                                    color: primaryColor,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        )
                      ],
                    )),
              ],
            ),
          ),
        )),
      ),
    );
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _emailCon.dispose();
    _pwdCon.dispose();
    super.dispose();
  }
}
