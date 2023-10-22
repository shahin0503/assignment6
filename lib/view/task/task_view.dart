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
  final User? user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    var isWideScreen = MediaQuery.of(context).size.width > 600;
    var crossAxisCount = isWideScreen ? 2 : 1;

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
          List<Widget> taskWidgets = [];

          for (var task in tasks!) {
            var taskData = task.data() as Map<String, dynamic>;
            var taskName = taskData['taskName'] as String;
            var assignedUsers =
                taskData['assignedUsers'] as Map<String, dynamic>;

            // Check if the logged-in user is assigned to the task
            if (assignedUsers.containsKey(user?.uid)) {
              var isCompleted = assignedUsers[user?.uid] as bool;
              taskWidgets.add(ListTile(
                title: Text(
                  taskName,
                  style: TextStyle(
                    decoration: isCompleted
                        ? TextDecoration.lineThrough
                        : TextDecoration.none,
                  ),
                ),
                trailing: Checkbox(
                  value: isCompleted,
                  onChanged: (bool? value) {
                    FirebaseFirestore.instance
                        .collection('tasks')
                        .doc(task.id)
                        .update({
                      'assignedUsers.${user?.uid}': value,
                    });
                  },
                ),
              ));
            }
          }
          return GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount, childAspectRatio: 10),
              itemCount: taskWidgets.length,
              itemBuilder: (context, index) {
                return Card(elevation: 4, child: taskWidgets[index]);
              });
        },
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Padding(
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
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).pushNamed(taskStatusRoute);
              },
              style: ElevatedButton.styleFrom(
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(10)),
                ),
              ),
              child: const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  'Task Status',
                  style: TextStyle(
                    fontSize: 18.0, // Adjust the font size as needed
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
