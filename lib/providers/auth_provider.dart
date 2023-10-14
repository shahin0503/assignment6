import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum Status {
  uninitialized,
  authenticated,
  authenticating,
  authenticateError,
}

class AuthProvider extends ChangeNotifier {
  final FirebaseAuth firebaseAuth;
  final FirebaseFirestore firestore;
  final SharedPreferences prefs;

  Status _status = Status.uninitialized;

  Status get status => _status;

  AuthProvider({
    required this.firebaseAuth,
    required this.firestore,
    required this.prefs,
  });

  Future<bool> createUser(
      String email, String password, String displayName) async {
    _status = Status.authenticating;
    notifyListeners();

    try {
      await firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = firebaseAuth.currentUser;
      if (user != null) {
        await createUserInFirestore(displayName, email);
        _status = Status.authenticated;
        notifyListeners();
        return true;
      } else {
        _status = Status.authenticateError;
        notifyListeners();
        return false;
      }
    } catch (e) {
      print("Error: $e");
      _status = Status.authenticateError;
      notifyListeners();
      return false;
    }
  }

  Future<bool> signIn(String email, String password) async {
    _status = Status.authenticating;
    notifyListeners();

    try {
      await firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = firebaseAuth.currentUser;
      if (user != null) {
        _status = Status.authenticated;
        notifyListeners();
        return true;
      } else {
        _status = Status.authenticateError;
        notifyListeners();
        return false;
      }
    } catch (e) {
      print("Error: $e");
      _status = Status.authenticateError;
      notifyListeners();
      return false;
    }
  }

  Future<void> createUserInFirestore(String displayName, String email) async {
    User? user = firebaseAuth.currentUser;
    if (user != null) {
      try {
        await firestore.collection('users').doc(user.uid).set({
          'uid': user.uid,
          'displayName': displayName,
          'email': email,
          // Add more user properties if needed
        });
      } catch (e) {
        print('Error creating user in Firestore: $e');
        // Handle the error appropriately, e.g., show an error message to the user
      }
    }
  }

  User? get currentUser {
    return firebaseAuth.currentUser;
  }

  Future<void> signOut() async {
    _status = Status.uninitialized;
    await firebaseAuth.signOut();
    notifyListeners();
  }
}
