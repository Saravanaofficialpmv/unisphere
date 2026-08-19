/// ─────────────────────────────────────────────────────────────
/// Resume Header & Contact Information
/// ─────────────────────────────────────────────────────────────
class ResumeHeader {
  final String fullName;
  final String headline;
  final String collegeEmail;
  final String? personalEmail;
  final String? phone;
  final bool isPhoneVisible;
  final String location;
  final String? linkedinUrl;
  final String? githubUrl;
  final String? leetcodeUrl;
  final String? portfolioUrl;
  final List<String> languages;
  final List<String> professionalInterests;

  const ResumeHeader({
    required this.fullName,
    required this.headline,
    required this.collegeEmail,
    this.personalEmail,
    this.phone,
    this.isPhoneVisible = true,
    required this.location,
    this.linkedinUrl,
    this.githubUrl,
    this.leetcodeUrl,
    this.portfolioUrl,
    this.languages = const [],
    this.professionalInterests = const [],
  });

  Map<String, dynamic> toMap() => {
        'fullName': fullName,
        'headline': headline,
        'collegeEmail': collegeEmail,
        'personalEmail': personalEmail,
        'phone': phone,
        'isPhoneVisible': isPhoneVisible,
        'location': location,
        'linkedinUrl': linkedinUrl,
        'githubUrl': githubUrl,
        'leetcodeUrl': leetcodeUrl,
        'portfolioUrl': portfolioUrl,
        'languages': languages,
        'professionalInterests': professionalInterests,
      };

  factory ResumeHeader.fromMap(Map<String, dynamic> map) => ResumeHeader(
        fullName: map['fullName'] ?? '',
        headline: map['headline'] ?? '',
        collegeEmail: map['collegeEmail'] ?? '',
        personalEmail: map['personalEmail'],
        phone: map['phone'],
        isPhoneVisible: map['isPhoneVisible'] ?? true,
        location: map['location'] ?? '',
        linkedinUrl: map['linkedinUrl'],
        githubUrl: map['githubUrl'],
        leetcodeUrl: map['leetcodeUrl'],
        portfolioUrl: map['portfolioUrl'],
        languages: List<String>.from(map['languages'] ?? []),
        professionalInterests: List<String>.from(map['professionalInterests'] ?? []),
      );
}

/// ─────────────────────────────────────────────────────────────
/// Education Record Item
/// ─────────────────────────────────────────────────────────────
class ResumeEducationItem {
  final String degree;
  final String institution;
  final String? boardOrUniversity;
  final String period;
  final String? score; // CGPA / Percentage
  final String? scoreLabel; // e.g. "CGPA: 8.92 / 10.0"
  final String? currentYearOrSem;
  final bool isPrimaryCollege;

  const ResumeEducationItem({
    required this.degree,
    required this.institution,
    this.boardOrUniversity,
    required this.period,
    this.score,
    this.scoreLabel,
    this.currentYearOrSem,
    this.isPrimaryCollege = false,
  });

  Map<String, dynamic> toMap() => {
        'degree': degree,
        'institution': institution,
        'boardOrUniversity': boardOrUniversity,
        'period': period,
        'score': score,
        'scoreLabel': scoreLabel,
        'currentYearOrSem': currentYearOrSem,
        'isPrimaryCollege': isPrimaryCollege,
      };

  factory ResumeEducationItem.fromMap(Map<String, dynamic> map) => ResumeEducationItem(
        degree: map['degree'] ?? '',
        institution: map['institution'] ?? '',
        boardOrUniversity: map['boardOrUniversity'],
        period: map['period'] ?? '',
        score: map['score'],
        scoreLabel: map['scoreLabel'],
        currentYearOrSem: map['currentYearOrSem'],
        isPrimaryCollege: map['isPrimaryCollege'] ?? false,
      );
}

/// ─────────────────────────────────────────────────────────────
/// Professional Experience & Internships
/// ─────────────────────────────────────────────────────────────
class ResumeExperienceItem {
  final String id;
  final String organization;
  final String role;
  final String type; // Internship, Startup, Freelance, Work Experience
  final String duration;
  final String? location;
  final List<String> bulletPoints;

