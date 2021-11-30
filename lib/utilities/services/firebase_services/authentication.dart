/*
 * Created by Gwyn Bong Xiao Min
 * Copyright (c) 2021. All rights reserved.
 * Last modified 5/7/21 11:46 AM
 */
import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:nearbyou/views/home/home_view.dart';

abstract class BaseAuth {
  Future<String> getCurrentUser();
  Future<User> signIn(String email, String password);
  Future<User> register(String email, String password, String username);
  Future<void> sendPasswordResetEmail(String email);
  Future<void> sendVerificationEmail();
  Future<void> signOut();
}

class Auth implements BaseAuth {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn googleSignIn = GoogleSignIn();

  @override
  Future<String> getCurrentUser() async {
    // TODO: implement currentUser
    final User user = _firebaseAuth.currentUser;
    final uid = user.uid.toString();

    return uid;
  }

  @override
  Future<User> register(String email, String password, String username) async {
    //create a user account with firestore
    try {
      UserCredential userCredential = await _firebaseAuth
          .createUserWithEmailAndPassword(email: email, password: password);

      final User registeredUser = userCredential.user;
      await registeredUser.sendEmailVerification();
      return registeredUser;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        print('The password provided is too weak');
      } else if (e.code == 'email-already-in-use') {
        print('The account already exists for that email');
      }
      return null;
    } catch (e) {
      print('An error occurred while trying to send email verification');
      return null;
    }
  }

  @override
  Future<User> signIn(String email, String password) async {
    // sign in to user account
    try {
      UserCredential userCredential = await _firebaseAuth
          .signInWithEmailAndPassword(email: email, password: password);

      final User signInUser = userCredential.user;
      return signInUser;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        print('No user found for that email.');
      } else if (e.code == 'wrong-password') {
        print('Wrong password provided.');
      } else if (e.code == 'email-already-in-use') {
        print('The account already exists for that email');
      }
      return null;
    }
  }

  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  Future<void> sendVerificationEmail() async {
    try {
      User user = _firebaseAuth.currentUser;
      user.sendEmailVerification();
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  @override
  Future<void> signOut() async {
    // sign out both normal firebase auth and google sign in
    try {
      await _firebaseAuth.signOut();
      await googleSignIn.signOut();
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  // sign in using google
  Future<User> signInWithGoogle(BuildContext context) async {
    final GoogleSignInAccount googleSignInAccount = await googleSignIn.signIn();

    if (googleSignInAccount != null) {
      final GoogleSignInAuthentication authentication =
          await googleSignInAccount.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: authentication.accessToken,
        idToken: authentication.idToken,
      );

      try {
        final UserCredential userCredential =
            await _firebaseAuth.signInWithCredential(credential);

        final User googleUser = userCredential.user;

        //if user is new user, pass user cred to login screen to enter username
        if (userCredential.additionalUserInfo.isNewUser) {
          return googleUser;
        } else {
          //else is existing user
          return Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => HomeScreen()),
          );
        }
      } on FirebaseAuthException catch (e) {
        if (e.code == 'account-exists-with-different-credential') {
          print('The account already exists with a different credential.');
        } else if (e.code == 'invalid-credential') {
          print('Error occurred while accessing credentials. Try again.');
        }
        return null;
      } catch (e) {
        print('Error occurred using Google Sign-In. Try again.');
        return null;
      }
    }
    return null;
  }
}
