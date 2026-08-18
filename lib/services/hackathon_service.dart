import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:unisphere/models/hackathon_model.dart';
import 'package:unisphere/models/hackathon_registration_model.dart';
import 'package:unisphere/models/hackathon_team_model.dart';


abstract class HackathonService {
  Future<List<HackathonModel>> getHackathons({int page = 1, int limit = 10, String? category});
  Future<HackathonModel?> getFeaturedHackathon();
  Future<HackathonModel> getHackathonById(String id);
  Future<Map<String, dynamic>> registerTeam(String hackathonId, Map<String, dynamic> registrationData);
  Future<List<Map<String, dynamic>>> getUserRegistrations();
  Future<void> createOrUpdateTeam(String hackathonId, HackathonTeamModel team);
  Future<void> reviewRegistrationByHod(String registrationId, String reviewStatus);
}

class ApiHackathonService implements HackathonService {
  final String baseUrl;
  final http.Client client;
  final FirebaseFirestore? _firestore;

  ApiHackathonService({
    String? baseUrl,
    http.Client? client,
    FirebaseFirestore? firestore,
  })  : baseUrl = baseUrl ?? const String.fromEnvironment('HACKATHON_API_URL', defaultValue: 'https://api.unisphere.edu/api'),
        client = client ?? http.Client(),
        _firestore = firestore ?? _tryGetFirestore();

  static FirebaseFirestore? _tryGetFirestore() {
    try {
      return FirebaseFirestore.instance;
    } catch (_) {
      return null;
    }
  }

  // Simulated fallback dataset payload
  final List<HackathonModel> _mockDb = [
    HackathonModel(
      id: 'HACK-101',
      title: 'UniHack 2026: GenAI & Autonomous Systems',
      description: '36-hour non-stop hackathon building autonomous AI agents, LLM pipelines, and intelligent multi-agent workflows for enterprise automation.',
      category: 'AI & Robotics',
      organizer: 'Department of Computer Science & IEEE',
      mode: 'Offline',
      bannerImage: 'https://images.unsplash.com/photo-1526374965328-7f61d4dc18c5?w=800&q=80',
      startDate: DateTime.now().add(const Duration(days: 14)),
      endDate: DateTime.now().add(const Duration(days: 16)),
      registrationOpen: true,
      registrationDeadline: DateTime.now().add(const Duration(days: 10)),
      prizePool: '₹2,50,000',
      registeredTeams: 142,
      maxTeams: 200,
      maxTeamMembers: 6,
      teamSize: 4,
      status: 'upcoming',
      userRegistrationStatus: 'registered',
      registrationId: 'REG-2026-8841',
      location: 'Main Auditorium, Tech Block Center',
      tags: ['GenAI', 'Autonomous Agents', 'Python', 'PyTorch'],
      isFeatured: true,
    ),
    HackathonModel(
      id: 'HACK-102',
      title: 'Global Web3 & Smart Contracts Challenge',
      description: 'Design zero-knowledge proofs, DeFi protocols, and decentralized apps on Ethereum & Solana ecosystems with global industry mentors.',
      category: 'Blockchain',
      organizer: 'Crypto & Blockchain Club',
      mode: 'Online',
      bannerImage: 'https://images.unsplash.com/photo-1639762681485-074b7f938ba0?w=800&q=80',
      startDate: DateTime.now().add(const Duration(days: 30)),
      endDate: DateTime.now().add(const Duration(days: 32)),
      registrationOpen: true,
      registrationDeadline: DateTime.now().add(const Duration(days: 25)),
      prizePool: '\$5,000 USDT',
      registeredTeams: 88,
      maxTeams: 150,
      maxTeamMembers: 6,
      teamSize: 3,
      status: 'upcoming',
      userRegistrationStatus: 'not_registered',
      location: 'Virtual / Discord & Devpost',
      tags: ['Solidity', 'Rust', 'Web3', 'DeFi'],
      isFeatured: false,
    ),
    HackathonModel(
      id: 'HACK-103',
      title: 'CleanTech & Sustainable Energy Sprint',
      description: 'Engineered solutions for carbon footprint tracking, smart grid optimization, and renewable micro-grid energy management.',
      category: 'Sustainability',
      organizer: 'SRM Green Initiative Foundation',
      mode: 'Hybrid',
      bannerImage: 'https://images.unsplash.com/photo-1497435334941-8c899ee9e8e9?w=800&q=80',
      startDate: DateTime.now().add(const Duration(days: 45)),
      endDate: DateTime.now().add(const Duration(days: 46)),
      registrationOpen: true,
      registrationDeadline: DateTime.now().add(const Duration(days: 40)),
      prizePool: '₹1,00,000',
      registeredTeams: 64,
      maxTeams: 100,
      maxTeamMembers: 6,
      teamSize: 4,
      status: 'upcoming',
      userRegistrationStatus: 'not_registered',
      location: 'Innovation Lab 302 & Zoom',
      tags: ['CleanTech', 'IoT', 'ESG', 'Green Energy'],
      isFeatured: false,
    ),
  ];