  const ResumeExperienceItem({
    required this.id,
    required this.organization,
    required this.role,
    required this.type,
    required this.duration,
    this.location,
    required this.bulletPoints,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'organization': organization,
        'role': role,
        'type': type,
        'duration': duration,
        'location': location,
        'bulletPoints': bulletPoints,
      };

  factory ResumeExperienceItem.fromMap(Map<String, dynamic> map) => ResumeExperienceItem(
        id: map['id'] ?? '',
        organization: map['organization'] ?? '',
        role: map['role'] ?? '',
        type: map['type'] ?? 'Internship',
        duration: map['duration'] ?? '',
        location: map['location'],
        bulletPoints: List<String>.from(map['bulletPoints'] ?? []),
      );
}

/// ─────────────────────────────────────────────────────────────
/// Key Projects
/// ─────────────────────────────────────────────────────────────
class ResumeProjectItem {
  final String id;
  final String title;
  final String role;
  final String description;
  final List<String> technologies;
  final List<String> outcomes;
  final String? githubUrl;
  final String? liveUrl;
  final String? status;

  const ResumeProjectItem({
    required this.id,
    required this.title,
    required this.role,
    required this.description,
    required this.technologies,
    this.outcomes = const [],
    this.githubUrl,
    this.liveUrl,
    this.status,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'role': role,
        'description': description,
        'technologies': technologies,
        'outcomes': outcomes,
        'githubUrl': githubUrl,
        'liveUrl': liveUrl,
        'status': status,
      };

  factory ResumeProjectItem.fromMap(Map<String, dynamic> map) => ResumeProjectItem(
        id: map['id'] ?? '',
        title: map['title'] ?? '',
        role: map['role'] ?? 'Lead Developer',
        description: map['description'] ?? '',
        technologies: List<String>.from(map['technologies'] ?? []),
        outcomes: List<String>.from(map['outcomes'] ?? []),
        githubUrl: map['githubUrl'],
        liveUrl: map['liveUrl'],
        status: map['status'],
      );
}

/// ─────────────────────────────────────────────────────────────
/// Certifications (NPTEL, Industry, Approved)
/// ─────────────────────────────────────────────────────────────
class ResumeCertificationItem {
  final String id;
  final String title;
  final String provider; // e.g. NPTEL, AWS, Google Cloud, Microsoft
  final String type; // NPTEL, Industry, Verified
  final String? certificateId;
  final String? issueDate;
  final String? credentialUrl;
  final bool isVerified;

  const ResumeCertificationItem({
    required this.id,
    required this.title,
    required this.provider,
    required this.type,
    this.certificateId,
    this.issueDate,
    this.credentialUrl,
    this.isVerified = true,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'provider': provider,
        'type': type,
        'certificateId': certificateId,
        'issueDate': issueDate,
        'credentialUrl': credentialUrl,
        'isVerified': isVerified,
      };

  factory ResumeCertificationItem.fromMap(Map<String, dynamic> map) => ResumeCertificationItem(
        id: map['id'] ?? '',
        title: map['title'] ?? '',
        provider: map['provider'] ?? '',
        type: map['type'] ?? 'Industry',
        certificateId: map['certificateId'],
        issueDate: map['issueDate'],
        credentialUrl: map['credentialUrl'],
        isVerified: map['isVerified'] ?? true,
      );
}

/// ─────────────────────────────────────────────────────────────
/// Activities & Achievements (Hackathons, Leadership, Honors)
/// ─────────────────────────────────────────────────────────────
class ResumeActivityItem {
  final String id;
  final String title;
  final String category; // Hackathon, Competition, Leadership, Award, Club
  final String? organizer;
  final String? roleOrRank; // 1st Rank, Team Lead, Active Member
  final String? date;
  final String? description;

