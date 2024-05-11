class Task {
  final String id;
  final String title;
  final DateTime dueDate;
  bool status;

  Task({
    required this.id,
    required this.title,
    required this.dueDate,
    required this.status,
  });

  // Factory method to create Task object from JSON
  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['objectId'] ?? '',
      title: json['title'] ?? '',
      dueDate: DateTime.parse(json['dueDate']['iso']),
      status: json['status'] ?? false,
    );
  }

  // Convert Task object to JSON
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'dueDate': {'__type': 'Date', 'iso': dueDate.toIso8601String()},
      'status': status,
    };
  }

  // Method to toggle the status of the task
  void toggleStatus() {
    status = !status;
  }
}
