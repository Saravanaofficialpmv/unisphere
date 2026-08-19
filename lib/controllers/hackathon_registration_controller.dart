import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unisphere/models/hackathon_registration_model.dart';
import 'package:unisphere/models/hackathon_model.dart';
import 'package:unisphere/services/hackathon_reminder_engine.dart';
import 'package:unisphere/services/hackathon_activity_logger.dart';

final hackathonRegistrationProvider =
    StateNotifierProvider<HackathonRegistrationNotifier, List<HackathonRegistrationModel>>((ref) {
  return HackathonRegistrationNotifier();
});

class HackathonRegistrationNotifier extends StateNotifier<List<HackathonRegistrationModel>> {
  final HackathonReminderEngine _reminderEngine = HackathonReminderEngine();

  HackathonRegistrationNotifier() : super(_getInitialMockRegistrations());

  static const String demoStudentId = 'STU-2026-042';

  static List<HackathonRegistrationModel> _getInitialMockRegistrations() {
    final now = DateTime.now();

    return [
      // 🟢 ONGOING 1 (Smart India Hackathon 2026)
      HackathonRegistrationModel(
        id: 'REG-SIH-8841',
        hackathonId: 'HACK-SIH-2026',
        hackathonTitle: 'Smart India Hackathon 2026 (Software Edition)',
        studentId: demoStudentId,
        studentName: 'Alex Johnson',
        department: 'Computer Science & Engineering',
        year: '3rd Year',
        email: 'alex.j@unisphere.edu',
        phone: '+91 98765 43210',
        teamName: 'Innovators',
        teamMembers: ['Alex Johnson (Lead)', 'Sarah Connor', 'David Kim', 'Priya Sharma'],
        registrationDate: now.subtract(const Duration(days: 10)),
        startDate: DateTime(2026, 8, 10),
        endDate: DateTime(2026, 8, 18),
        participationStatus: 'Active Participant',
        mode: 'Online',
        location: 'Virtual / SIH Portal',
        organizer: 'Ministry of Education & AICTE',
        description: 'Nationwide 36-hour hackathon focused on solving real-world government and industry problems using technology.',
        bannerImage: 'https://images.unsplash.com/photo-1526374965328-7f61d4dc18c5?w=800&q=80',
        rules: [
          'All code must be committed to the official repository during the hackathon timeline.',
          'Teams must consist of up to 4 members with at least 1 female member.',
          'Plagiarism or pre-built complete solutions will result in disqualification.',
        ],
        submissionDeadline: DateTime(2026, 8, 18, 18, 0),
      ),

      // 🟢 ONGOING 2 (Web3 & Smart Contracts Challenge)
      HackathonRegistrationModel(
        id: 'REG-W3-2026-77',
        hackathonId: 'HACK-102',
        hackathonTitle: 'Global Web3 & Smart Contracts Challenge',
        studentId: demoStudentId,
        studentName: 'Alex Johnson',
        department: 'Computer Science & Engineering',
        year: '3rd Year',
        email: 'alex.j@unisphere.edu',
        phone: '+91 98765 43210',
        teamName: 'ZkSquad',
        teamMembers: ['Alex Johnson (Lead)', 'Pranav V', 'Deepika R'],
        registrationDate: now.subtract(const Duration(days: 5)),
        startDate: DateTime(2026, 8, 11),
        endDate: DateTime(2026, 8, 16),
        participationStatus: 'Active Participant',
        mode: 'Online',
        location: 'Discord & Devpost Hub',
        organizer: 'Crypto & Blockchain Club',
        description: 'Design zero-knowledge proofs, DeFi protocols, and decentralized apps on Ethereum & Solana ecosystems.',
        bannerImage: 'https://images.unsplash.com/photo-1639762681485-074b7f938ba0?w=800&q=80',
        rules: [
          'Smart contracts must be deployed on testnet.',
          'Open-source repository link required for submission.',
        ],
        submissionDeadline: DateTime(2026, 8, 16, 20, 0),
      ),

      // 🟡 PENDING 1 (AI Innovation Challenge 2026)
      HackathonRegistrationModel(
        id: 'REG-AI-2026-09',
        hackathonId: 'HACK-AI-2026',
        hackathonTitle: 'AI Innovation Challenge 2026',
        studentId: demoStudentId,
        studentName: 'Alex Johnson',
        department: 'Computer Science & Engineering',
        year: '3rd Year',
        email: 'alex.j@unisphere.edu',
        phone: '+91 98765 43210',
        teamName: 'NeuralCraft',
        teamMembers: ['Alex Johnson (Lead)', 'Harini S', 'Kavin Raj'],
        registrationDate: now.subtract(const Duration(days: 2)),
        startDate: DateTime(2026, 8, 20),
        endDate: DateTime(2026, 8, 25),
        participationStatus: 'Registration Confirmed',
        mode: 'Offline',
        location: 'Main Auditorium, Tech Block Center',
        organizer: 'Department of Computer Science & IEEE',
        description: 'Building multi-agent LLM systems, computer vision tools, and autonomous robotics solutions.',
        bannerImage: 'https://images.unsplash.com/photo-1485827404703-89b55fcc595e?w=800&q=80',
        rules: [
          'Laptops with GPU support recommended.',
          'Mentors will be assigned at venue check-in.',
        ],
        submissionDeadline: DateTime(2026, 8, 25, 17, 0),
      ),

      // 🟡 PENDING 2 (CleanTech & Sustainable Energy Sprint)
      HackathonRegistrationModel(
        id: 'REG-CLEAN-2026-11',
        hackathonId: 'HACK-103',
        hackathonTitle: 'CleanTech & Sustainable Energy Sprint',
        studentId: demoStudentId,
        studentName: 'Alex Johnson',
        department: 'Computer Science & Engineering',
        year: '3rd Year',
        email: 'alex.j@unisphere.edu',
        phone: '+91 98765 43210',
        teamName: 'EcoCoders',
        teamMembers: ['Alex Johnson (Lead)', 'Yogeshwaran P', 'Nandhini M'],
        registrationDate: now.subtract(const Duration(days: 1)),
        startDate: DateTime(2026, 8, 28),
        endDate: DateTime(2026, 8, 30),
        participationStatus: 'Registration Confirmed',
        mode: 'Hybrid',
        location: 'Innovation Lab 302 & Zoom',
        organizer: 'SRM Green Initiative Foundation',
        description: 'Engineered solutions for carbon footprint tracking, smart grid optimization, and renewable energy.',
        bannerImage: 'https://images.unsplash.com/photo-1497435334941-8c899ee9e8e9?w=800&q=80',
        rules: [
          'Working prototype or hardware demonstration required.',
        ],
        submissionDeadline: DateTime(2026, 8, 30, 16, 0),
      ),

      // 🟡 PENDING 3 (Quantum Computing & Algorithms Challenge)
      HackathonRegistrationModel(
        id: 'REG-QUANTUM-2026',
        hackathonId: 'HACK-106',
        hackathonTitle: 'Quantum Computing & Algorithms Challenge',
        studentId: demoStudentId,
        studentName: 'Alex Johnson',
        department: 'Computer Science & Engineering',
        year: '3rd Year',
        email: 'alex.j@unisphere.edu',
        phone: '+91 98765 43210',
        teamName: 'QubitForce',
        teamMembers: ['Alex Johnson (Lead)', 'Manoj Kumar V'],
        registrationDate: now.subtract(const Duration(hours: 12)),
        startDate: DateTime(2026, 9, 5),
        endDate: DateTime(2026, 9, 8),
        participationStatus: 'Registration Confirmed',
        mode: 'Online',
        location: 'Qiskit Hub & Virtual Lab',
        organizer: 'Quantum Science Initiative',
        description: 'Explore quantum cryptography, Qiskit circuit optimization, and hybrid quantum-classical algorithms.',
        bannerImage: 'https://images.unsplash.com/photo-1635070041078-e363dbe005cb?w=800&q=80',
        rules: [
          'Submissions must use Qiskit or Pennylane framework.',
        ],
        submissionDeadline: DateTime(2026, 9, 8, 19, 0),
      ),

      // 🔵 COMPLETED 1 (College HackFest 2026)
      HackathonRegistrationModel(
        id: 'REG-HF-2026-03',
        hackathonId: 'HACK-FEST-2026',
        hackathonTitle: 'College HackFest 2026',
        studentId: demoStudentId,
        studentName: 'Alex Johnson',
        department: 'Computer Science & Engineering',
        year: '3rd Year',
        email: 'alex.j@unisphere.edu',
        phone: '+91 98765 43210',
        teamName: 'ByteBusters',
        teamMembers: ['Alex Johnson (Lead)', 'Monisha R', 'Sanjay K'],
        registrationDate: DateTime(2026, 7, 25),
        startDate: DateTime(2026, 8, 5),
        endDate: DateTime(2026, 8, 7),
        participationStatus: 'Participation Completed',
        mode: 'Offline',
        location: 'CS Block Lab 3',
        organizer: 'UniSphere Tech Council',
        description: 'Internal campus hackathon building campus automation and student utility mobile applications.',
        bannerImage: 'https://images.unsplash.com/photo-1531482615713-2afd69097998?w=800&q=80',
        rules: ['Event concluded on Aug 07, 2026.'],
        projectSubmissionUrl: 'https://github.com/alex-j/unisphere-smart-campus',
        projectSubmissionTitle: 'UniSphere Smart Campus Assistant',
        projectSubmissionNotes: 'Secured 2nd Place in Institutional Category.',
        submittedAt: DateTime(2026, 8, 7, 16, 30),
      ),

      // 🔵 COMPLETED 2 (Cybersecurity CTF Challenge 2026)
      HackathonRegistrationModel(
        id: 'REG-CTF-2026-44',
        hackathonId: 'HACK-104',
        hackathonTitle: 'NextGen Cybersecurity & Threat Hunting CTF',
        studentId: demoStudentId,
        studentName: 'Alex Johnson',
        department: 'Computer Science & Engineering',
        year: '3rd Year',
        email: 'alex.j@unisphere.edu',
        phone: '+91 98765 43210',
        teamName: 'RootHackers',
        teamMembers: ['Alex Johnson (Lead)', 'Arun Prakash G'],
        registrationDate: DateTime(2026, 7, 15),
        startDate: DateTime(2026, 7, 28),
        endDate: DateTime(2026, 7, 30),
        participationStatus: 'Participation Completed',
        mode: 'Offline',
        location: 'Cyber Defense Center, Lab B',
        organizer: 'Center of Cyber Excellence',
        description: 'Capture-the-flag hackathon focusing on vulnerability discovery, zero-day exploitation, and SOC automation.',
        bannerImage: 'https://images.unsplash.com/photo-1550751827-4bd374c3f58b?w=800&q=80',
        rules: ['Event concluded on Jul 30, 2026.'],
        projectSubmissionUrl: 'https://ctf.unisphere.edu/team/roothackers',
        projectSubmissionTitle: 'Automated Log Analyzer & Defacer Shield',
        submittedAt: DateTime(2026, 7, 30, 18, 0),
      ),

      // 🔵 COMPLETED 3 (BioHealth AI Diagnostics Hack)
      HackathonRegistrationModel(
        id: 'REG-BIO-2026-19',
        hackathonId: 'HACK-105',
        hackathonTitle: 'HealthTech AI & Digital Diagnostic Hack',
        studentId: demoStudentId,
        studentName: 'Alex Johnson',
        department: 'Computer Science & Engineering',
        year: '3rd Year',
        email: 'alex.j@unisphere.edu',
        phone: '+91 98765 43210',
        teamName: 'MedAI',
        teamMembers: ['Alex Johnson (Lead)', 'Kavya Dharshini B'],
        registrationDate: DateTime(2026, 7, 10),
        startDate: DateTime(2026, 8, 1),
        endDate: DateTime(2026, 8, 3),
        participationStatus: 'Participation Completed',
        mode: 'Hybrid',
        location: 'BioTech Complex Auditorium',
        organizer: 'Biomedical Engineering & BioAI Lab',
        description: 'Machine learning diagnostic models for early disease detection and remote telemedicine.',
        bannerImage: 'https://images.unsplash.com/photo-1576091160399-112ba8d25d1d?w=800&q=80',
        rules: ['Event concluded on Aug 03, 2026.'],
        projectSubmissionUrl: 'https://github.com/alex-j/retinal-scan-ai',
        projectSubmissionTitle: 'Retinal Disease Screening via Mobile CNN',
        submittedAt: DateTime(2026, 8, 3, 15, 0),
      ),
    ];
  }