  const ResumeActivityItem({
    required this.id,
    required this.title,
    required this.category,
    this.organizer,
    this.roleOrRank,
    this.date,
    this.description,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'category': category,
        'organizer': organizer,
        'roleOrRank': roleOrRank,
        'date': date,
        'description': description,
      };

  factory ResumeActivityItem.fromMap(Map<String, dynamic> map) => ResumeActivityItem(
        id: map['id'] ?? '',
        title: map['title'] ?? '',
        category: map['category'] ?? 'Achievement',
        organizer: map['organizer'],
        roleOrRank: map['roleOrRank'],
        date: map['date'],
        description: map['description'],
      );
}

/// ─────────────────────────────────────────────────────────────
/// Categorized Skills
/// ─────────────────────────────────────────────────────────────
class ResumeSkillCategory {
  final String categoryName; // e.g. "Programming Languages", "Frameworks & Libraries", "Databases & Cloud"
  final List<String> skills;

  const ResumeSkillCategory({
    required this.categoryName,
    required this.skills,
  });

  Map<String, dynamic> toMap() => {
        'categoryName': categoryName,
        'skills': skills,
      };

  factory ResumeSkillCategory.fromMap(Map<String, dynamic> map) => ResumeSkillCategory(
        categoryName: map['categoryName'] ?? '',
        skills: List<String>.from(map['skills'] ?? []),
      );
}

/// ─────────────────────────────────────────────────────────────
/// Completeness System Item & Result
/// ─────────────────────────────────────────────────────────────
class ResumeCompletenessItem {
  final String id;
  final String title;
  final String description;
  final bool isCompleted;
  final bool isRequired; // Required vs Recommended
  final String actionRoute; // Route or module to navigate for updates
  final String actionLabel;

  const ResumeCompletenessItem({
    required this.id,
    required this.title,
    required this.description,
    required this.isCompleted,
    required this.isRequired,
    required this.actionRoute,
    required this.actionLabel,
  });
}

class ResumeCompleteness {
  final int scorePercentage;
  final int requiredTotal;
  final int requiredCompleted;
  final int recommendedTotal;
  final int recommendedCompleted;
  final List<ResumeCompletenessItem> checklist;

  const ResumeCompleteness({
    required this.scorePercentage,
    required this.requiredTotal,
    required this.requiredCompleted,
    required this.recommendedTotal,
    required this.recommendedCompleted,
    required this.checklist,
  });

  List<ResumeCompletenessItem> get requiredItems =>
      checklist.where((c) => c.isRequired).toList();

  List<ResumeCompletenessItem> get recommendedItems =>
      checklist.where((c) => !c.isRequired).toList();

  List<ResumeCompletenessItem> get missingRecommended =>
      checklist.where((c) => !c.isRequired && !c.isCompleted).toList();
}

/// ─────────────────────────────────────────────────────────────
/// Full Dedicated Student Resume Model
/// ─────────────────────────────────────────────────────────────
class StudentResumeModel {
  final String studentUid;
  final String registerNumber;
  final String department;
  final String academicYear;
  final String section;
  final ResumeHeader header;
  final String professionalSummary;
  final List<ResumeEducationItem> education;
  final List<ResumeExperienceItem> experience;
  final List<ResumeProjectItem> projects;
  final List<ResumeCertificationItem> certifications;
  final List<ResumeActivityItem> activitiesAndAchievements;
  final List<ResumeSkillCategory> categorizedSkills;
  final List<String> allSkills;
  final ResumeCompleteness completeness;
  final List<String> strengths;
  final DateTime lastUpdatedAt;
  final int version;

  const StudentResumeModel({
    required this.studentUid,
    required this.registerNumber,
    required this.department,
    required this.academicYear,
    required this.section,
    required this.header,
    required this.professionalSummary,
    required this.education,
    required this.experience,
    required this.projects,
    required this.certifications,
    required this.activitiesAndAchievements,
    required this.categorizedSkills,
    required this.allSkills,
    required this.completeness,
    this.strengths = const [
      'Strong foundation in Object-Oriented Programming (OOP) and software design principles.',
      'Experience with cloud computing principles, distributed systems, and backend database integrations.',
      'Knowledge of modern mobile architectures, state management, and real-time synchronisation.',
      'Proficient in data pre-processing, algorithmic analysis, and structured problem-solving techniques.',
      'Quick learner with strong analytical and problem-solving abilities; excellent teamwork and communication skills.',
      'Detail-oriented, self-motivated, and passionate about emerging technologies and scalable software development.',
    ],
    required this.lastUpdatedAt,
    this.version = 1,
  });

