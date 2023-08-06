// ignore_for_file: prefer_const_constructors

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  final TextEditingController _nameController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  XFile? _imageFile;
  late String _uidCurrentUser;
  bool _isLoading = false;
  String _urlImage = "";

  Future _selectImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image == null) return;
    setState(() {
      _imageFile = image;

      if (_imageFile == null) return;
      _isLoading = true;
      _uploadImage();
    });
  }

  Future _uploadImage() async {
    Reference ref = FirebaseStorage.instance
        .ref()
        .child('profile')
        .child('$_uidCurrentUser.jpg');

    // upload task to firebase storage
    UploadTask uploadTask = ref.putFile(File(_imageFile!.path));

    // control upload task progress
    uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
      if (snapshot.state == TaskState.running) {
        setState(() {
          _isLoading = true;
        });
      } else if (snapshot.state == TaskState.success) {
        setState(() {
          _isLoading = false;
        });
      }

      // get download url
      uploadTask.then((TaskSnapshot snapshot) {
        _recoveryUrlImage(snapshot);
      });
    });
  }

  _recoveryUrlImage(TaskSnapshot snapshot) async {
    String url = await snapshot.ref.getDownloadURL();
    _updateUrlImageFirestore(url);
    setState(() {
      _urlImage = url;
    });
  }

  _updateUrlImageFirestore(String url) async {
    await FirebaseFirestore.instance
        .collection("users")
        .doc(_uidCurrentUser)
        .update({"urlImage": url});
  }

  _updateNameUserFirestore() async {
    await FirebaseFirestore.instance
        .collection("users")
        .doc(_uidCurrentUser)
        .update({"name": _nameController.text});
  }

  _recoveryUserData() async {
    setState(() {
      _isLoading = true;
    });

    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      setState(() {
        _uidCurrentUser = currentUser.uid;
      });
    }

    // get user data name and urlImage
    FirebaseFirestore db = FirebaseFirestore.instance;
    DocumentSnapshot snapshot =
        await db.collection("users").doc(_uidCurrentUser).get();

    Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;

    _nameController.text = data["name"];
    if (data["urlImage"] != null) {
      setState(() {
        _urlImage = data["urlImage"];
      });
    }

    setState(() {
      _isLoading = false;
    });
  }

  ImageProvider<Object>? _setImageScreen() {
    if (_imageFile != null) {
      return FileImage(File(_imageFile!.path));
    }

    if (_urlImage != "") {
      return NetworkImage(_urlImage);
    }

    return null;
  }

  @override
  void initState() {
    super.initState();
    _recoveryUserData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
      ),
      body: Container(
        padding: EdgeInsets.all(16),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              children: [
                // Loading
                if (_isLoading) ...[
                  const LinearProgressIndicator(),
                  const SizedBox(height: 16),
                ],
                // Image
                CircleAvatar(
                  radius: 100,
                  backgroundImage: _setImageScreen(),
                  child: _imageFile == null && _urlImage == ""
                      ? Icon(
                          Icons.camera_alt,
                          size: 100,
                        )
                      : null,
                ),
                TextButton(
                  onPressed: _selectImage,
                  child: Text("Upload Photo"),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    hintText: "Name",
                    labelText: "Name",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    _updateNameUserFirestore();

                    // notification
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Name updated successfully!"),
                      ),
                    );
                  },
                  child: Text("Update"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
