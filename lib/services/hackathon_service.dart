import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:unisphere/models/hackathon_model.dart';

abstract class HackathonService {
  Future<List<HackathonModel>> getHackathons({int page = 1, int limit = 10, String? category});
  Future<HackathonModel?> getFeaturedHackathon();
  Future<HackathonModel> getHackathonById(String id);
  Future<Map<String, dynamic>> registerTeam(String hackathonId, Map<String, dynamic> registrationData);
  Future<List<Map<String, dynamic>>> getUserRegistrations();
}

class ApiHackathonService implements HackathonService {
  final String baseUrl;
  final http.Client client;

  ApiHackathonService({
    String? baseUrl,
    http.Client? client,
  })  : baseUrl = baseUrl ?? const String.fromEnvironment('HACKATHON_API_URL', defaultValue: 'https://api.unisphere.edu/api'),
        client = client ?? http.Client();

  // Simulated backend database store for offline & development fallback execution
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
      teamSize: 4,
      status: 'upcoming',
      userRegistrationStatus: 'not_registered',
      location: 'Innovation Lab 302 & Zoom',
      tags: ['CleanTech', 'IoT', 'ESG', 'Green Energy'],
      isFeatured: false,
    ),
    HackathonModel(
      id: 'HACK-104',
      title: 'NextGen Cybersecurity & Threat Hunting',
      description: 'Capture-the-flag (CTF) hackathon focusing on vulnerability discovery, zero-day exploitation prevention, and SOC automation.',
      category: 'Cybersecurity',
      organizer: 'Center of Cyber Excellence',
      mode: 'Offline',
      bannerImage: 'https://images.unsplash.com/photo-1550751827-4bd374c3f58b?w=800&q=80',
      startDate: DateTime.now().add(const Duration(days: 60)),
      endDate: DateTime.now().add(const Duration(days: 61)),
      registrationOpen: false,
      registrationDeadline: DateTime.now().subtract(const Duration(days: 2)),
      prizePool: '₹1,50,000',
      registeredTeams: 100,
      maxTeams: 100,
      teamSize: 2,
      status: 'upcoming',
      userRegistrationStatus: 'not_registered',
      location: 'Cyber Defense Center, Lab B',
      tags: ['CTF', 'Pentesting', 'SOC', 'Network Security'],
      isFeatured: false,
    ),
    HackathonModel(
      id: 'HACK-105',
      title: 'HealthTech AI & Digital Diagnostic Hack',
      description: 'Building machine learning diagnostic models for early disease detection, EHR interoperability, and remote telemedicine devices.',
      category: 'Healthcare',
      organizer: 'Biomedical Engineering & BioAI Lab',
      mode: 'Hybrid',
      bannerImage: 'https://images.unsplash.com/photo-1576091160399-112ba8d25d1d?w=800&q=80',
      startDate: DateTime.now().add(const Duration(days: 75)),
      endDate: DateTime.now().add(const Duration(days: 77)),
      registrationOpen: true,
      registrationDeadline: DateTime.now().add(const Duration(days: 70)),
      prizePool: '₹2,00,000',
      registeredTeams: 42,
      maxTeams: 120,
      teamSize: 4,
      status: 'upcoming',
      userRegistrationStatus: 'not_registered',
      location: 'BioTech Complex Auditorium',
      tags: ['HealthTech', 'Medical AI', 'Computer Vision', 'FHIR'],
      isFeatured: false,
    ),
    HackathonModel(
      id: 'HACK-106',
      title: 'Quantum Computing & Algorithms Challenge',
      description: 'Explore quantum cryptography, Qiskit circuit optimization, and hybrid quantum-classical machine learning algorithms.',
      category: 'Quantum AI',
      organizer: 'Quantum Science Initiative',
      mode: 'Online',
      bannerImage: 'https://images.unsplash.com/photo-1635070041078-e363dbe005cb?w=800&q=80',
      startDate: DateTime.now().add(const Duration(days: 90)),
      endDate: DateTime.now().add(const Duration(days: 92)),
      registrationOpen: true,
      registrationDeadline: DateTime.now().add(const Duration(days: 85)),
      prizePool: '₹3,00,000',
      registeredTeams: 35,
      maxTeams: 80,
      teamSize: 3,
      status: 'upcoming',
      userRegistrationStatus: 'not_registered',
      location: 'Virtual / Qiskit Hub',
      tags: ['Quantum', 'Qiskit', 'Linear Algebra', 'Physics'],
      isFeatured: false,
    ),
    HackathonModel(
      id: 'HACK-107',
      title: 'FinTech & Algorithmic Trading Sprint',
      description: 'Develop low-latency high-frequency trading bots, risk analysis dashboards, and automated fraud prevention engines.',
      category: 'FinTech',
      organizer: 'School of Finance & Quantitative Analytics',
      mode: 'Offline',
      bannerImage: 'https://images.unsplash.com/photo-1611974789855-9c2a0a7236a3?w=800&q=80',
      startDate: DateTime.now().add(const Duration(days: 100)),
      endDate: DateTime.now().add(const Duration(days: 102)),
      registrationOpen: true,
      registrationDeadline: DateTime.now().add(const Duration(days: 95)),
      prizePool: '₹1,80,000',
      registeredTeams: 72,
      maxTeams: 120,
      teamSize: 4,
      status: 'upcoming',
      userRegistrationStatus: 'not_registered',
      location: 'Finance Trading Floor Lab',
      tags: ['FinTech', 'Algo Trading', 'Python', 'WebSockets'],
      isFeatured: false,
    ),
    HackathonModel(
      id: 'HACK-108',
      title: 'AR/VR & Spatial Computing Hackathon',
      description: 'Build immersive visionOS, Unity 3D, and WebXR applications for surgical training, remote collaboration, and metaverse education.',
      category: 'AR / VR',
      organizer: 'Spatial Media & GameDev Society',
      mode: 'Hybrid',
      bannerImage: 'https://images.unsplash.com/photo-1593508512255-86ab42a8e620?w=800&q=80',
      startDate: DateTime.now().add(const Duration(days: 115)),
      endDate: DateTime.now().add(const Duration(days: 117)),
      registrationOpen: true,
      registrationDeadline: DateTime.now().add(const Duration(days: 110)),
      prizePool: '₹2,20,000',
      registeredTeams: 50,
      maxTeams: 100,
      teamSize: 4,
      status: 'upcoming',
      userRegistrationStatus: 'not_registered',
      location: 'VR Innovation Studio 4',
      tags: ['Unity', 'Unreal', 'WebXR', 'VisionOS'],
      isFeatured: false,
    ),
  ];

  @override
  Future<List<HackathonModel>> getHackathons({int page = 1, int limit = 10, String? category}) async {
    final uri = Uri.parse('$baseUrl/hackathons').replace(queryParameters: {
      'page': page.toString(),
      'limit': limit.toString(),
      if (category != null && category != 'All') 'category': category,
    });

    try {
      final response = await client.get(uri).timeout(const Duration(seconds: 3));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body)['data'] ?? [];
        return data.map((json) => HackathonModel.fromMap(json)).toList();
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[HackathonService] Remote endpoint ($uri) unverified/offline. Falling back to local dataset payload.');
      }
    }

    // Local pagination simulation
    await Future.delayed(const Duration(milliseconds: 400));
    var filtered = _mockDb;
    if (category != null && category != 'All') {
      filtered = filtered.where((h) => h.category.toLowerCase() == category.toLowerCase()).toList();
    }
    final startIndex = (page - 1) * limit;
    if (startIndex >= filtered.length) return [];
    final endIndex = (startIndex + limit) > filtered.length ? filtered.length : (startIndex + limit);
    return filtered.sublist(startIndex, endIndex);
  }

  @override
  Future<HackathonModel?> getFeaturedHackathon() async {
    final uri = Uri.parse('$baseUrl/hackathons/featured');
    try {
      final response = await client.get(uri).timeout(const Duration(seconds: 3));
      if (response.statusCode == 200) {
        final data = json.decode(response.body)['data'];
        if (data != null) return HackathonModel.fromMap(data);
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[HackathonService] Remote featured endpoint ($uri) offline. Returning local featured event.');
      }
    }

    await Future.delayed(const Duration(milliseconds: 300));
    try {
      return _mockDb.firstWhere((h) => h.isFeatured);
    } catch (_) {
      return _mockDb.isNotEmpty ? _mockDb.first : null;
    }
  }

  @override
  Future<HackathonModel> getHackathonById(String id) async {
    final uri = Uri.parse('$baseUrl/hackathons/$id');
    try {
      final response = await client.get(uri).timeout(const Duration(seconds: 3));
      if (response.statusCode == 200) {
        final data = json.decode(response.body)['data'];
        return HackathonModel.fromMap(data);
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[HackathonService] Remote hackathon detail ($uri) offline. Searching local store.');
      }
    }

    await Future.delayed(const Duration(milliseconds: 200));
    final found = _mockDb.firstWhere(
      (h) => h.id == id,
      orElse: () => throw Exception('Hackathon with ID $id not found'),
    );
    return found;
  }

  @override
  Future<Map<String, dynamic>> registerTeam(String hackathonId, Map<String, dynamic> registrationData) async {
    final uri = Uri.parse('$baseUrl/hackathons/$hackathonId/register');
    try {
      final response = await client
          .post(
            uri,
            headers: {'Content-Type': 'application/json'},
            body: json.encode(registrationData),
          )
          .timeout(const Duration(seconds: 3));
      if (response.statusCode == 200 || response.statusCode == 201) {
        return json.decode(response.body);
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[HackathonService] Remote registration ($uri) offline. Updating local state.');
      }
    }

    await Future.delayed(const Duration(milliseconds: 500));
    final index = _mockDb.indexWhere((h) => h.id == hackathonId);
    if (index != -1) {
      final existing = _mockDb[index];
      final regId = 'REG-${DateTime.now().year}-${1000 + (DateTime.now().millisecondsSinceEpoch % 8999)}';
      _mockDb[index] = existing.copyWith(
        userRegistrationStatus: 'registered',
        registrationId: regId,
        registeredTeams: existing.registeredTeams + 1,
      );
      return {
        'status': 'success',
        'message': 'Successfully registered team for ${existing.title}',
        'registrationId': regId,
        'teamName': registrationData['teamName'] ?? 'Team Alpha',
      };
    }
    throw Exception('Failed to register for hackathon ID $hackathonId');
  }

  @override
  Future<List<Map<String, dynamic>>> getUserRegistrations() async {
    final uri = Uri.parse('$baseUrl/users/me/registrations');
    try {
      final response = await client.get(uri).timeout(const Duration(seconds: 3));
      if (response.statusCode == 200) {
        final List<dynamic> list = json.decode(response.body)['data'] ?? [];
        return list.cast<Map<String, dynamic>>();
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[HackathonService] Remote user registrations ($uri) offline. Reading local registrations.');
      }
    }

    await Future.delayed(const Duration(milliseconds: 300));
    final registered = _mockDb.where((h) => h.isRegistered).toList();
    return registered
        .map((h) => {
              'registrationId': h.registrationId ?? 'REG-DEFAULT',
              'hackathonId': h.id,
              'hackathonTitle': h.title,
              'status': 'confirmed',
              'registeredAt': DateTime.now().subtract(const Duration(days: 3)).toIso8601String(),
              'teamName': 'CodeCatalysts',
              'teamMembers': [
                {'name': 'Alex Johnson', 'role': 'Team Leader', 'email': 'alex.j@unisphere.edu'},
                {'name': 'Sarah Connor', 'role': 'Frontend Developer', 'email': 'sarah.c@unisphere.edu'},
                {'name': 'David Kim', 'role': 'AI/ML Engineer', 'email': 'david.k@unisphere.edu'},
              ]
            })
        .toList();
  }
}
