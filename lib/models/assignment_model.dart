class AssignmentModel {
  final String id;
  final String title;
  final String description;
  final String authorName;
  final String? subjectName;
  final String? courseCode;
  final DateTime createdAt;
  final DateTime dueDate;
  final String? attachmentUrl;
  final int maxMarks;
  final List<String> targetedClasses;
  final List<String> allowedFileTypes;
  final Map<String, String> regNoQuestionMap;

  // Additional fields for Upcoming Tasks module
  final String taskType; // 'Assignment', 'Lab Record', 'Quiz', 'Seminar', 'Project Review', 'Internal Assessment', 'Submission', 'Other'
  final String priority; // 'Normal', 'High', 'Urgent'
  final String status; // 'Upcoming', 'Pending', 'In Progress', 'Submitted', 'Completed', 'Overdue'
  final String? submissionInstructions;
  final DateTime? submittedAt;
  final String? submittedFileUrl;

  AssignmentModel({
    required this.id,
    required this.title,
    required this.description,
    required this.authorName,
    this.subjectName,
    this.courseCode,
    required this.createdAt,
    required this.dueDate,
    this.attachmentUrl,
    required this.maxMarks,
    required this.targetedClasses,
    this.allowedFileTypes = const ['pdf', 'docx', 'zip', 'png', 'jpg'],
    this.regNoQuestionMap = const {},
    this.taskType = 'Assignment',
    this.priority = 'Normal',
    this.status = 'Pending',
    this.submissionInstructions,
    this.submittedAt,
    this.submittedFileUrl,
  });

  bool get isOverdue => status != 'Submitted' && status != 'Completed' && dueDate.isBefore(DateTime.now());

  bool get isDueSoon {
    if (isOverdue || status == 'Submitted' || status == 'Completed') return false;
    final diff = dueDate.difference(DateTime.now());
    return diff.inHours <= 24 && !diff.isNegative;
  }

  String get dynamicStatus {
    if (status == 'Submitted' || status == 'Completed') return status;
    if (isOverdue) return 'Overdue';
    return status;
  }

  /// Get specific question assigned to student by Register Number
  String getQuestionForRegNo(String regNo) {
    if (regNoQuestionMap.containsKey(regNo)) {
      return regNoQuestionMap[regNo]!;
    }
    for (final entry in regNoQuestionMap.entries) {
      if (entry.key.contains('-')) {
        final parts = entry.key.split('-');
        if (parts.length == 2) {
          final start = parts[0].trim();
          final end = parts[1].trim();
          if (regNo.compareTo(start) >= 0 && regNo.compareTo(end) <= 0) {
            return entry.value;
          }
        }
      }
    }
    return description;
  }

  AssignmentModel copyWith({
    String? status,
    DateTime? submittedAt,
    String? submittedFileUrl,
  }) {
    return AssignmentModel(
      id: id,
      title: title,
      description: description,
      authorName: authorName,
      subjectName: subjectName,
      courseCode: courseCode,
      createdAt: createdAt,
      dueDate: dueDate,
      attachmentUrl: attachmentUrl,
      maxMarks: maxMarks,
      targetedClasses: targetedClasses,
      allowedFileTypes: allowedFileTypes,
      regNoQuestionMap: regNoQuestionMap,
      taskType: taskType,
      priority: priority,
      status: status ?? this.status,
      submissionInstructions: submissionInstructions,
      submittedAt: submittedAt ?? this.submittedAt,
      submittedFileUrl: submittedFileUrl ?? this.submittedFileUrl,
    );
  }

  factory AssignmentModel.fromMap(Map<String, dynamic> map) {
    return AssignmentModel(
      id: map['id'].toString(),
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      authorName: map['author_name'] ?? 'Staff',
      subjectName: map['subject_name'],
      courseCode: map['course_code'],
      createdAt: DateTime.parse(map['created_at'] ?? DateTime.now().toIso8601String()),
      dueDate: DateTime.parse(map['due_date'] ?? DateTime.now().toIso8601String()),
      attachmentUrl: map['attachment_url'],
      maxMarks: map['max_marks'] ?? 100,
      targetedClasses: List<String>.from(map['targeted_classes'] ?? []),
      allowedFileTypes: List<String>.from(map['allowed_file_types'] ?? ['pdf', 'docx', 'zip', 'png', 'jpg']),
      regNoQuestionMap: Map<String, String>.from(map['reg_no_question_map'] ?? {}),
      taskType: map['task_type'] ?? 'Assignment',
      priority: map['priority'] ?? 'Normal',
      status: map['status'] ?? 'Pending',
      submissionInstructions: map['submission_instructions'],
      submittedAt: map['submitted_at'] != null ? DateTime.parse(map['submitted_at']) : null,
      submittedFileUrl: map['submitted_file_url'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'author_name': authorName,
      'subject_name': subjectName,
      'course_code': courseCode,
      'created_at': createdAt.toIso8601String(),
      'due_date': dueDate.toIso8601String(),
      'attachment_url': attachmentUrl,
      'max_marks': maxMarks,
      'targeted_classes': targetedClasses,
      'allowed_file_types': allowedFileTypes,
      'reg_no_question_map': regNoQuestionMap,
      'task_type': taskType,
      'priority': priority,
      'status': status,
      'submission_instructions': submissionInstructions,
      'submitted_at': submittedAt?.toIso8601String(),
      'submitted_file_url': submittedFileUrl,
    };
  }
}
