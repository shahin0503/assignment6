import 'package:assignment6/constants/routes.dart';
import 'package:assignment6/firebase_options.dart';
import 'package:assignment6/providers/auth_provider.dart';
import 'package:assignment6/providers/chat_message_provider.dart';
import 'package:assignment6/providers/chat_provider.dart';
import 'package:assignment6/providers/profile_provider.dart';
import 'package:assignment6/utilities/theme.dart';
import 'package:assignment6/view/chat_detail_view.dart';
import 'package:assignment6/view/chat_view.dart';
import 'package:assignment6/view/home_view.dart';
import 'package:assignment6/view/login_view.dart';
import 'package:assignment6/view/profile_view.dart';
import 'package:assignment6/view/sign_up_view.dart';
import 'package:assignment6/view/splash_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  SharedPreferences prefs = await SharedPreferences.getInstance();
  FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
  FirebaseStorage firebaseStorage = FirebaseStorage.instance;

  runApp(MultiProvider(
    providers: [
      Provider<ChatProvider>(
          create: (_) => ChatProvider(firebaseFirestore: firebaseFirestore)),
      ChangeNotifierProvider<AuthProvider>(
        create: (_) => AuthProvider(
            firebaseAuth: FirebaseAuth.instance,
            firestore: firebaseFirestore,
            prefs: prefs),
      ),
      Provider<ProfileProvider>(
        create: (_) => ProfileProvider(
            prefs: prefs,
            firebaseStorage: firebaseStorage,
            firebaseFirestore: firebaseFirestore),
      ),
      Provider<ChatMessageProvider>(
          create: (_) => ChatMessageProvider(
              prefs: prefs,
              firebaseStorage: firebaseStorage,
              firebaseFirestore: firebaseFirestore))
      // Add other providers if needed
    ],
    child: MyApp(prefs: prefs),
  ));
}

class MyApp extends StatelessWidget {
  final SharedPreferences prefs;

  MyApp({super.key, required this.prefs}) {
    Get.put(AuthProvider(
        firebaseAuth: FirebaseAuth.instance,
        firestore: FirebaseFirestore.instance,
        prefs: prefs));
  }

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Smart Talk',
      theme: appTheme,
      routes: {
        signInRoute: (context) => const LoginView(),
        signUpRoute: (context) => const SignUpView(),
        homeRoute: (context) => const HomeScreen(),
        profileRoute: (context) => const ProfileView(),
        chatRoute: (context) => const ChatView(),
        chatDetailRoute: (context) => const ChatDetailView(
              peerNickname: '',
              peerAvatar: '',
              peerId: '',
              userAvatar: '',
            ),
      },
      home: const SplashPage(),
    );
  }
}
