import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // 1. Sign In (Login)
  Future<User?> signInWithEmail(String email, String password, BuildContext context) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      if (!context.mounted) return null;
      _showErrorSnackBar(context, e.message);
      return null;
    }
  }

  // 2. Sign Up (Register) - Now accepts Full Name
  Future<User?> signUpWithEmail(String name, String email, String password, BuildContext context) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      // Update the Firebase Auth Profile with the Full Name
      await userCredential.user?.updateDisplayName(name);
      
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      if (!context.mounted) return null;
      _showErrorSnackBar(context, e.message);
      return null;
    }
  }




  // 3. Google Sign In
  Future<User?> signInWithGoogle(BuildContext context) async {
    try {
      GoogleAuthProvider googleProvider = GoogleAuthProvider();
      UserCredential userCredential;
      
      if (kIsWeb) {
        userCredential = await _auth.signInWithPopup(googleProvider);
      } else {
        userCredential = await _auth.signInWithProvider(googleProvider);
      }

      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      if (!context.mounted) return null;
      _showErrorSnackBar(context, e.message);
      return null;
    } catch (e) {
      if (!context.mounted) return null;
      _showErrorSnackBar(context, 'Google Sign-In failed');
      return null;
    }
  }

  // 4. GitHub Sign In
  Future<User?> signInWithGitHub(BuildContext context) async {
    try {
      GithubAuthProvider githubProvider = GithubAuthProvider();
      
      UserCredential userCredential;
      if (kIsWeb) {
        userCredential = await _auth.signInWithPopup(githubProvider);
      } else {
        userCredential = await _auth.signInWithProvider(githubProvider);
      }
      
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      if (!context.mounted) return null;
      _showErrorSnackBar(context, e.message);
      return null;
    }
  }

  // Helper method for errors
  void _showErrorSnackBar(BuildContext context, String? message) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message ?? 'An error occurred'),
        backgroundColor: Colors.redAccent,
      ),
    );
  }
}