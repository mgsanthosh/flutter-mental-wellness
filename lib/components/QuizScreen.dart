import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_mental_wellness/components/homeScreen.dart';

class QuizScreen extends StatefulWidget {
  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();
  int _currentQuestionIndex = 0;
  int _score = 0;
  late User? _user;
  late Map<String, int> _categoryScores = {
    'Happy': 0,
    'Sad': 0,
    'Anxious': 0,
  };

  final List<Map<String, String>> questions = [
    {
      'question':
      'Is there any change in your sleep pattern, appetite, or energy level?',
      'type': 'Yes/No',
      'category': 'Anxious',
    },
    {
      'question':
      'Have you been consistently feeling anxious or overwhelmed lately?',
      'type': 'Yes/No',
      'category': 'Anxious',
    },
    {
      'question':
      'Have you had sudden moments of intense fear or panic recently?',
      'type': 'Yes/No',
      'category': 'Anxious',
    },
    {
      'question': 'Have your moods been noticeably changing frequently?',
      'type': 'Yes/No',
      'category': 'Sad',
    },
    {
      'question': 'Have you been feeling depressed lately?',
      'type': 'Yes/No',
      'category': 'Sad',
    },
    {
      'question':
      'Do you experience physical symptoms such as tension or headaches when stressed?',
      'type': 'Yes/No',
      'category': 'Anxious',
    },
    {
      'question': 'Have you been experiencing a lack of calmness recently?',
      'type': 'Yes/No',
      'category': 'Sad',
    },
    {
      'question': 'Are there moments in your day when you feel joyful or optimistic?',
      'type': 'Yes/No',
      'category': 'Happy',
    },
    {
      'question': 'Have you been enjoying your hobbies or activities recently?',
      'type': 'Yes/No',
      'category': 'Happy',
    },
  ];

  @override
  void initState() {
    super.initState();
    _user = _auth.currentUser;
    if (_user == null) {
      Fluttertoast.showToast(msg: 'No user signed in.');
      Navigator.pop(context);
    }
  }

  void _handleAnswer(bool isYes) {
    String currentCategory = questions[_currentQuestionIndex]['category']!;
    if (isYes) {
      _score += 5;
      if (_categoryScores.containsKey(currentCategory)) {
        int val = _categoryScores[currentCategory]!;
        _categoryScores[currentCategory] = val + 5;
      } else {
        _categoryScores[currentCategory] = 5; // Initialize if not exists
      }
    }
    if (_currentQuestionIndex < questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
      });
    } else {
      _submitQuiz();
    }
  }

  String findHighestScore() {
    // Find the highest score
    int maxScore = _categoryScores.values.reduce((value, element) => value > element ? value : element);

    // Collect categories with the highest score
    List<String> highestCategories = _categoryScores.entries.where((entry) => entry.value == maxScore).map((entry) => entry.key).toList();

    // If there are ties (more than one category with the highest score), check ascending order
    if (highestCategories.length > 1) {
      highestCategories.sort(); // Sort alphabetically
    }

    // Print or use the highest categories
    print('Highest score: $maxScore');
    print('Highest categories: $highestCategories');
    return highestCategories.last;
  }


  void _submitQuiz() async {
    String quizTime = DateTime.now().toIso8601String();
    Map<String, dynamic> quizValue = {
      'score': _score,
      'quizTime': quizTime,
      'categoryScores': _categoryScores,
      'currentMood': findHighestScore()
    };
    DatabaseReference userQuizRef =
    _dbRef.child('users/${_user!.uid}/quizHistory').push();
    await userQuizRef.set(quizValue);
    DatabaseReference latestQuizRef = _dbRef.child('users/${_user!.uid}/latestQuiz');
    await latestQuizRef.set(quizValue);
    Fluttertoast.showToast(msg: 'Quiz completed! Your score is $_score');
    _determineUserCategory();
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => HomeScreen(isCounsellor: false)));
  }

  void _determineUserCategory() {
    String maxCategory = '';
    int maxScore = 0;
    _categoryScores.forEach((category, score) {
      if (score > maxScore) {
        maxScore = score;
        maxCategory = category;
      }
    });
    print('User\'s dominant category: $maxCategory');
    // Logic to bucket the user based on their dominant category can be implemented here.
    // You can store this information in Firebase or use it for further processing.
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Quiz'),
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              questions[_currentQuestionIndex]['question']!,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.blueAccent,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                ElevatedButton(
                  onPressed: () => _handleAnswer(true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.greenAccent,
                    padding: EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                    textStyle: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  child: Text('Yes'),
                ),
                ElevatedButton(
                  onPressed: () => _handleAnswer(false),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    padding: EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                    textStyle: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  child: Text('No'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
