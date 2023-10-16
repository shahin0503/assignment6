import 'package:flutter/material.dart';

class ChatView extends StatefulWidget {
  const ChatView({super.key});

  @override
  State<ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends State<ChatView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Smart Talk'),
        actions: [
          IconButton(onPressed: (){}, icon: Icon(Icons.logout_sharp)),
          IconButton(onPressed: (){}, icon: Icon(Icons.person))
        ],
      ),
    );
  }
}