  /// Get student-specific registrations
  List<HackathonRegistrationModel> getStudentRegistrations(String? studentId) {
    if (studentId == null || studentId.isEmpty) {
      return state.where((r) => r.studentId == demoStudentId).toList();
    }
    // Match by studentId, email prefix, or demo fallback
    return state.where((r) {
      return r.studentId.toLowerCase() == studentId.toLowerCase() ||
          r.email.toLowerCase() == studentId.toLowerCase() ||
          studentId == 'DEMO-STU' ||
          studentId == 'STU-2026-042' ||
          studentId.contains('saravanapmvofficial') ||
          studentId.contains('student');
    }).toList();
  }

  /// Helper mapping Year + Section to assigned Class Advisor
  static Map<String, String> _getAdvisorForYearAndSection(String year, String section) {
    final y = year.trim();
    final s = section.trim();

    if (y.contains('3rd') && s.contains('B')) {
      return {'id': 'ADV-CSE-3B', 'name': 'Dr. S. Meenakshi'};
    } else if (y.contains('3rd') && s.contains('A')) {
      return {'id': 'ADV-CSE-3A', 'name': 'Prof. Robert Vance'};
    } else if (y.contains('2nd')) {
      return {'id': 'ADV-CSE-2A', 'name': 'Dr. Anita Sharma'};
    } else if (y.contains('4th')) {
      return {'id': 'ADV-CSE-4A', 'name': 'Prof. David Miller'};
    } else {
      return {'id': 'ADV-CSE-1A', 'name': 'Dr. S. Meenakshi'};
    }
  }

