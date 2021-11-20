/*
 * Created by Gwyn Bong Xiao Min
 * Copyright (c) 2021. All rights reserved.
 * Last modified 17/7/21 9:09 PM
 */
import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:nearbyou/utilities/constants/constants.dart';
import 'package:uuid/uuid.dart';
import 'package:path/path.dart' as Path;

class StorageService {
  static Future<String> uploadProfilePhoto(
      String url, File img, String userUid) async {
    UploadTask uploadTask = storageRef
        .child('images/users/$userUid/userProfile_${Path.basename}.jpg')
        .putFile(img);

    TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() => null);

    String downloadUrl = await taskSnapshot.ref.getDownloadURL();
    return downloadUrl;
  }

  // static Future<String> uploadPostImages(File img, String userUid) async {
  //   UploadTask uploadTask = storageRef
  //       .child('images/users/$userUid/userPost_${Path.basename}.jpg')
  //       .putFile(img);
  //
  //   TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() => null);
  //
  //   String downloadUrl = await taskSnapshot.ref.getDownloadURL();
  //   return downloadUrl;
  // }

  // static Future<List<String>> uploadPostImages(
  //     List<File> images, String userUid) async {
  //   List<String> urlList = [];
  //
  //   await images.forEach((image) async {
  //     UploadTask uploadTask = storageRef
  //         .child('images/users/$userUid/userPost_${Path.basename}.jpg')
  //         .putFile(image);
  //
  //     TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() => null);
  //
  //     String downloadUrl = await taskSnapshot.ref.getDownloadURL();
  //     urlList.add(downloadUrl);
  //   });
  //
  //   return urlList;
  // }
}
