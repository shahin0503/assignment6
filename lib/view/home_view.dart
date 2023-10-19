import 'package:assignment6/constants/routes.dart';
import 'package:assignment6/constants/size_constant.dart';
import 'package:assignment6/providers/auth_provider.dart';
import 'package:assignment6/utilities/show_log_out_dialog.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  late AuthProvider authProvider;

  @override
  void initState() {
    super.initState();
    authProvider = context.read<AuthProvider>();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return Scaffold(
        appBar: AppBar(
          actions: [
            IconButton(
                onPressed: () async {
                  final shouldLogout = await showLogOutDialog(context);

                  if (shouldLogout) {
                    await authProvider.signOut();
                    Navigator.of(context)
                        .pushNamedAndRemoveUntil(signInRoute, (route) => false);
                  }
                },
                icon: const Icon(Icons.logout_sharp)),
          ],
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                'Welcome to Smart Team Application',
                style: TextStyle(
                    fontSize: Sizes.dimen_50,
                    fontWeight: FontWeight.bold,
                    color: Colors.black),
              ),
              const Padding(
                padding: EdgeInsets.all(Sizes.dimen_14),
                child: Text(
                  '''Welcome to our versatile application that seamlessly combines the power of communication and efficient task management! Whether you're on your mobile device or using the web, our app revolutionizes the way you interact and collaborate with your team. With two core components, our app offers a dynamic chatting experience that caters to both one-on-one conversations and group discussions. Stay connected effortlessly and foster meaningful conversations with your team members, no matter where they are. Additionally, our robust task manager simplifies project coordination. Easily assign tasks to team members, set deadlines, and track progress in real-time. Team members receive instant notifications for task updates, ensuring everyone stays in the loop and projects move forward seamlessly. Experience the perfect blend of communication and productivity – all in one app. Join us in transforming the way you work and collaborate. Download now and elevate your team's efficiency to new heights! ''',
                  style: TextStyle(
                    fontSize: Sizes.dimen_12,
                    color: Colors.black,
                  ),
                ),
              ),
              const SizedBox(
                height: Sizes.dimen_10,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(context, chatRoute);
                    },
                    child: Image.asset(
                      'assets/images/chat.png',
                      height: constraints.maxHeight * 0.6,
                      width: constraints.maxWidth * 0.3,
                      fit: BoxFit.fill,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(context, taskRoute);
                    },
                    child: Image.asset(
                      'assets/images/task.png',
                      height: constraints.maxHeight * 0.6,
                      width: constraints.maxWidth * 0.4,
                      fit: BoxFit.fill,
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      );
    });
  }
}
