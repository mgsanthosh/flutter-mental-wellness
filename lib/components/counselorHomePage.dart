import 'package:blurrycontainer/blurrycontainer.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mental_wellness/components/widgets/profileInfo.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'loginScreen.dart';
import 'chatScreen.dart'; // Import the ChatScreen

class CounsellorHomePage extends StatefulWidget {
  const CounsellorHomePage({super.key});

  @override
  State<CounsellorHomePage> createState() => _CounsellorHomePageState();
}

class _CounsellorHomePageState extends State<CounsellorHomePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();
  List<Map<String, dynamic>> _chats = [];


  @override
  void initState() {
    super.initState();
    _getChats();
  }

  Future<Map?> _getUserDetails(String userId) async {
    if (userId.isNotEmpty) {
      DatabaseReference userRef = _dbRef.child(
          'users/$userId'); // Replace 'users' with your actual database name
      DataSnapshot snapshot = await userRef.get();
      return snapshot.value as Map?;
    } else {
      Fluttertoast.showToast(msg: 'No user Details found.');
      return null;
    }
  }

  void _getChats() async {
    User? user = _auth.currentUser;
    if (user != null) {
      DatabaseReference expertsRef = _dbRef.child('chat/${user.uid}');
      DataSnapshot snapshot = await expertsRef.get();
      if (snapshot.exists) {
        Map<dynamic, dynamic>? chatData = snapshot.value as Map?;
        if (chatData != null) {
          List<Map<String, dynamic>> chats = [];
          for (var entry in chatData.entries) {
            Map<dynamic, dynamic>? userDetails =
                await _getUserDetails(entry.key);
            if (userDetails != null) {
              userDetails['chat'] = entry.value;
              userDetails['userId'] = entry.key;
              chats.add(Map<String, dynamic>.from(userDetails));
            }
          }
          setState(() {
            _chats = chats;
          });
        }
      }
    }
  }

  void _logout() async {
    await _auth.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
    );
  }

  void _startChat(Map<String, dynamic> userDetails) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatScreen(
          chatProps: {
            'userDetails': {
              'userId': _auth.currentUser!.uid,
              'firstName': 'Counsellor',
              // You can update this with actual counsellor details if available
            },
            'expertDetails': userDetails,
            'chatLink':
                '${_auth.currentUser!.uid}/${userDetails['userId']}',
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Counsellor's Home Screen"),
        automaticallyImplyLeading: false,
        elevation: 10,
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: Column(
        children: [
          BlurryContainer(
            blur: 8,
            height: 320,
            elevation: 6,
            width: double.infinity,
            child: Profileinfo(isCounsellor: true),
          ),
          Text("Hi Counselor", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
          Text("Please find the Chat Requests Below", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, fontStyle: FontStyle.italic),),
          ListView.builder(
            itemCount: _chats.length,
            shrinkWrap: true,
            itemBuilder: (context, index) {
              final chat = _chats[index];
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
                        radius: 30,
                        backgroundImage: NetworkImage(chat['imageUrl']),
                      ),
                      SizedBox(width: 16.0),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "${chat['firstName']} ${chat['lastName']}",
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 10),
                            Text("Age: ${chat['age']}"),
                            SizedBox(height: 5),
                            Text("Phone: ${chat['phoneNumber']}"),
                            SizedBox(height: 5),
                            Text("Email: ${chat['email']}"),
                          ],
                        ),
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: ElevatedButton(
                          onPressed: () => _startChat(chat),
                          child: Text("Chat"),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          )
        ],
      ),
    );
  }
}
