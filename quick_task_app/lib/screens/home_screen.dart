import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:quick_task_app/screens/edit_task_screen.dart';
import 'package:quick_task_app/screens/login_screen.dart';
import 'add_task_screen.dart';
import '../models/task.dart';
import '../services/backend_service.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Task> _tasks = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchTasks();
  }

  // Fetch tasks from backend
  Future<void> _fetchTasks() async {
    setState(() {
      _isLoading = true;
    });
    try {
      List<Map<String, dynamic>> taskData = await BackendService.fetchTasks();
      List<Task> tasks = taskData.map((data) => Task.fromJson(data)).toList();
      setState(() {
        _tasks = tasks;
        _isLoading = false;
      });
    } catch (error) {
      setState(() {
        _isLoading = false;
      });
      print("Error fetching tasks: $error");
    }
  }

  // Add a new task
  Future<void> _addTask(Task newTask) async {
    try {
      await _fetchTasks();
    } catch (error) {
      print("Error adding task: $error");
    }
  }

  // Edit an existing task
  Future<void> _editTask(Task task) async {
    try {
      final editedTask = await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => EditTaskScreen(task: task)),
      );
      if (editedTask != null) {
        setState(() {
          _tasks[_tasks.indexWhere((element) => element.id == editedTask.id)] =
              editedTask;
        });
        await BackendService.updateTask(editedTask);
      }
    } catch (error) {
      print("Error editing task: $error");
    }
  }

  // Delete a task
  Future<void> _deleteTask(String taskId) async {
    bool confirmDelete = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Confirm Delete"),
          content: Text("Are you sure you want to delete this task?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text("Delete"),
            ),
          ],
        );
      },
    );

    if (confirmDelete == true) {
      try {
        await BackendService.deleteTask(taskId);
        await _fetchTasks();
      } catch (error) {
        print("Error deleting task: $error");
      }
    }
  }

  // Toggle task completion status
  Future<void> _toggleTaskCompletion(String taskId, bool isCompleted) async {
    try {
      setState(() {
        _tasks.firstWhere((task) => task.id == taskId).toggleStatus();
      });
      await BackendService.toggleTaskCompletion(taskId, isCompleted);
    } catch (error) {
      print("Error toggling task completion: $error");
    }
  }

  // Sign out user
  Future<void> _signOut() async {
    try {
      await BackendService.signOut();
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => LoginScreen()));
    } catch (error) {
      print("Error signing out: $error");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Task List'),
        actions: [
          IconButton(
            icon: Icon(Icons.exit_to_app),
            onPressed: () {
              _signOut();
            },
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: ElevatedButton.icon(
              onPressed: () async {
                final Task? newTask = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AddTaskScreen()),
                );
                if (newTask != null) {
                  await _addTask(newTask);
                }
              },
              icon: Icon(Icons.add),
              label: Text('Create Task'),
            ),
          ),
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator())
                : _buildTaskList(),
          ),
        ],
      ),
    );
  }

  // Build task list
  Widget _buildTaskList() {
    return ListView.builder(
      itemCount: _tasks.length,
      itemBuilder: (context, index) {
        final task = _tasks[index];
        return ListTile(
          title: Text(task.title),
          subtitle: Text(
            DateFormat.yMMMd().format(task.dueDate),
            style: TextStyle(fontStyle: FontStyle.italic),
          ),
          leading: IconButton(
            icon: Icon(
              task.status ? Icons.check_circle : Icons.radio_button_unchecked,
              color: task.status ? Colors.green : Colors.grey,
            ),
            onPressed: () {
              _toggleTaskCompletion(task.id, !task.status);
            },
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: Icon(Icons.edit),
                onPressed: () {
                  _editTask(task);
                },
              ),
              IconButton(
                icon: Icon(Icons.delete),
                onPressed: () {
                  _deleteTask(task.id);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
