class AssignmentModel {
  final String id;
  final String title;
  final String description;
  final String authorName;
  final String? subjectName;
  final DateTime createdAt;
  final DateTime dueDate;
  final String? attachmentUrl;
  final int maxMarks;
  final List<String> targetedClasses;

  AssignmentModel({
    required this.id,
    required this.title,
    required this.description,
    required this.authorName,
    this.subjectName,
    required this.createdAt,
    required this.dueDate,
    this.attachmentUrl,
    required this.maxMarks,
    required this.targetedClasses,
  });

  factory AssignmentModel.fromMap(Map<String, dynamic> map) {
    return AssignmentModel(
      id: map['id'].toString(),
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      authorName: map['author_name'] ?? 'Staff',
      subjectName: map['subject_name'],
      createdAt: DateTime.parse(map['created_at'] ?? DateTime.now().toIso8601String()),
      dueDate: DateTime.parse(map['due_date'] ?? DateTime.now().toIso8601String()),
      attachmentUrl: map['attachment_url'],
      maxMarks: map['max_marks'] ?? 100,
      targetedClasses: List<String>.from(map['targeted_classes'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'author_name': authorName,
      'subject_name': subjectName,
      'created_at': createdAt.toIso8601String(),
      'due_date': dueDate.toIso8601String(),
      'attachment_url': attachmentUrl,
      'max_marks': maxMarks,
      'targeted_classes': targetedClasses,
    };
  }
}
