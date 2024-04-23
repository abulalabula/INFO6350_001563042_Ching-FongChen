import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'BrowsePostsActivity.dart';
import 'SignInPage.dart';

class AuthenticationWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.active) {
          User? user = snapshot.data;
          if (user == null) {
            return SignInPage(); 
          }
          return BrowsePostsActivity(); 
        }
        return CircularProgressIndicator(); // Loading indicator while waiting for auth state
      },
    );
  }
}
