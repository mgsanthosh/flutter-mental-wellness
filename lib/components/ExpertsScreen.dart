import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'chatScreen.dart';

class ExpertsScreen extends StatefulWidget {
  const ExpertsScreen({super.key});

  @override
  State<ExpertsScreen> createState() => _ExpertsScreenState();
}

class _ExpertsScreenState extends State<ExpertsScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();
  List<Map<String, dynamic>> _experts = [];
  Map<dynamic, dynamic>? _userDetails;
  Map<dynamic, dynamic>? chatProps;

  @override
  void initState() {
    super.initState();
    _getExperts();
    _getCurrentUser();
  }

  void _getCurrentUser() async {
    User? user = _auth.currentUser;
    if (user != null) {
      String dbName = 'users'; // Replace with your actual database name
      DatabaseReference userRef = _dbRef.child('$dbName/${user.uid}');
      DataSnapshot snapshot = await userRef.get();
      setState(() {
        _userDetails = snapshot.value! as Map?;
      });
    } else {
      Fluttertoast.showToast(msg: 'No user signed in.');
    }
  }

  void _getExperts() async {
    DatabaseReference expertsRef = _dbRef.child('counselors');
    DataSnapshot snapshot = await expertsRef.get();
    if (snapshot.exists) {
      Map<dynamic, dynamic>? expertData = snapshot.value as Map?;
      if (expertData != null) {
        expertData.forEach((key, value) {
          _experts.add(Map<String, dynamic>.from(value));
        });
        setState(() {});
      }
    }
  }

  Future<void> _chatWithExpert(dynamic expert) async{
    // Implement chat functionality here
    DatabaseReference messageRef = _dbRef.child('messages/${expert['userId']}/${_userDetails!['userId']}');
    Map<dynamic, dynamic>? userData = {"userDetails": _userDetails};
    await messageRef.set(userData);
    Fluttertoast.showToast(msg: "Chat with ${expert['userId']}");
    Map<String, dynamic> chatProps = {
      "userDetails": _userDetails,
      "chatLink": '${expert['userId']}/${_userDetails!['userId']}',
      "expertDetails": expert
    };
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ChatScreen(chatProps: chatProps)),
    );

  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Center(
          child: Text("Our Experts", style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),),
        ),
        Center(
          child: Text("All your problems are confidential", style: TextStyle(fontStyle: FontStyle.italic),),
        ),
        SizedBox(
          height: 20,
        ),
        Container(
          child: _experts.isEmpty
              ? Center(child: CircularProgressIndicator())
              : ListView.builder(
            shrinkWrap: true,
            itemCount: _experts.length,
            itemBuilder: (context, index) {
              final expert = _experts[index];
              return Card(
                margin: EdgeInsets.all(16.0),
                elevation: 10,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundImage: NetworkImage(expert['imageUrl']),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "${expert['firstName']} ${expert['lastName']}",
                              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 8),
                            Text(
                              "Age: ${expert['age']}",
                              style: TextStyle(fontSize: 16),
                            ),
                            SizedBox(height: 8),
                            ElevatedButton(
                              onPressed: () => _chatWithExpert(expert),
                              child: Text('Chat'),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ]
    );
  }
}
