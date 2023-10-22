import 'package:assignment6/constants/all_constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AssignTaskView extends StatefulWidget {
  const AssignTaskView({Key? key});

  @override
  State<AssignTaskView> createState() => _AssignTaskViewState();
}

class _AssignTaskViewState extends State<AssignTaskView> {
  TextEditingController _taskController = TextEditingController();

  List<String> selectedUsers = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Assign Task'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 50, 0, 15),
            child: Center(
              child: FractionallySizedBox(
                widthFactor: 0.45,
                child: TextFormField(
                  controller: _taskController,
                  decoration:
                      kTextInputDecoration.copyWith(labelText: 'Enter Task'),
                ),
              ),
            ),
          ),
          StreamBuilder(
            stream: FirebaseFirestore.instance.collection('users').snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const CircularProgressIndicator();
              }

              var users = snapshot.data?.docs;

              return Wrap(
                runSpacing: 8,
                children: List.generate(users?.length ?? 0, (index) {
                  var userData = users![index].data();
                  var userId = users[index].id;
                  var userName = userData['displayName'];
                  var userAbout = userData['aboutMe'];

                  return ChoiceChip(
                    label: Column(
                      children: [
                        Text(
                          '$userName',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '$userAbout',
                          style: const TextStyle(
                              color: Colors.black, fontWeight: FontWeight.w100),
                        ),
                      ],
                    ),
                    selected: selectedUsers.contains(userId),
                    onSelected: (bool selected) {
                      setState(() {
                        if (selected) {
                          selectedUsers.add(userId);
                        } else {
                          selectedUsers.remove(userId);
                        }
                      });
                    },
                    shape: StadiumBorder(),
                    backgroundColor: selectedUsers.contains(userId)
                        ? Colors.blue
                        : Colors.grey,
                    selectedColor: Colors.blue,
                  );
                }),
              );
            },
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: ElevatedButton(
        onPressed: () async {
          String taskName = _taskController.text;

          Map<String, bool> assignedUsersMap = {};
          for (String userId in selectedUsers) {
            assignedUsersMap[userId] = false;
          }

          await FirebaseFirestore.instance.collection('tasks').add({
            'taskName': taskName,
            'assignedUsers': assignedUsersMap,
          });

          setState(() {
            selectedUsers.clear();
            _taskController.clear();
          });

          // Show a success message or navigate to another screen
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Task assigned successfully!')),
          );

          Navigator.of(context).pop();
        },
        child: const Text('Assign'),
      ),
    );
  }
}
