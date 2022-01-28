import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';

final db = FirebaseFirestore.instance;

class ImageHelper {
  final ImagePicker picker = ImagePicker();

  Future<void> uploadImage(File image, User user) async {
    try {
      var path = '${user.uid}${extension(image.path)}';
      print('path ' + path);
      var storageRef =
          FirebaseStorage.instance.ref().child('images/profile/$path');
      await storageRef.putFile(image);
      print('File Uploaded');

      var returnURL = '';
      await storageRef.getDownloadURL().then((fileURL) {
        returnURL = fileURL;
        print('returnURL $returnURL');
      });
      await db
          .collection('users')
          .doc(user.uid)
          .update({'imageURL': returnURL});
      print('URL stored');
    } on FirebaseException catch (e) {
      //printErrorMessage(e.message!); //TODO handle error
      print(e.stackTrace);
    }
  }

  Future<String> uploadFile(File _image) async {
    var storageReference =
        FirebaseStorage.instance.ref().child('images/${basename(_image.path)}');
    await storageReference.putFile(_image);
    print('File Uploaded');
    var returnURL = '';
    await storageReference.getDownloadURL().then((fileURL) {
      returnURL = fileURL;
    });
    return returnURL;
  }

  ImageProvider showImage(String url, String asset) {
    ImageProvider imageProvider = AssetImage(asset);
    if (url != '') {
      imageProvider = CachedNetworkImageProvider(url);
    }
    return imageProvider;
  }
}
