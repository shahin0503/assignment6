import 'package:assignment6/constants/all_constants.dart';
import 'package:flutter/material.dart';

class TaskView extends StatefulWidget {
  const TaskView({super.key});

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
      floatingActionButton: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ElevatedButton(
            onPressed: () {
              Navigator.of(context).pushNamed(assignTaskRoute);
            },
            style: ElevatedButton.styleFrom(
                shape: const RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.only(topLeft: Radius.circular(10)))),
            child: const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                'Assign task',
                style: TextStyle(
                  fontSize: 18.0, // Adjust the font size as needed
                ),
              ),
            )),
      ),
    );
  }
}