  /// Check if logged in student is registered for a specific hackathon
  bool isRegisteredForHackathon(String hackathonId, String? studentId) {
    final list = getStudentRegistrations(studentId);
    return list.any((r) => r.hackathonId == hackathonId);
  }

  /// Register student for a new hackathon with team, external registration ID, year, section, and screenshot proof
  HackathonRegistrationModel registerStudentForHackathon({
    required HackathonModel hackathon,
    required String studentId,
    required String studentName,
    required String department,
    required String year,
    String section = 'Sec B',
    required String email,
    required String phone,
    required String teamName,
    required List<String> teamMembers,
    String externalRegistrationId = 'EXT-REG-8841',
    String registrationScreenshotUrl = 'https://images.unsplash.com/photo-1517694712202-14dd9538aa97?w=800&q=80',
  }) {
    final now = DateTime.now();
    final regId = 'REG-${now.year}-${1000 + (now.millisecondsSinceEpoch % 8999)}';

    // Auto-identify advisor based on Year + Section
    final advisorMap = _getAdvisorForYearAndSection(year, section);

    final initialActivities = [
      HackathonActivityLogger.createActivity(
        hackathonId: hackathon.id,
        teamId: regId,
        studentId: studentId.isEmpty ? demoStudentId : studentId,
        actorId: studentId.isEmpty ? demoStudentId : studentId,
        actorRole: 'student',
        activityType: 'team_created',
        description: 'Team "$teamName" created by Team Leader ${studentName.isEmpty ? "Alex Johnson" : studentName}',
        newStatus: 'Team Created',
      ),
      HackathonActivityLogger.createActivity(
        hackathonId: hackathon.id,
        teamId: regId,
        studentId: studentId.isEmpty ? demoStudentId : studentId,
        actorId: studentId.isEmpty ? demoStudentId : studentId,
        actorRole: 'student',
        activityType: 'screenshot_uploaded',
        description: 'Registration screenshot proof attached (ID: $externalRegistrationId)',
        newStatus: 'Screenshot Uploaded',
      ),
      HackathonActivityLogger.createActivity(
        hackathonId: hackathon.id,
        teamId: regId,
        studentId: studentId.isEmpty ? demoStudentId : studentId,
        actorId: studentId.isEmpty ? demoStudentId : studentId,
        actorRole: 'student',
        activityType: 'details_submitted',
        description: 'Registration details submitted to Class Advisor ${advisorMap['name']}',
        previousStatus: 'Details Incomplete',
        newStatus: 'Submitted to Advisor',
      ),
    ];

    final newRegistration = HackathonRegistrationModel(
      id: regId,
      hackathonId: hackathon.id,
      hackathonTitle: hackathon.title,
      studentId: studentId.isEmpty ? demoStudentId : studentId,
      studentName: studentName.isEmpty ? 'Alex Johnson' : studentName,
      department: department.isEmpty ? 'Computer Science' : department,
      year: year.isEmpty ? '3rd Year' : year,
      section: section.isEmpty ? 'Sec B' : section,
      email: email.isEmpty ? 'alex.j@unisphere.edu' : email,
      phone: phone.isEmpty ? '+91 98765 43210' : phone,
      teamName: teamName,
      teamMembers: [studentName.isEmpty ? 'Alex Johnson (Lead)' : '$studentName (Lead)', ...teamMembers],
      registrationDate: now,
      startDate: hackathon.startDate,
      endDate: hackathon.endDate,
      participationStatus: 'Submitted to Advisor',
      mode: hackathon.mode,
      location: hackathon.location,
      organizer: hackathon.organizer,
      description: hackathon.description,
      bannerImage: hackathon.bannerImage,
      rules: [
        'All team members must check in prior to event kickoff.',
        'Submissions must adhere to safety and ethical guidelines.',
      ],
      submissionDeadline: hackathon.endDate,
      externalRegistrationId: externalRegistrationId,
      registrationScreenshotUrl: registrationScreenshotUrl,
      verificationStatus: 'Pending Verification',
      assignedAdvisorId: advisorMap['id']!,
      assignedAdvisorName: advisorMap['name']!,
      activities: initialActivities,
    );

    // Update state reactively
    state = [newRegistration, ...state];
    return newRegistration;
  }

