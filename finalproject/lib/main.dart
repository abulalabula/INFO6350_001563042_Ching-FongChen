import 'package:flutter/material.dart';
import 'BrowsePostsActivity.dart';
import 'SignInPage.dart';
import 'SignUpPage.dart';
import 'AuthenticationWrapper.dart';
import 'database_helper.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await DatabaseHelper.instance.database;
  // List<Map<String, dynamic>> posts = await DatabaseHelper.instance.fetchPosts();

  // Load and print initial posts to confirm database operations
  // print(posts); // check db(posts) content
  // DatabaseHelper.instance.deletePost(7);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HyperGarageSale',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => AuthenticationWrapper(),
        '/home': (context) => BrowsePostsActivity(),
        '/signin': (context) => SignInPage(),
        '/signup': (context) => SignUpPage(),
      },
    );
  }
}

class SplashScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
