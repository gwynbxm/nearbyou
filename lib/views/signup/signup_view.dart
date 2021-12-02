/*
 * Created by Gwyn Bong Xiao Min
 * Copyright (c) 2021. All rights reserved.
 * Last modified 16/7/21 12:45 PM
 */

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:nearbyou/models/user_profile_model.dart';
import 'package:nearbyou/utilities/helper/validator.dart';
import 'package:nearbyou/utilities/services/firebase_services/authentication.dart';
import 'package:nearbyou/utilities/services/firebase_services/firestore.dart';
import 'package:nearbyou/utilities/ui/components/custom_dialog_box.dart';
import 'package:nearbyou/utilities/ui/components/rounded_button.dart';
import 'package:nearbyou/utilities/ui/components/rounded_input_field.dart';
import 'package:nearbyou/utilities/ui/components/rounded_pwd_field.dart';
import 'package:nearbyou/utilities/ui/components/social_rounded_button.dart';
import 'package:nearbyou/utilities/ui/palette.dart';
import 'package:nearbyou/views/home/home_view.dart';
import 'package:nearbyou/views/signin/signin_view.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SignUpView extends StatelessWidget {
  const SignUpView({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: SignUp(),
      ),
    );
  }
}

class SignUp extends StatefulWidget {
  const SignUp({Key key}) : super(key: key);

  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final _formKey = GlobalKey<FormState>();
  final _googleUsernameKey = GlobalKey<FormState>();

  final _focusUsername = FocusNode();
  final _focusEmail = FocusNode();
  final _focusPwd = FocusNode();
  final _focusCfmPwd = FocusNode();

  TextEditingController _usernameCon = TextEditingController();
  TextEditingController _emailCon = TextEditingController();
  TextEditingController _pwdCon = TextEditingController();
  TextEditingController _cfmPwdCon = TextEditingController();

  bool _isHiddenPwd = true;
  bool _isHiddenCfmPwd = true;
  bool isLoading = false;

  void _togglePwd() {
    setState(() {
      _isHiddenPwd = !_isHiddenPwd;
    });
  }

  void _toggleCfmPwd() {
    setState(() {
      _isHiddenCfmPwd = !_isHiddenCfmPwd;
    });
  }

