import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class Profileinfo extends StatefulWidget {
  final bool isCounsellor;

  Profileinfo({required this.isCounsellor});

  @override
  State<Profileinfo> createState() => _ProfileinfoState();
}

class _ProfileinfoState extends State<Profileinfo> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();
  Map<dynamic, dynamic>? _userDetails;

  @override
  void initState() {
    super.initState();
    _getCurrentUser();
  }

  void _getCurrentUser() async {
    User? user = _auth.currentUser;
    if (user != null) {
      String dbName = widget.isCounsellor ? 'counselors' : 'users'; // Replace with your actual database name
      DatabaseReference userRef = _dbRef.child('$dbName/${user.uid}');
      DataSnapshot snapshot = await userRef.get();
      setState(() {
        _userDetails = snapshot.value! as Map?;
      });
    } else {
      Fluttertoast.showToast(msg: 'No user signed in.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      child: _userDetails != null
          ? Padding(
              padding: const EdgeInsets.all(0.0),
              child: Card(
                color: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundImage:
                            NetworkImage(_userDetails!['imageUrl']),
                        backgroundColor: Colors.grey.shade200,
                      ),
                      SizedBox(height: 10),
                      Text(
                        '${_userDetails!['firstName']} ${_userDetails!['lastName']}',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Colors.blueAccent,
                        ),
                      ),
                      SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Icon(Icons.cake, color: Colors.black87),
                              SizedBox(width: 8),
                              Text(
                                'Age: ${_userDetails!['age']}',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(width: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.phone, color: Colors.black87),
                              SizedBox(width: 8),
                              Text(
                                _userDetails!['phoneNumber'],
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.email, color: Colors.black87),
                          SizedBox(width: 8),
                          Text(
                            _userDetails!['email'],
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),

                    ],
                  ),
                ),
              ),
            )
          : Center(child: CircularProgressIndicator()),
    );
  }
}
