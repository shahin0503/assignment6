import 'package:flutter/material.dart';

class ChatDetailView extends StatefulWidget {
  const ChatDetailView(
      {super.key,
      required String peerId,
      required String peerAvatar,
      required String peerNickname,
      required String userAvatar});

  @override
  State<ChatDetailView> createState() => _ChatDetailViewState();
}

class _ChatDetailViewState extends State<ChatDetailView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detail'),
      ),
    );
  }
}
