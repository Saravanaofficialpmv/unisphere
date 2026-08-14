class ProjectModel {
  final String id;
  final String studentUid;
  final String title;
  final String description;
  final List<String> technologies;
  final String? githubUrl;
  final String? guideName;
  final String status; // 'Ongoing', 'Completed', 'In Review'
  final DateTime createdAt;

  ProjectModel({
    required this.id,
    required this.studentUid,
    required this.title,
    required this.description,
    required this.technologies,
    this.githubUrl,
    this.guideName,
    this.status = 'Ongoing',
    required this.createdAt,
  });

  factory ProjectModel.fromMap(Map<String, dynamic> map, String docId) {
    return ProjectModel(
      id: docId,
      studentUid: map['student_uid'] ?? map['studentUid'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      technologies: List<String>.from(map['technologies'] ?? []),
      githubUrl: map['github_url'] ?? map['githubUrl'],
      guideName: map['guide_name'] ?? map['guideName'],
      status: map['status'] ?? 'Ongoing',
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'].toString())
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'student_uid': studentUid,
      'title': title,
      'description': description,
      'technologies': technologies,
      'github_url': githubUrl,
      'guide_name': guideName,
      'status': status,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
