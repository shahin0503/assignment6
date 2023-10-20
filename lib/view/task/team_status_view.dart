import 'package:assignment6/constants/size_constant.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class TeamStatusView extends StatefulWidget {
  const TeamStatusView({super.key});

  @override
  State<TeamStatusView> createState() => _TeamStatusViewState();
}

class _TeamStatusViewState extends State<TeamStatusView> {
  String? _selectedTask;
  List<DocumentSnapshot> _taskDetails = [];

  Future<List<String>> _fetchTaskNames() async {
    QuerySnapshot tasksSnapshot =
        await FirebaseFirestore.instance.collection('tasks').get();
    List<String> taskNames = [];
    tasksSnapshot.docs.forEach((doc) {
      taskNames.add(doc[
          'taskName']); // Assuming your task name field is named 'taskName' in Firestore
    });
    return taskNames;
  }

  Future<void> _fetchTaskDetails(String selectedTaskName) async {
    QuerySnapshot taskDetailsSnapshot = await FirebaseFirestore.instance
        .collection('tasks')
        .where('taskName', isEqualTo: selectedTaskName)
        .get();
    setState(() {
      _taskDetails = taskDetailsSnapshot.docs;
    });
  }
  // tasksSnapshot.docs.forEach((doc) {
  //   taskNames.add(doc[
  //       'taskName']); // Assuming your task name field is named 'taskName' in Firestore
  // });
  // return taskNames;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            FutureBuilder<List<String>>(
              future: _fetchTaskNames(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator(); // Loading indicator while fetching data
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Select Task Name: '),
                      DropdownButton<String>(
                        value: _selectedTask,
                        onChanged: (String? newValue) {
                          setState(() {
                            _selectedTask = newValue;
                            if (_selectedTask != null) {
                              _fetchTaskDetails(_selectedTask!);
                            }
                          });
                        },
                        items: snapshot.data
                            ?.map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        hint: Text('Select Task'),
                      ),
                    ],
                  );
                }
              },
            ),
            SizedBox(
              height: Sizes.dimen_20,
            ),
            Expanded(
                child: ListView.builder(
              itemCount: _taskDetails.length,
              itemBuilder: (context, index) {
                var task = _taskDetails[index];
                Map<String, dynamic> assignedUsers = task['assignedUsers'];

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: assignedUsers.entries.map(
                    (entry) {
                      String userId = entry.key;
                      bool completed = entry.value;

                      return ListTile(
                        title: Text(
                          userId,
                          style: TextStyle(
                            decoration: completed
                                ? TextDecoration.lineThrough
                                : TextDecoration.none,
                          ),
                        ),
                        trailing: Checkbox(
                          value: completed,
                          onChanged: (bool? newValue) {
                            // Map<String, dynamic> updatedAssignedUsers =
                            //     Map.from(assignedUsers);
                            // updatedAssignedUsers[userId] = newValue;

                            FirebaseFirestore.instance
                                .collection('tasks')
                                .doc(task.id)
                                .update({
                              'assignedUsers.$userId': newValue,
                            }).then((_) {
                              // Call setState after updating Firestore data to rebuild the UI
                              setState(() {
                                _taskDetails[index]['assignedUsers'][userId] =
                                    newValue;
                              });
                            }).catchError((error) {
                              print('Error updating checkbox value: $error');
                            });
                          },
                        ),
                      );
                    },
                  ).toList(),
                );
              },
            ))
          ],
        ),
      ),
    );
  }
}
