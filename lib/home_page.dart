import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class ImageScreen extends StatelessWidget {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<void> uploadImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile =
        await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      uploadToFirebaseStorage(pickedFile.path);
    } else {}
  }

  Future<void> uploadToFirebaseStorage(String imagePath) async {
    final CollectionReference storageReference =
        FirebaseFirestore.instance.collection('images');
    // UploadTask uploadTask = storageReference.putFile(File(imagePath));

    print(imagePath);

    // await uploadTask.whenComplete(() => print('Imagen subida exitosamente'));
  }

  Future<void> getImage() async {
    // TODO: Implement image retrieval logic using Firebase Storage
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Firebase Connection'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: uploadImage,
              child: const Text('Upload Image'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: getImage,
              child: const Text('Get Image'),
            ),
          ],
        ),
      ),
    );
  }
}
