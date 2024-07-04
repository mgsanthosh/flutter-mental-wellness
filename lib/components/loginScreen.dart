import 'package:flutter/cupertino.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mental_wellness/components/counselorHomePage.dart';
import 'package:flutter_mental_wellness/components/signupScreen.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'homeScreen.dart';

class LoginScreen extends StatefulWidget {
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool isCounsellor = false;

  void _login() async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );
      Fluttertoast.showToast(msg: 'User signed in: ${userCredential.user?.email}');
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => !isCounsellor ? HomeScreen(isCounsellor: isCounsellor) : CounsellorHomePage()),
      );
    } on FirebaseAuthException catch (e) {
      String errorMsg;
      if (e.code == 'user-not-found') {
        errorMsg = 'No user found for that email.';
      } else if (e.code == 'wrong-password') {
        errorMsg = 'Wrong password provided.';
      } else {
        errorMsg = 'An error occurred. Please try again.';
      }
      Fluttertoast.showToast(msg: errorMsg);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Spacer(), // Spacer to push content to the top when keyboard is shown
            Text(
              'Login as:',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18.0),
            ),
            SizedBox(height: 10.0),
            CupertinoSegmentedControl(
              groupValue: isCounsellor ? 1 : 0,
              children: {
                0: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.0),
                  child: Text('User'),
                ),
                1: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.0),
                  child: Text('Counsellor'),
                ),
              },
              onValueChanged: (int? newValue) {
                setState(() {
                  isCounsellor = newValue == 1;
                });
              },
              borderColor: Theme.of(context).primaryColor,
              pressedColor: Theme.of(context).primaryColor,
              unselectedColor: Theme.of(context).scaffoldBackgroundColor,
              selectedColor: Theme.of(context).primaryColor,
            ),
            SizedBox(height: 20.0),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
            ),
            SizedBox(height: 10.0),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
              obscureText: true,
            ),
            SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: _login,
              child: Text('Login'),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 15.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
            ),
            SizedBox(height: 10.0),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SignUpScreen()),
                );
              },
              child: Text('Don\'t have an account? Sign up'),
            ),
            Spacer(), // Spacer to push content to the top when keyboard is shown
          ],
        ),
      ),
    );
  }
}
