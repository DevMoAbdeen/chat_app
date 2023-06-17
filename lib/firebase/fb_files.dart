import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class FbFiles {
  static Future<String> uploadImage(BuildContext context, XFile? file, String imageName) async {
    if (file != null) {
      Reference referenceRoot = FirebaseStorage.instance.ref();
      Reference referenceDirImage = referenceRoot.child("Images");
      Reference referenceImageUpload = referenceDirImage.child(imageName);

      // Handle error
      try {
        // store the file
        await referenceImageUpload.putFile(File(file.path));
        return await referenceImageUpload.getDownloadURL();
      } catch (error) {
        print(error.toString());
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${error.toString()}'),
          ),
        );
        return "Error: ${error.toString()}";
      }
    } else {
      return "File is not valid";
    }
  }

  ///////////////////

  static Future<String> uploadVideo(
      BuildContext context, XFile? file, String videoName) async {
    if (file != null) {
      Reference referenceRoot = FirebaseStorage.instance.ref();
      Reference referenceDirVideo = referenceRoot.child("Videos");
      Reference referenceVideoUpload = referenceDirVideo.child(videoName);

      // Handle error
      try {
        // store the file
        await referenceVideoUpload.putFile(File(file.path));
        return await referenceVideoUpload.getDownloadURL();
      } catch (error) {
        print(error.toString());
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${error.toString()}'),
          ),
        );
        return "Error: ${error.toString()}";
      }
    } else {
      return "File is not valid";
    }
  }

///////////////////
}
