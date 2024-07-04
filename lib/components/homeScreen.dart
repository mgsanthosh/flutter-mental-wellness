import 'dart:async';
import 'package:blurrycontainer/blurrycontainer.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mental_wellness/components/widgets/profileInfo.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'ExpertsScreen.dart';
import 'QuizScreen.dart';
import 'VideoPlayerScreen.dart';
import 'loginScreen.dart';

class HomeScreen extends StatefulWidget {
  final bool isCounsellor;

  HomeScreen({required this.isCounsellor});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();
  DateTime? _latestQuizTime;
  int _minutesLeft = 0;
  int _secondsLeft = 0;
  Timer? _timer;
  String? _quizScore;
  String? _currentFeeling;
  List<Map<String, String>> _videos = [];
  int _selectedIndex = 0;
  String _CURRENTSCREEN = "HOME";

  @override
  void initState() {
    super.initState();
    _getLatestQuizTime();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      // Handle navigation or any state changes based on the index
      switch (_selectedIndex) {
        case 0:
          _CURRENTSCREEN = "HOME";
          break;
        case 1:
          _CURRENTSCREEN = "EXPERTS";
          break;
      }
    });
  }

  void _getLatestQuizTime() async {
    User? user = _auth.currentUser;
    if (user != null) {
      DatabaseReference quizRef = _dbRef.child('users/${user.uid}');
      DataSnapshot snapshot = await quizRef.get();
      if (snapshot.exists) {
        Map<dynamic, dynamic>? quizData = snapshot.value as Map?;
        if (quizData != null) {
          quizData['latestQuiz'].forEach((key, value) {
            setState(() {
              if (key == "quizTime") {
                _latestQuizTime = DateTime.parse(value);
              } else if (key == "score") {
                _quizScore = value.toString();
              } else if (key == "currentMood") {
                _currentFeeling = value.toString();
              }
            });
          });
        }
        _loadVideosBasedOnMood();
      }
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_latestQuizTime != null) {
        setState(() {
          final timeDiff = DateTime.now().difference(_latestQuizTime!);
          _minutesLeft = 14 - timeDiff.inMinutes;
          _secondsLeft = 59 - timeDiff.inSeconds % 60;

          if (_minutesLeft < 0) {
            _minutesLeft = 0;
            _secondsLeft = 0;
            _timer?.cancel();
          }
        });
      }
    });
  }

  void _logout() async {
    await _auth.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
    );
  }

  void _navigateToQuiz() {
    if (_minutesLeft <= 0 && _secondsLeft <= 0) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => QuizScreen()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => QuizScreen()),
      );
      Fluttertoast.showToast(
        msg:
            'You can take the quiz in $_minutesLeft minutes $_secondsLeft seconds.',
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    }
  }

  void _loadVideosBasedOnMood() {
    // Sample data based on mood
    if (_currentFeeling == 'Sad') {
      _videos = [
        {
          "link": "https://youtu.be/iqcAWup2aCE?si=QKfVBHVUkfv2VKl_",
          "title": "Yoga To Treat Anxiety"
        },
        {
          "link": "https://youtu.be/lHVYgnlukTw?si=ManDO3p5or7f68jY",
          "title": " 5 Ways to Deal with Anxiety "
        },
        {
          "link": "https://youtu.be/NE56XyroZY4?si=9IJsF_yTQsMOKncF",
          "title": "Ease the Head Pain"
        }
      ];
    } else if (_currentFeeling == 'Happy') {
      _videos = [
        {
          "link": "https://youtu.be/NE56XyroZY4?si=9IJsF_yTQsMOKncF",
          "title": "Ease the Head Pain"
        },
        {
          "link": "https://youtu.be/K2LnW1gF6Eg?si=EDXh_aOovQzsiMaw",
          "title": "Yoga for Mood Swings"
        },
        {
          "link": "https://youtu.be/6mZP1GORRC8?si=rh-RSLmWG3qagks2",
          "title": "Ways to Prevent Frequent Mood Fluctuations "
        }
      ];
    } else if (_currentFeeling == 'Anxious') {
      _videos = [
        {
          "link": "https://youtu.be/MjMkBaqimFo",
          "title": "Emotional Benefits of Exercise "
        },
        {
          "link": "https://youtu.be/Sxddnugwu-8",
          "title": "Yoga For Depression "
        },
        {
          "link": "https://youtu.be/sFtP0HWvu0k",
          "title": "Exercise for Depression"
        }
      ];
    }
  }

  void _openVideoPlayer(String videoLink) {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => VideoPlayerScreen(videoLink: videoLink)),
    );
  }

  // void _viewMoreVideos() {
  //   Navigator.push(
  //     context,
  //     MaterialPageRoute(builder: (context) => AllVideosScreen(videos: _videos)),
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Home Screen"),
        automaticallyImplyLeading: false,
        elevation: 10,
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/homeBG1.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          SingleChildScrollView(
            child: _CURRENTSCREEN == "HOME" ? Container(
              child: Column(
                children: [
                  BlurryContainer(
                    blur: 8,
                    height: 320,
                    elevation: 6,
                    width: double.infinity,
                    child: Profileinfo(isCounsellor: false),
                  ),
                  Card(
                    margin: EdgeInsets.all(16.0),
                    elevation: 10,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            "Quiz Status",
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.blueAccent,
                            ),
                          ),
                          Divider(
                            color: Colors.blueAccent,
                            thickness: 2,
                          ),
                          SizedBox(height: 15),
                          if (_minutesLeft > 0 || _secondsLeft > 0)
                            Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.timer,
                                      color: Colors.redAccent,
                                      size: 30,
                                    ),
                                    SizedBox(width: 10),
                                    Text(
                                      'You can take the quiz in:',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        fontStyle: FontStyle.italic,
                                        color: Colors.black54,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 5),
                                Text(
                                  '$_minutesLeft minutes $_secondsLeft seconds',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.redAccent,
                                    fontWeight: FontWeight.bold,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ],
                            ),
                          if (_minutesLeft <= 0 && _secondsLeft <= 0)
                            Text(
                              'You can take the quiz now!',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.green,
                                fontWeight: FontWeight.bold,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          SizedBox(height: 15),
                          _quizScore != null ?  Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Your previous test score was:',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.black54,
                                ),
                              ),
                              SizedBox(width: 10),
                              Text(
                                '$_quizScore',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.blueAccent,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ) : Container(),
                          SizedBox(height: 10),
                          _currentFeeling != null ? Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'You are feeling:',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.black54,
                                ),
                              ),
                              SizedBox(width: 10),
                              Text(
                                '$_currentFeeling',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.blueAccent,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ) : Container(),
                          SizedBox(height: 20),
                          _currentFeeling != null ? CircleAvatar(
                            radius: 40,
                            backgroundColor: Colors.transparent,
                            child: Image.asset(
                              _currentFeeling == 'Sad'
                                  ? 'assets/images/sad.png'
                                  : _currentFeeling == 'Happy'
                                      ? 'assets/images/happy.png'
                                      : 'assets/images/anxious.png',
                              fit: BoxFit.contain,
                            ),
                          ) : Container(),
                          SizedBox(height: 20),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.white,
                              backgroundColor: Colors.blueAccent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              padding: EdgeInsets.symmetric(
                                  vertical: 12, horizontal: 20),
                            ),
                            onPressed: _navigateToQuiz,
                            child: Text(
                              "TAKE QUIZ",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  _videos.length > 0 ? Center(
                    child: Text(
                      "Videos Crafted For You!",
                      style:
                          TextStyle(fontSize: 23, fontWeight: FontWeight.bold),
                    ),
                  ) : Container(),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: _videos.length,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () {
                          _openVideoPlayer(_videos[index]['link']!);
                        },
                        child: Card(
                          margin:
                              EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                          elevation: 5,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _videos[index]['title']!,
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blueAccent,
                                  ),
                                ),
                                SizedBox(height: 8),
                                AspectRatio(
                                  aspectRatio: 16 / 9,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(12.0),
                                    child: Image.network(
                                      'https://img.youtube.com/vi/${(_videos[index]['link']!.split("/").last).split("?").first}/0.jpg',
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ) : ExpertsScreen(),
          )
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Experts',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blueAccent,
        onTap: _onItemTapped,
      ),
    );
  }
}