  /// Advisor verifies student hackathon registration
  void verifyRegistration(String registrationId) {
    state = state.map((reg) {
      if (reg.id == registrationId) {
        final verifyAct = HackathonActivityLogger.createActivity(
          hackathonId: reg.hackathonId,
          teamId: reg.id,
          studentId: reg.studentId,
          actorId: reg.assignedAdvisorId,
          actorRole: 'advisor',
          activityType: 'registration_verified',
          description: 'Class Advisor (${reg.assignedAdvisorName}) verified hackathon team registration',
          previousStatus: reg.verificationStatus,
          newStatus: 'Verified',
        );
        return reg.copyWith(
          verificationStatus: 'Verified',
          participationStatus: 'Verified by Advisor',
          advisorCorrectionNotes: null,
          activities: [...reg.activities, verifyAct],
        );
      }
      return reg;
    }).toList();
  }

  /// Advisor requests correction from student
  void requestCorrection(String registrationId, String notes) {
    state = state.map((reg) {
      if (reg.id == registrationId) {
        final correctionAct = HackathonActivityLogger.createActivity(
          hackathonId: reg.hackathonId,
          teamId: reg.id,
          studentId: reg.studentId,
          actorId: reg.assignedAdvisorId,
          actorRole: 'advisor',
          activityType: 'correction_requested',
          description: 'Class Advisor (${reg.assignedAdvisorName}) requested correction: "$notes"',
          previousStatus: reg.verificationStatus,
          newStatus: 'Correction Required',
        );
        return reg.copyWith(
          verificationStatus: 'Correction Required',
          participationStatus: 'Correction Required by Advisor',
          advisorCorrectionNotes: notes,
          activities: [...reg.activities, correctionAct],
        );
      }
      return reg;
    }).toList();
  }