  bool get hasExperience => experience.isNotEmpty;
  bool get hasProjects => projects.isNotEmpty;
  bool get hasCertifications => certifications.isNotEmpty;
  bool get hasActivities => activitiesAndAchievements.isNotEmpty;
  bool get hasSkills => categorizedSkills.any((cat) => cat.skills.isNotEmpty);
  bool get hasEducation => education.isNotEmpty;
  bool get hasStrengths => strengths.isNotEmpty;

  StudentResumeModel copyWith({
    String? studentUid,
    String? registerNumber,
    String? department,
    String? academicYear,
    String? section,
    ResumeHeader? header,
    String? professionalSummary,
    List<ResumeEducationItem>? education,
    List<ResumeExperienceItem>? experience,
    List<ResumeProjectItem>? projects,
    List<ResumeCertificationItem>? certifications,
    List<ResumeActivityItem>? activitiesAndAchievements,
    List<ResumeSkillCategory>? categorizedSkills,
    List<String>? allSkills,
    List<String>? strengths,
    ResumeCompleteness? completeness,
    DateTime? lastUpdatedAt,
    int? version,
  }) {
    return StudentResumeModel(
      studentUid: studentUid ?? this.studentUid,
      registerNumber: registerNumber ?? this.registerNumber,
      department: department ?? this.department,
      academicYear: academicYear ?? this.academicYear,
      section: section ?? this.section,
      header: header ?? this.header,
      professionalSummary: professionalSummary ?? this.professionalSummary,
      education: education ?? this.education,
      experience: experience ?? this.experience,
      projects: projects ?? this.projects,
      certifications: certifications ?? this.certifications,
      activitiesAndAchievements: activitiesAndAchievements ?? this.activitiesAndAchievements,
      categorizedSkills: categorizedSkills ?? this.categorizedSkills,
      allSkills: allSkills ?? this.allSkills,
      strengths: strengths ?? this.strengths,
      completeness: completeness ?? this.completeness,
      lastUpdatedAt: lastUpdatedAt ?? this.lastUpdatedAt,
      version: version ?? this.version,
    );
  }

  String toPlainText() {
    final buffer = StringBuffer();
    buffer.writeln(header.fullName.toUpperCase());
    buffer.writeln(header.headline);
    buffer.writeln('${header.collegeEmail} | ${header.phone ?? ""} | ${header.linkedinUrl ?? ""} | ${header.githubUrl ?? ""}');
    buffer.writeln('\n${"=" * 40}');
    buffer.writeln('PROFESSIONAL SUMMARY');
    buffer.writeln(professionalSummary);

    if (hasEducation) {
      buffer.writeln('\n${"=" * 40}');
      buffer.writeln('EDUCATION');
      for (final e in education) {
        buffer.writeln('${e.degree} - ${e.institution} (${e.period})');
        if (e.scoreLabel != null) buffer.writeln(e.scoreLabel);
      }
    }

    if (hasSkills) {
      buffer.writeln('\n${"=" * 40}');
      buffer.writeln('TECHNICAL SKILLS');
      for (final cat in categorizedSkills) {
        buffer.writeln('${cat.categoryName}: ${cat.skills.join(" · ")}');
      }
    }

    if (hasProjects) {
      buffer.writeln('\n${"=" * 40}');
      buffer.writeln('PROJECTS');
      for (final p in projects) {
        buffer.writeln(p.title);
        if (p.technologies.isNotEmpty) buffer.writeln('Technologies: ${p.technologies.join(" · ")}');
        buffer.writeln(p.description);
        for (final out in p.outcomes) {
          buffer.writeln('• $out');
        }
      }
    }

    if (hasCertifications) {
      buffer.writeln('\n${"=" * 40}');
      buffer.writeln('CERTIFICATIONS');
      for (final c in certifications) {
        buffer.writeln('• ${c.title} - ${c.provider}');
      }
    }

    if (hasStrengths) {
      buffer.writeln('\n${"=" * 40}');
      buffer.writeln('ADDITIONAL STRENGTHS');
      for (final s in strengths) {
        buffer.writeln('• $s');
      }
    }

    return buffer.toString();
  }
}