  @override
  Future<List<HackathonModel>> getHackathons({int page = 1, int limit = 10, String? category}) async {
    final firestore = _firestore;
    if (firestore != null) {
      try {
        final snap = await firestore.collection('hackathons').get();
        if (snap.docs.isNotEmpty) {
          var list = snap.docs.map((d) => HackathonModel.fromMap(d.data(), d.id)).toList();
          if (category != null && category != 'All') {
            list = list.where((h) => h.category.toLowerCase() == category.toLowerCase()).toList();
          }
          return list;
        }
      } catch (e) {
        debugPrint('Firestore hackathons query notice: $e');
      }
    }

    var filtered = _mockDb;
    if (category != null && category != 'All') {
      filtered = filtered.where((h) => h.category.toLowerCase() == category.toLowerCase()).toList();
    }
    return filtered;
  }

  @override
  Future<HackathonModel?> getFeaturedHackathon() async {
    final firestore = _firestore;
    if (firestore != null) {
      try {
        final snap = await firestore.collection('hackathons').where('isFeatured', isEqualTo: true).limit(1).get();
        if (snap.docs.isNotEmpty) {
          return HackathonModel.fromMap(snap.docs.first.data(), snap.docs.first.id);
        }
      } catch (_) {}
    }
    return _mockDb.firstWhere((h) => h.isFeatured, orElse: () => _mockDb.first);
  }

  @override
  Future<HackathonModel> getHackathonById(String id) async {
    final firestore = _firestore;
    if (firestore != null) {
      try {
        final doc = await firestore.collection('hackathons').doc(id).get();
        if (doc.exists && doc.data() != null) {
          return HackathonModel.fromMap(doc.data()!, doc.id);
        }
      } catch (_) {}
    }
    return _mockDb.firstWhere((h) => h.id == id, orElse: () => _mockDb.first);
  }

