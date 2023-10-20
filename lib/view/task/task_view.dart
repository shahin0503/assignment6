import 'package:assignment6/constants/all_constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class TaskView extends StatefulWidget {
  const TaskView({Key? key});

  @override
  State<TaskView> createState() => _TaskViewState();
}

class _TaskViewState extends State<TaskView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Task Manager'),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('tasks').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return CircularProgressIndicator();
          }

          var tasks = snapshot.data?.docs;
          var user = FirebaseAuth.instance.currentUser;

          // Filter tasks assigned to the logged-in user
          var userTasks = tasks?.where((task) {
            var assignedUsers = task['assignedUsers'] as List;
            return assignedUsers.contains(user?.uid);
          }).toList();

          return ListView.builder(
            itemCount: userTasks?.length,
            itemBuilder: (context, index) {
              var task = userTasks?[index];
              var taskName = task?['taskName'];

              return ListTile(
                title: Text(taskName),
                // You can customize how you want to display other task details here
              );
            },
          );
        },
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ElevatedButton(
          onPressed: () {
            Navigator.of(context).pushNamed(assignTaskRoute);
          },
          style: ElevatedButton.styleFrom(
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.only(topLeft: Radius.circular(10)),
            ),
          ),
          child: const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              'Assign task',
              style: TextStyle(
                fontSize: 18.0, // Adjust the font size as needed
              ),
            ),
          ),
        ),
      ),
    );
  }
}
