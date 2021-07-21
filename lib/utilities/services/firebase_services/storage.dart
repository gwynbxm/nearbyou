/*
 * Created by Gwyn Bong Xiao Min
 * Copyright (c) 2021. All rights reserved.
 * Last modified 17/7/21 9:09 PM
 */
import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';

final FirebaseStorage storage = FirebaseStorage.instance;
final Reference storageRef = storage.ref();

class StorageService {
  static Future<String> uploadProfilePhoto(
      String url, File img, String userUid) async {
    String photoUid = Uuid().v4();

    UploadTask uploadTask = storageRef
        .child('images/users/$userUid/userProfile_$photoUid.jpg')
        .putFile(img);

    TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() => null);

    String downloadUrl = await taskSnapshot.ref.getDownloadURL();
    return downloadUrl;
  }
}
