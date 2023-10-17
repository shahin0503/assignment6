import 'package:assignment6/constants/all_constants.dart';
import 'package:assignment6/models/chat_user.dart';
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

  // String? getFirebaseUserId() {
  //   return prefs.getString(FirestoreConstants.id);
  // }

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
        ChatUser chatUser = ChatUser(
          id: user.uid,
          displayName: displayName,
          aboutMe: email,
          photoUrl: user.photoURL ?? '',
          phoneNumber: user.phoneNumber ?? '',

          // Add more user properties if needed
        );
        await firestore
            .collection(FirestoreConstants.pathUserCollection)
            .doc(user.uid)
            .set({
          'uid': user.uid,
          'displayName': displayName,
          'aboutMe': email,
          'photoUrl': user.photoURL ?? '',
          'phoneNumber': user.phoneNumber ?? ''
        });
        await prefs.setString(FirestoreConstants.id, chatUser.id);
        await prefs.setString(
            FirestoreConstants.displayName, chatUser.displayName);
        await prefs.setString(FirestoreConstants.photoUrl, chatUser.photoUrl);
        await prefs.setString(
            FirestoreConstants.phoneNumber, chatUser.phoneNumber);
        // await firestore.collection('users').doc(user.uid).set({
        //   'uid': user.uid,
        //   'displayName': displayName,
        //   'email': email,
        //   'photoUrl': user.photoURL ?? '',
        //   // Add more user properties if needed
        // });
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
