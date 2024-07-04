import 'package:flutter/cupertino.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mental_wellness/components/counselorHomePage.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_database/firebase_database.dart';

import 'homeScreen.dart';

class SignUpScreen extends StatefulWidget {
  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();
  File? _image;
  String? _imageUrl;
  bool _isCounsellor = false;

  final ImagePicker _picker = ImagePicker();

  void _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    } else {
      print('No image selected.');
    }
  }

  Future<void> _uploadImageToStorage() async {
    if (_image == null) return;

    try {
      final storageRef = FirebaseStorage.instance.ref();
      final imageRef = storageRef.child('user_images/${_auth.currentUser?.uid}.jpg');
      final uploadTask = imageRef.putFile(_image!);

      final snapshot = await uploadTask.whenComplete(() {});
      final downloadUrl = await snapshot.ref.getDownloadURL();

      setState(() {
        _imageUrl = downloadUrl;
      });

      print('Image uploaded to: $_imageUrl');
    } catch (e) {
      print('Error uploading image: $e');
      Fluttertoast.showToast(msg: 'Error uploading image: $e');
    }
  }

  Future<void> _saveUserToFirebaseDatabase(User user) async {
    String dbName = _isCounsellor ? 'counselors' : 'users';
    await _dbRef.child('${dbName}/${user.uid}').set({
      'firstName': _firstNameController.text,
      'lastName': _lastNameController.text,
      'email': user.email,
      'phoneNumber': _phoneNumberController.text,
      'age': _ageController.text,
      'imageUrl': _imageUrl,
      'isCounsellor': _isCounsellor,
      'userId': user.uid
    });
  }

  void _signUp() async {
    if (_validateInputs()) {
      try {
        UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
          email: _emailController.text,
          password: _passwordController.text,
        );

        await _uploadImageToStorage();
        await _saveUserToFirebaseDatabase(userCredential.user!);

        Fluttertoast.showToast(msg: 'User signed up: ${userCredential.user?.email}');
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => !_isCounsellor ? HomeScreen(isCounsellor: _isCounsellor) : CounsellorHomePage()),
        );
      } on FirebaseAuthException catch (e) {
        String errorMsg;
        if (e.code == 'weak-password') {
          errorMsg = 'The password provided is too weak.';
        } else if (e.code == 'email-already-in-use') {
          errorMsg = 'An account already exists for that email.';
        } else {
          errorMsg = 'An error occurred. Please try again.';
        }
        Fluttertoast.showToast(msg: errorMsg);
      }
    } else {
      Fluttertoast.showToast(msg: 'Please fill all fields and upload an image.');
    }
  }

  bool _validateInputs() {
    if (_emailController.text.isEmpty ||
        _passwordController.text.isEmpty ||
        _firstNameController.text.isEmpty ||
        _lastNameController.text.isEmpty ||
        _phoneNumberController.text.isEmpty ||
        _ageController.text.isEmpty ||
        _image == null) {
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sign Up'),
        elevation: 10,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text('User'),
                Switch(
                  value: _isCounsellor,
                  onChanged: (value) {
                    setState(() {
                      _isCounsellor = value;
                    });
                  },
                ),
                Text('Counsellor'),
              ],
            ),
            TextField(
              controller: _firstNameController,
              decoration: InputDecoration(
                labelText: 'First Name',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _lastNameController,
              decoration: InputDecoration(
                labelText: 'Last Name',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            SizedBox(height: 10),
            TextField(
              controller: _phoneNumberController,
              decoration: InputDecoration(
                labelText: 'Phone Number',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _ageController,
              decoration: InputDecoration(
                labelText: 'Age',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 20),
            _image == null
                ? Text('No image selected.')
                : Container(
              width: 200,
              height: 200,
              child: Image.file(
                _image!,
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _pickImage,
              child: Text('Upload Photo'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _signUp,
              child: Text('Sign Up'),
            ),
          ],
        ),
      ),
    );
  }
}