  validateRegister() async {
    FormState form = _formKey.currentState;
    if (form.validate()) {
      User user = await Auth()
          .register(_emailCon.text, _pwdCon.text, _usernameCon.text);
      if (user != null) {
        UserData userProfile =
            UserData(username: _usernameCon.text, emailAddress: _emailCon.text);
        await DatabaseServices.addUser(user.uid, userProfile);

        return showDialog(
            context: context,
            builder: (BuildContext context) {
              return CustomDialogBox(
                icon: Icons.auto_awesome,
                bgAvatarColor: iconColor,
                iconColor: Colors.white,
                dialogTitle: 'Registration Successful!',
                dialogSubtitle:
                    'Thank you for signing up with Nearbyou! You may proceed to verify your email before signing in!',
                rightButtonText: 'Dismiss',
                rightButtonTextColor: primaryColor,
                onPressedRightButton: () {
                  Navigator.of(context).pop();
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => SignInView()));
                },
              );
            });
      } else {
        return showDialog(
            context: context,
            builder: (BuildContext context) {
              return CustomDialogBox(
                icon: Icons.warning,
                bgAvatarColor: Colors.redAccent,
                iconColor: Colors.white,
                dialogTitle: 'Existing Account found!',
                dialogSubtitle:
                    'Email has already been taken! Please try another email or sign in if you have registered!',
                leftButtonText: 'Cancel',
                rightButtonText: 'Sign In',
                rightButtonTextColor: primaryColor,
                leftButtonTextColor: Colors.black,
                onPressedLeftButton: () => Navigator.of(context).pop(),
                onPressedRightButton: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                },
              );
            });
      }
    } else {
      print('Form is invalid');
    }
  }

  void validateGoogleSignIn() async {
    User result = await Auth().signInWithGoogle(context);
    if (result != null) {
      //prompt pop up dialog to enter username
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return CustomDialogBox(
            icon: Icons.auto_awesome,
            bgAvatarColor: iconColor,
            iconColor: Colors.white,
            dialogTitle: 'Create a username',
            dialogSubtitle:
                'To be a part of the Nearbyou community, create a username of your own!',
            widget: Form(
              key: _googleUsernameKey,
              child: TextFormField(
                controller: _usernameCon,
                decoration: InputDecoration(
                    icon: Icon(
                      Icons.account_box_rounded,
                      color: primaryColor,
                    ),
                    hintText: 'Username',
                    border: InputBorder.none,
                    errorStyle: TextStyle(color: Colors.red)),
                // TODO: Implement check for username existing in firestore
              ),
            ),
            leftButtonText: 'Cancel',
            rightButtonText: 'Submit',
            leftButtonTextColor: Colors.black,
            rightButtonTextColor: primaryColor,
            onPressedLeftButton: () => Navigator.of(context).pop(),
            onPressedRightButton: () async {
              UserData userProfile = UserData(
                  username: _usernameCon.text,
                  profilePhoto: result.photoURL.toString(),
                  emailAddress: result.email.toString());
              await DatabaseServices.addUser(result.uid, userProfile);

              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => HomeScreen()),
              );
            },
          );
        },
      );
      // showDialog(
      //     context: context,
      //     builder: (context) {
      //       return AlertDialog(
      //         title: Text("Enter username"),
      //         content: ,
      //         actions: [
      //           TextButton(
      //             child: Text("SUBMIT"),
      //             onPressed: () async {
      //               UserData userProfile = UserData(
      //                   username: _usernameCon.text,
      //                   profilePhoto: result.photoURL.toString());
      //               await DatabaseServices.addUser(result.uid, userProfile);
      //
      //               Navigator.push(
      //                 context,
      //                 MaterialPageRoute(builder: (context) => HomeScreen()),
      //               );
      //             },
      //           ),
      //           TextButton(
      //             child: Text("SKIP"),
      //             onPressed: () => Navigator.push(
      //               context,
      //               MaterialPageRoute(builder: (context) => HomeScreen()),
      //             ),
      //           ),
      //         ],
      //       );
      //     });
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
                          obscureText: _isHiddenPwd,
                          onChanged: (value) {},
                          focusNode: _focusPwd,
                          hintText: "Password",
                          labelText: "Password",
                          suffixIcon: IconButton(
                            icon: Icon(_isHiddenPwd
                                ? Icons.visibility
                                : Icons.visibility_off),
                            color: primaryColor,
                            onPressed: () => _togglePwd(),
                          ),
                          validator: (value) =>
                              Validator.validatePassword(value),
                        ),
                        RoundedPasswordField(
                          controller: _cfmPwdCon,
                          obscureText: _isHiddenCfmPwd,
                          onChanged: (value) {},
                          focusNode: _focusCfmPwd,
                          hintText: "Confirm Password",
                          labelText: "Confirm Password",
                          suffixIcon: IconButton(
                            icon: Icon(_isHiddenCfmPwd
                                ? Icons.visibility
                                : Icons.visibility_off),
                            color: primaryColor,
                            onPressed: () => _toggleCfmPwd(),
                          ),
                          validator: (value) => Validator.validateCfmPassword(
                              _pwdCon.text, _cfmPwdCon.text),
                        ),
                        RoundedButton(
                          onPressed: () => validateRegister(),
                          color: primaryColor,
                          text: "SIGN UP",
                        ),
                        SizedBox(height: 5.0),
                        SocialRoundedButton(
                          // onPressed: () => Auth().signInWithGoogle(),
                          color: Colors.white70,
                          onPressed: () => validateGoogleSignIn(),
                          icon: AssetImage('assets/icons/google-logo.png'),
                          text: "SIGN UP WITH GOOGLE",
                          textColor: Colors.black,
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
                                      builder: (context) => new SignInView())),
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
    super.dispose();
    _usernameCon.dispose();
    _emailCon.dispose();
    _pwdCon.dispose();
    _cfmPwdCon.dispose();
  }
}
