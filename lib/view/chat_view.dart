import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'package:assignment6/constants/all_constants.dart';
import 'package:assignment6/models/chat_user.dart';
import 'package:assignment6/providers/auth_provider.dart';
import 'package:assignment6/providers/chat_provider.dart';
import 'package:assignment6/utilities/debouncer.dart';
import 'package:assignment6/utilities/keyboard_utils.dart';
import 'package:assignment6/utilities/show_log_out_dialog.dart';
import 'package:assignment6/widgets/loading_view.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ChatView extends StatefulWidget {
  const ChatView({super.key});

  @override
  State<ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends State<ChatView> {
  final ScrollController scrollController = ScrollController();

  int _limit = 20;
  final int _limitIncrement = 20;
  String _textSearch = "";
  bool isLoading = false;

  late AuthProvider authProvider;
  late String currentUserId;

  late ChatProvider chatProvider;

  Debouncer searchDebouncer = Debouncer(milliseconds: 300);
  StreamController<bool> buttonClearController = StreamController<bool>();
  TextEditingController searchTextEditingController = TextEditingController();

  Future<bool> onBackPress() {
    openDialog();
    return Future.value(false);
  }

  Future<void> openDialog() async {
    switch (await showDialog(
        context: context,
        builder: (BuildContext ctx) {
          return SimpleDialog(
            backgroundColor: AppColors.burgundy,
            title: const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Exit Application',
                  style: TextStyle(color: AppColors.white),
                ),
                Icon(
                  Icons.exit_to_app,
                  size: 30,
                  color: Colors.white,
                ),
              ],
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(Sizes.dimen_10),
            ),
            children: [
              vertical10,
              const Text(
                'Are you sure?',
                textAlign: TextAlign.center,
                style:
                    TextStyle(color: AppColors.white, fontSize: Sizes.dimen_16),
              ),
              vertical15,
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  SimpleDialogOption(
                    onPressed: () {
                      Navigator.pop(context, 0);
                    },
                    child: const Text(
                      'Cancel',
                      style: TextStyle(color: AppColors.white),
                    ),
                  ),
                  SimpleDialogOption(
                    onPressed: () {
                      Navigator.pop(context, 1);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(Sizes.dimen_8),
                      ),
                      padding: const EdgeInsets.fromLTRB(14, 8, 14, 8),
                      child: const Text(
                        'Yes',
                        style: TextStyle(color: AppColors.spaceCadet),
                      ),
                    ),
                  )
                ],
              )
            ],
          );
        })) {
      case 0:
        break;
      case 1:
        exit(0);
    }
  }

  void scrollListener() {
    if (scrollController.offset >= scrollController.position.maxScrollExtent &&
        !scrollController.position.outOfRange) {
      setState(() {
        _limit += _limitIncrement;
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
    buttonClearController.close();
  }

  @override
  void initState() {
    super.initState();
    authProvider = context.read<AuthProvider>();
    chatProvider = context.read<ChatProvider>();

    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      setState(() {
        currentUserId = user.uid;
      });
    } else {
      Navigator.of(context)
          .pushNamedAndRemoveUntil(signInRoute, (route) => false);
    }

    scrollController.addListener(scrollListener);
  }

  @override
  Widget build(BuildContext context) {
    log('chat view screen');
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Smart Talk'),
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
          IconButton(
              onPressed: () {
                Navigator.of(context).pushNamed(profileRoute);
              },
              icon: const Icon(Icons.person))
        ],
      ),
      body: Stack(children: [
        Column(
          children: [
            buildSearchBar(),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: chatProvider.getFirestoreData(
                  FirestoreConstants.pathUserCollection,
                  _limit,
                  _textSearch,
                ),
                builder: (BuildContext context,
                    AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.hasData) {
                    if ((snapshot.data?.docs.length ?? 0) > 0) {
                      return ListView.separated(
                        shrinkWrap: true,
                        itemCount: snapshot.data!.docs.length,
                        itemBuilder: (context, index) =>
                            buildItem(context, snapshot.data?.docs[index]),
                        controller: scrollController,
                        separatorBuilder: (BuildContext context, int index) =>
                            const Divider(),
                      );
                    } else {
                      return const Center(child: Text('No User Found'));
                    }
                  } else {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                },
              ),
            )
          ],
        ),
        Positioned(
          child: isLoading ? const LoadingView() : const SizedBox.shrink(),
        ),
      ]),
    );
  }

  Widget buildSearchBar() {
    return Container(
      margin: const EdgeInsets.all(Sizes.dimen_10),
      height: Sizes.dimen_50,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(Sizes.dimen_30),
        color: AppColors.spaceLight,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(
            width: Sizes.dimen_10,
          ),
          const Icon(
            Icons.person_search,
            color: AppColors.white,
            size: Sizes.dimen_24,
          ),
          const SizedBox(
            width: 5,
          ),
          Expanded(
            child: TextFormField(
              textInputAction: TextInputAction.search,
              controller: searchTextEditingController,
              onChanged: (value) {
                updateSearchText(value);
                if (value.isNotEmpty) {
                  buttonClearController.add(true);
                  setState(() {
                    _textSearch = value;
                  });
                } else {
                  buttonClearController.add(false);
                  setState(() {
                    _textSearch = "";
                  });
                }
              },
              decoration: const InputDecoration.collapsed(
                hintText: 'Search here...',
                hintStyle: TextStyle(color: AppColors.white),
              ),
            ),
          ),
          StreamBuilder(
              stream: buttonClearController.stream,
              builder: (context, snapshot) {
                return snapshot.data == true
                    ? GestureDetector(
                        onTap: () {
                          searchTextEditingController.clear();
                          buttonClearController.add(false);
                          setState(() {
                            _textSearch = '';
                          });
                        },
                        child: const Icon(
                          Icons.clear_rounded,
                          color: AppColors.greyColor,
                          size: 20,
                        ),
                      )
                    : const SizedBox.shrink();
              })
        ],
      ),
    );
  }

  void updateSearchText(String searchText) {
    if (searchText.isNotEmpty) {
      buttonClearController.add(true);
      setState(() {
        _textSearch = searchText;
      });
    } else {
      buttonClearController.add(false);
      setState(() {
        _textSearch = '';
      });
    }
  }

  Widget buildItem(BuildContext context, DocumentSnapshot? documentSnapshot) {
    log('message');
    log('message: ${documentSnapshot?.id}');
    final firebaseAuth = FirebaseAuth.instance;
    if (documentSnapshot != null && documentSnapshot.exists) {
      ChatUser userChat = ChatUser.fromDocument(documentSnapshot);
      log('message: $userChat');
      if (userChat.id == currentUserId) {
        return const SizedBox.shrink();
      } else {
        return TextButton(
          onPressed: () {
            if (KeyboardUtils.isKeyboardShowing()) {
              KeyboardUtils.closeKeyboard(context);
            }
            print(userChat.displayName);
            Navigator.of(context).pushNamed(
              chatDetailRoute,
              arguments: {
                'peerId': userChat.id,
                'peerAvatar': userChat.photoUrl,
                'peerNickname': userChat.displayName,
                'userAvatar': firebaseAuth.currentUser!.photoURL,
              },
            );
          },
          child: ListTile(
            leading: userChat.photoUrl.isNotEmpty
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(Sizes.dimen_30),
                    child: Image.network(
                      userChat.photoUrl,
                      fit: BoxFit.cover,
                      width: 50,
                      height: 50,
                      loadingBuilder: (BuildContext ctx, Widget child,
                          ImageChunkEvent? loadingProgress) {
                        if (loadingProgress == null) {
                          return child;
                        } else {
                          return SizedBox(
                            width: 50,
                            height: 50,
                            child: CircularProgressIndicator(
                                color: Colors.grey,
                                value: loadingProgress.expectedTotalBytes !=
                                        null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                        loadingProgress.expectedTotalBytes!
                                    : null),
                          );
                        }
                      },
                      errorBuilder: (context, object, stackTrace) {
                        return const Icon(Icons.account_circle, size: 50);
                      },
                    ),
                  )
                : const Icon(
                    Icons.account_circle,
                    size: 50,
                  ),
            title: Text(
              userChat.displayName,
              style: const TextStyle(color: Colors.black),
            ),
          ),
        );
      }
    } else {
      return const SizedBox.shrink();
    }
  }
}
