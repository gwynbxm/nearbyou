/*
 * Created by Gwyn Bong Xiao Min
 * Copyright (c) 2021. All rights reserved.
 * Last modified 16/7/21 12:44 PM
 */

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
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
import 'package:nearbyou/views/preferences/preferences_view.dart';
import 'package:nearbyou/views/signup/signup_view.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SignInView extends StatelessWidget {
  const SignInView({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: SignInAuth(),
      ),
    );
  }
}

class SignInAuth extends StatefulWidget {
  const SignInAuth({Key key}) : super(key: key);

  @override
  _SignInAuthState createState() => _SignInAuthState();
}

class _SignInAuthState extends State<SignInAuth> {
  final _formKey = GlobalKey<FormState>();
  final _googleUsernameKey = GlobalKey<FormState>();
  final _resetPwdEmailKey = GlobalKey<FormState>();

  final _focusEmail = FocusNode();
  final _focusPwd = FocusNode();

  TextEditingController _emailCon = TextEditingController();
  TextEditingController _pwdCon = TextEditingController();
  TextEditingController _usernameCon = TextEditingController();
  TextEditingController _pwdResetEmailCon = TextEditingController();

  bool _isHidden = true;
  bool _isEmailVerified = false;

  void _toggle() {
    setState(() {
      _isHidden = !_isHidden;
    });
  }

  void validateLoginEmail() async {
    _focusPwd.unfocus();
    _focusEmail.unfocus();

    FormState form = _formKey.currentState;

    if (form.validate()) {
      User result = await Auth().signIn(_emailCon.text, _pwdCon.text);
      if (result != null && result.emailVerified) {
        final SharedPreferences sharedPreferences =
            await SharedPreferences.getInstance();
        sharedPreferences.setBool('login', false);
        sharedPreferences.setString('email', result.email);

        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen()),
        );
      } else {
        _showVerifyEmailDialog();
      }
    } else {
      print('Form is invalid');
    }
  }

  void _showVerifyEmailDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return CustomDialogBox(
          icon: Icons.lock,
          bgAvatarColor: iconColor,
          iconColor: Colors.white,
          dialogTitle: 'Verify your account',
          dialogSubtitle:
              'Please enter correct email address and password. Also, verify account through the link sent to your email if you have not done so!',
          leftButtonText: 'Cancel',
          rightButtonText: 'Resend',
          leftButtonTextColor: Colors.black,
          rightButtonTextColor: primaryColor,
          onPressedLeftButton: () => Navigator.of(context).pop(),
          onPressedRightButton: () {
            Navigator.of(context).pop();
            Auth().sendVerificationEmail();
          },
        );
      },
    );
  }

  void _showPasswordResetDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return CustomDialogBox(
          icon: Icons.lock,
          bgAvatarColor: iconColor,
          iconColor: Colors.white,
          dialogTitle: 'Reset Password?',
          dialogSubtitle: 'Enter your email address to reset password.',
          widget: Form(
            key: _resetPwdEmailKey,
            child: TextFormField(
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(hintText: 'Email address'),
                controller: _pwdResetEmailCon,
                validator: (value) => Validator.validateEmail(value)),
          ),
          leftButtonText: 'Cancel',
          rightButtonText: 'Send',
          leftButtonTextColor: Colors.black,
          rightButtonTextColor: primaryColor,
          onPressedLeftButton: () => Navigator.of(context).pop(),
          onPressedRightButton: () {
            Navigator.of(context).pop();
            Auth().sendPasswordResetEmail(_pwdResetEmailCon.text);
          },
        );
      },
    );
  }

  void validateGoogleSignIn() async {
    User result = await Auth().signInWithGoogle(context);
    if (result != null) {
      //prompt pop up dialog to enter username
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text("Enter username"),
              content: Form(
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
              actions: [
                TextButton(
                  child: Text("SUBMIT"),
                  onPressed: () async {
                    UserData userProfile = UserData(
                        username: _usernameCon.text,
                        profilePhoto: result.photoURL.toString());
                    await DatabaseServices.addUser(result.uid, userProfile);

                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => HomeScreen()),
                    );
                  },
                ),
                TextButton(
                  child: Text("SKIP"),
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => HomeScreen()),
                  ),
                ),
              ],
            );
          });
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
                          hintText: "Email Address",
                          labelText: "Email Address",
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
                        GestureDetector(
                          onTap: () => _showPasswordResetDialog(),
                          child: Text(
                            "Forgot Password?",
                            style: TextStyle(
                                color: primaryColor,
                                fontWeight: FontWeight.bold,
                                fontStyle: FontStyle.italic),
                          ),
                        ),
                        SizedBox(
                          height: 15.0,
                        ),
                        RoundedButton(
                          onPressed: () => validateLoginEmail(),
                          color: primaryColor,
                          text: "SIGN IN",
                        ),
                        SizedBox(height: 5.0),
                        SocialRoundedButton(
                          // onPressed: () => Auth().signInWithGoogle(),
                          color: Colors.white70,
                          onPressed: () => validateGoogleSignIn(),
                          icon: AssetImage('assets/icons/google-logo.png'),
                          text: "SIGN IN WITH GOOGLE",
                          textColor: Colors.black,
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
                                      builder: (context) => new SignUpView())),
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
    _emailCon.dispose();
    _pwdCon.dispose();
    super.dispose();
  }
}
