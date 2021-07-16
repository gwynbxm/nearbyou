/*
 * Created by Gwyn Bong Xiao Min
 * Copyright (c) 2021. All rights reserved.
 * Last modified 5/7/21 11:46 AM
 */
import 'package:firebase_auth/firebase_auth.dart';

abstract class BaseAuth {
  Future<String> getCurrentUser();
  Future<User> signIn(String email, String password);
  Future<User> register(String email, String password);
  Future<void> signOut();
}

class Auth implements BaseAuth {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  @override
  Future<String> getCurrentUser() async {
    // TODO: implement currentUser
    final User user = _firebaseAuth.currentUser;
    final uid = user.uid.toString();

    return uid;
  }

  @override
  Future<User> register(String email, String password) async {
    // TODO: implement register
    try {
      UserCredential userCredential = await _firebaseAuth
          .createUserWithEmailAndPassword(email: email, password: password);

      final User registeredUser = userCredential.user;
      return registeredUser;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        print('The password provided is too weak');
      } else if (e.code == 'email-already-in-use') {
        print('The account already exists for that email');
      }
      return null;
    }
  }

  @override
  Future<User> signIn(String email, String password) async {
    // TODO: implement signIn
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

  @override
  Future<void> signOut() {
    // TODO: implement signOut
    return _firebaseAuth.signOut();
  }
}
