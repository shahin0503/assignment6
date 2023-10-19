import 'package:assignment6/constants/all_constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AssignTaskView extends StatefulWidget {
  const AssignTaskView({super.key});

  @override
  State<AssignTaskView> createState() => _AssignTaskViewState();
}

class _AssignTaskViewState extends State<AssignTaskView> {
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
                  // controller: _taskController,
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
                return CircularProgressIndicator(); // Loading indicator while fetching data
              }

              var users = snapshot.data?.docs;

              List<Widget> userChips = [];

              for (var user in users!) {
                var userData = user.data() as Map<String, dynamic>;
                var userName = userData[
                    'displayName']; // Assuming 'name' is the field in your user collection
                var userAbout = userData[
                    'aboutMe']; // Assuming 'email' is the field in your user collection

                var userChip = Chip(
                  label: Column(
                    children: [
                      Text(
                        '$userName',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '$userAbout',
                        style: TextStyle(
                            color: Colors.grey, fontWeight: FontWeight.w600),
                      )
                    ],
                  ),

                  // You can add more properties like avatar, delete functionality, etc., as per your requirements
                );

                userChips.add(userChip);
              }

              return SingleChildScrollView(
                child: Column(
                  children: userChips,
                ),
              );
            },
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton:
          ElevatedButton(onPressed: () {}, child: Text('Assign')),
    );
  }
}
