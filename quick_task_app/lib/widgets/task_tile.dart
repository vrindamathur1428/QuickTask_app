import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/task.dart';

class TaskTile extends StatelessWidget {
  final Task task;
  final Function(bool?)? onCheckboxChanged;
  final Function() onDeletePressed;

  TaskTile({
    required this.task,
    required this.onCheckboxChanged,
    required this.onDeletePressed,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        task.title,
        style: TextStyle(
          decoration: task.status ? TextDecoration.lineThrough : null,
        ),
      ),
      subtitle: Text(
        DateFormat.yMMMd().format(task.dueDate),
        style: TextStyle(
          fontStyle: FontStyle.italic,
          decoration: task.status ? TextDecoration.lineThrough : null,
        ),
      ),
      leading: Checkbox(
        value: task.status,
        onChanged: onCheckboxChanged,
      ),
      trailing: IconButton(
        icon: Icon(Icons.delete),
        onPressed: onDeletePressed,
      ),
    );
  }
}
