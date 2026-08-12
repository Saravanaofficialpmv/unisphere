import 'package:flutter/material.dart';
import 'package:unisphere/models/assignment_model.dart';
import 'package:unisphere/models/submission_model.dart';

class TaskService extends ChangeNotifier {
  static final TaskService _instance = TaskService._internal();
  factory TaskService() => _instance;

  TaskService._internal() {
    _initSeedTasks();
  }

  final List<AssignmentModel> _tasks = [];
  final List<SubmissionModel> _submissions = [];

  List<AssignmentModel> get tasks => List.unmodifiable(_tasks);
  List<SubmissionModel> get submissions => List.unmodifiable(_submissions);

  int get pendingCount => _tasks.where((t) => t.status == 'Pending' || t.status == 'In Progress' || t.isOverdue).length;
  int get overdueCount => _tasks.where((t) => t.isOverdue).length;
  int get dueSoonCount => _tasks.where((t) => t.isDueSoon).length;

  void _initSeedTasks() {
    final now = DateTime.now();

    _tasks.addAll([
      AssignmentModel(
        id: 'task_001',
        title: 'Submit Lab Record',
        description: 'Prepare and submit your lab record for Data Structures. Include all executed algorithm code snippets, output logs, and AVL tree rotation diagrams.',
        authorName: 'Prof. Sarah Jenkins',
        subjectName: 'Data Structures Lab',
        courseCode: 'CS201L',
        createdAt: now.subtract(const Duration(days: 2)),
        dueDate: now.add(const Duration(days: 2)),
        maxMarks: 100,
        taskType: 'Lab Record',
        priority: 'High',
        status: 'Pending',
        targetedClasses: ['CSE - 3rd Year - Sec A'],
        submissionInstructions: 'Upload a clean PDF document containing your index page, signed lab experiments, and source code listings.',
      ),
      AssignmentModel(
        id: 'task_002',
        title: 'Mini Project Review',
        description: 'Upload your Mini Project progress report and dynamic slide presentation for Phase 1 review.',
        authorName: 'Dr. Robert Miller',
        subjectName: 'Mini Project',
        courseCode: 'CS304P',
        createdAt: now.subtract(const Duration(days: 4)),
        dueDate: now.add(const Duration(days: 4)),
        maxMarks: 50,
        taskType: 'Project Review',
        priority: 'Urgent',
        status: 'In Progress',
        targetedClasses: ['CSE - 3rd Year - Sec A'],
        submissionInstructions: 'Submit a ZIP archive containing your project architectural diagrams, database schema export, and PowerPoint slides.',
      ),
      AssignmentModel(
        id: 'task_003',
        title: 'Seminar Presentation',
        description: 'Submit your research seminar paper on Next-Gen TCP/IP Protocol Optimizations and IPv6 Migration.',
        authorName: 'Prof. Anita Sharma',
        subjectName: 'Computer Networks',
        courseCode: 'CS205',
        createdAt: now.subtract(const Duration(days: 5)),
        dueDate: now.add(const Duration(days: 8)),
        maxMarks: 100,
        taskType: 'Seminar',
        priority: 'Normal',
        status: 'Upcoming',
        targetedClasses: ['CSE - 3rd Year - Sec A'],
        submissionInstructions: 'Submit your 10-page IEEE format seminar report in PDF format.',
      ),
      AssignmentModel(
        id: 'task_004',
        title: 'Operating Systems Quiz 2',
        description: 'Online multiple-choice assessment covering Process Scheduling, Deadlocks, and Memory Paging algorithms.',
        authorName: 'Dr. Alan Turing',
        subjectName: 'Operating Systems',
        courseCode: 'CS301',
        createdAt: now.subtract(const Duration(days: 1)),
        dueDate: now.subtract(const Duration(hours: 3)), // Overdue
        maxMarks: 20,
        taskType: 'Quiz',
        priority: 'High',
        status: 'Overdue',
        targetedClasses: ['CSE - 3rd Year - Sec A'],
      ),
      AssignmentModel(
        id: 'task_005',
        title: 'Database Design Case Study',
        description: 'Design a 3NF normalized database schema for a Healthcare Hospital Management System.',
        authorName: 'Prof. Anita Sharma',
        subjectName: 'DBMS',
        courseCode: 'CS204',
        createdAt: now.subtract(const Duration(days: 7)),
        dueDate: now.subtract(const Duration(days: 1)),
        maxMarks: 100,
        taskType: 'Assignment',
        priority: 'Normal',
        status: 'Submitted',
        submittedAt: now.subtract(const Duration(days: 1, hours: 2)),
        submittedFileUrl: 'https://storage.unisphere.edu/submissions/Healthcare_DBMS_Design.pdf',
        targetedClasses: ['CSE - 3rd Year - Sec A'],
      ),
    ]);
  }

  List<AssignmentModel> getFilteredTasks({
    String? subject,
    String? taskType,
    String? status,
    String? searchQuery,
    String? dateGroup, // 'Today', 'This Week', 'Next Week', 'Later', 'Overdue'
  }) {
    return _tasks.where((task) {
      final matchesSubject = subject == null || subject == 'All' || task.subjectName == subject;
      final matchesType = taskType == null || taskType == 'All' || task.taskType == taskType;
      
      bool matchesStatus = true;
      if (status != null && status != 'All') {
        if (status == 'Overdue') {
          matchesStatus = task.isOverdue;
        } else {
          matchesStatus = task.status == status;
        }
      }

      final query = searchQuery?.toLowerCase().trim() ?? '';
      final matchesSearch = query.isEmpty ||
          task.title.toLowerCase().contains(query) ||
          (task.subjectName?.toLowerCase().contains(query) ?? false) ||
          task.description.toLowerCase().contains(query);

      bool matchesDateGroup = true;
      if (dateGroup != null && dateGroup != 'All') {
        final now = DateTime.now();
        final diffDays = task.dueDate.difference(now).inDays;
        if (dateGroup == 'Overdue') {
          matchesDateGroup = task.isOverdue;
        } else if (dateGroup == 'Today') {
          matchesDateGroup = task.dueDate.day == now.day && task.dueDate.month == now.month && task.dueDate.year == now.year;
        } else if (dateGroup == 'This Week') {
          matchesDateGroup = diffDays >= 0 && diffDays <= 7;
        } else if (dateGroup == 'Next Week') {
          matchesDateGroup = diffDays > 7 && diffDays <= 14;
        } else if (dateGroup == 'Later') {
          matchesDateGroup = diffDays > 14;
        }
      }

      return matchesSubject && matchesType && matchesStatus && matchesSearch && matchesDateGroup;
    }).toList()
      ..sort((a, b) => a.dueDate.compareTo(b.dueDate)); // Nearest deadline first
  }

  void submitTask(String taskId, String fileUrl) {
    final index = _tasks.indexWhere((t) => t.id == taskId);
    if (index != -1) {
      _tasks[index] = _tasks[index].copyWith(
        status: 'Submitted',
        submittedAt: DateTime.now(),
        submittedFileUrl: fileUrl,
      );
      notifyListeners();
    }
  }

  void addTask(AssignmentModel task) {
    _tasks.insert(0, task);
    notifyListeners();
  }

  void updateTaskStatus(String taskId, String newStatus) {
    final index = _tasks.indexWhere((t) => t.id == taskId);
    if (index != -1) {
      _tasks[index] = _tasks[index].copyWith(status: newStatus);
      notifyListeners();
    }
  }

  List<String> get uniqueSubjects {
    final subjects = _tasks.map((t) => t.subjectName).whereType<String>().toSet().toList();
    subjects.sort();
    return subjects;
  }
}
