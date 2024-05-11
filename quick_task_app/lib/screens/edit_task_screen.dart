import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/task.dart';

class EditTaskScreen extends StatefulWidget {
  final Task task;

  EditTaskScreen({required this.task});

  @override
  _EditTaskScreenState createState() => _EditTaskScreenState();
}

class _EditTaskScreenState extends State<EditTaskScreen> {
  late TextEditingController _titleController;
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    // Initialize text controller with task title and selected date
    _titleController = TextEditingController(text: widget.task.title);
    _selectedDate = widget.task.dueDate;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Task'),
      ),
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _buildTitleTextField(),
          const SizedBox(height: 20.0),
          _buildDueDateRow(context),
          const SizedBox(height: 20.0),
          _buildUpdateButton(context),
        ],
      ),
    );
  }

  Widget _buildTitleTextField() {
    return TextField(
      controller: _titleController,
      decoration: const InputDecoration(labelText: 'Task Title'),
    );
  }

  Widget _buildDueDateRow(BuildContext context) {
    return Row(
      children: <Widget>[
        const Text(
          'Due Date:',
          style: TextStyle(fontSize: 16.0),
        ),
        const SizedBox(width: 20.0),
        TextButton(
          onPressed: () => _selectDate(context),
          child: Text(
            DateFormat.yMMMd().format(_selectedDate),
            style: const TextStyle(fontSize: 16.0),
          ),
        ),
      ],
    );
  }

  Widget _buildUpdateButton(BuildContext context) {
    return ElevatedButton(
      onPressed: () => _updateTask(context),
      child: const Text('Update Task'),
    );
  }

  // Function to select due date
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  // Function to update task
  void _updateTask(BuildContext context) {
    if (_titleController.text.trim().isEmpty) {
      // Show error dialog if title is empty
      _showErrorDialog(context, 'Task title cannot be empty.');
    } else {
      // Create updated task object and pass it back to the previous screen
      Task updatedTask = Task(
        title: _titleController.text.trim(),
        dueDate: _selectedDate,
        status: widget.task.status,
        id: widget.task.id,
      );
      Navigator.pop(context, updatedTask);
    }
  }

  // Function to show error dialog
  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }
}