  /// Student resubmits proof screenshot & details after advisor correction request
  void resubmitRegistration({
    required String registrationId,
    required String screenshotUrl,
    String? externalRegId,
  }) {
    state = state.map((reg) {
      if (reg.id == registrationId) {
        final resubmitAct = HackathonActivityLogger.createActivity(
          hackathonId: reg.hackathonId,
          teamId: reg.id,
          studentId: reg.studentId,
          actorId: reg.studentId,
          actorRole: 'student',
          activityType: 'correction_submitted',
          description: 'Team Leader resubmitted updated registration screenshot proof',
          previousStatus: reg.verificationStatus,
          newStatus: 'Pending Verification',
        );
        return reg.copyWith(
          registrationScreenshotUrl: screenshotUrl,
          externalRegistrationId: externalRegId ?? reg.externalRegistrationId,
          verificationStatus: 'Pending Verification',
          participationStatus: 'Resubmitted to Advisor',
          advisorCorrectionNotes: null,
          activities: [...reg.activities, resubmitAct],
        );
      }
      return reg;
    }).toList();
  }

  /// Get pending & total registrations assigned to an Advisor by Year/Section/ID
  List<HackathonRegistrationModel> getAdvisorRegistrations(String advisorId) {
    return state; // In demo mode return all department registrations for thorough inspection
  }

  /// Submit project for an ongoing hackathon
  void submitProject({
    required String registrationId,
    required String projectUrl,
    required String projectTitle,
    String? notes,
  }) {
    state = state.map((reg) {
      if (reg.id == registrationId) {
        return reg.copyWith(
          projectSubmissionUrl: projectUrl,
          projectSubmissionTitle: projectTitle,
          projectSubmissionNotes: notes,
          submittedAt: DateTime.now(),
          participationStatus: 'Project Submitted',
        );
      }
      return reg;
    }).toList();
  }

  /// Clear registrations for testing empty state
  void clearAllRegistrations() {
    state = [];
  }

  /// Trigger automated reminder evaluation check targeting Team Leaders
  Future<int> runAutomatedRemindersCheck(List<HackathonModel> hackathons) async {
    return await _reminderEngine.evaluateAndSendReminders(
      registrations: state,
      hackathons: hackathons,
    );
  }

  /// Reset default mock data
  void resetToDefault() {
    state = _getInitialMockRegistrations();
  }
}