  /// Create/Update team with transaction-enforced maximum of 6 team members
  @override
  Future<void> createOrUpdateTeam(String hackathonId, HackathonTeamModel team) async {
    final firestore = _firestore;
    if (firestore == null) return;

    if (team.memberIds.length > 6) {
      throw Exception('Maximum 6 team members allowed per hackathon team.');
    }

    final teamRef = firestore.collection('hackathons').doc(hackathonId).collection('teams').doc(team.teamId);

    await firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(teamRef);
      if (snapshot.exists) {
        final currentMembers = List<String>.from(snapshot.data()?['memberIds'] ?? []);
        if (currentMembers.length > 6) {
          throw Exception('Team already reached maximum allowed limit of 6 members.');
        }
      }

      final teamData = team.toMap();
      teamData['updatedAt'] = FieldValue.serverTimestamp();
      transaction.set(teamRef, teamData, SetOptions(merge: true));
    });
  }

  @override
  Future<Map<String, dynamic>> registerTeam(String hackathonId, Map<String, dynamic> registrationData) async {
    final firestore = _firestore;
    final teamMembers = List<String>.from(registrationData['teamMembers'] ?? registrationData['memberIds'] ?? []);

    if (teamMembers.length > 6) {
      throw Exception('Cannot register team: Maximum 6 team members permitted.');
    }

    final regId = 'REG-${DateTime.now().year}-${1000 + (DateTime.now().millisecondsSinceEpoch % 8999)}';
    final teamId = registrationData['teamId']?.toString() ?? 'TEAM-$regId';
    final leaderId = registrationData['leaderId']?.toString() ?? registrationData['studentId']?.toString() ?? '';

    if (firestore != null) {
      try {
        final regModel = HackathonRegistrationModel(
          id: regId,
          hackathonId: hackathonId,
          teamId: teamId,
          leaderId: leaderId,
          hackathonTitle: registrationData['hackathonTitle']?.toString() ?? registrationData['title']?.toString() ?? 'Hackathon Event',
          studentId: leaderId,
          studentName: registrationData['studentName']?.toString() ?? 'Team Leader',
          department: registrationData['department']?.toString() ?? 'Computer Science',
          year: registrationData['year']?.toString() ?? '3rd Year',
          email: registrationData['email']?.toString() ?? 'leader@unisphere.edu',
          phone: registrationData['phone']?.toString() ?? '',
          teamName: registrationData['teamName']?.toString() ?? 'Team Alpha',
          teamMembers: teamMembers,
          registrationDate: DateTime.now(),
          startDate: DateTime.now().add(const Duration(days: 7)),
          endDate: DateTime.now().add(const Duration(days: 9)),
          participationStatus: 'Registration Confirmed',
          registrationCompleted: true,
          externalRegistrationStatus: 'completed',
          hodReviewStatus: 'pending',
          mode: registrationData['mode']?.toString() ?? 'Online',
          location: registrationData['location']?.toString() ?? 'Online',
          organizer: registrationData['organizer']?.toString() ?? 'UniSphere Innovation Cell',
        );

        await firestore.collection('hackathonRegistrations').doc(regId).set(regModel.toMap(), SetOptions(merge: true));

        // Create team record under hackathons/{hackathonId}/teams/{teamId}
        final teamModel = HackathonTeamModel(
          teamId: teamId,
          hackathonId: hackathonId,
          teamName: registrationData['teamName']?.toString() ?? 'Team Alpha',
          leaderId: leaderId,
          memberIds: teamMembers,
          registrationStatus: 'registered',
          registrationCompleted: true,
          hodReviewStatus: 'pending',
        );
        await createOrUpdateTeam(hackathonId, teamModel);
      } catch (e) {
        debugPrint('Firestore registerTeam notice: $e');
      }
    }

    return {
      'status': 'success',
      'message': 'Successfully registered team for Hackathon',
      'registrationId': regId,
      'teamName': registrationData['teamName'] ?? 'Team Alpha',
    };
  }

  @override
  Future<void> reviewRegistrationByHod(String registrationId, String reviewStatus) async {
    final firestore = _firestore;
    if (firestore == null || registrationId.isEmpty) return;
    try {
      await firestore.collection('hackathonRegistrations').doc(registrationId).update({
        'hodReviewStatus': reviewStatus,
        'hod_review_status': reviewStatus,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('HackathonService reviewRegistrationByHod error: $e');
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getUserRegistrations() async {
    final firestore = _firestore;
    if (firestore != null) {
      try {
        final snap = await firestore.collection('hackathonRegistrations').get();
        if (snap.docs.isNotEmpty) {
          return snap.docs.map((d) => d.data()).toList();
        }
      } catch (_) {}
    }
    return [
      {
        'registrationId': 'REG-2026-8841',
        'hackathonId': 'HACK-101',
        'hackathonTitle': 'UniHack 2026: GenAI & Autonomous Systems',
        'status': 'confirmed',
        'teamName': 'CodeCatalysts',
        'teamMembers': ['Alex Johnson (Leader)', 'Sarah Connor', 'David Kim'],
      }
    ];
  }
}

