import 'package:unisphere/models/hackathon_model.dart';
import 'package:unisphere/services/hackathon_service.dart';

class HackathonRepository {
  final HackathonService _service;

  HackathonRepository(this._service);

  Future<List<HackathonModel>> fetchHackathons({int page = 1, int limit = 10, String? category}) async {
    return await _service.getHackathons(page: page, limit: limit, category: category);
  }

  Future<HackathonModel?> fetchFeaturedHackathon() async {
    return await _service.getFeaturedHackathon();
  }

  Future<HackathonModel> fetchHackathonById(String id) async {
    return await _service.getHackathonById(id);
  }

  Future<Map<String, dynamic>> registerTeam(String hackathonId, Map<String, dynamic> data) async {
    return await _service.registerTeam(hackathonId, data);
  }

  Future<List<Map<String, dynamic>>> fetchUserRegistrations() async {
    return await _service.getUserRegistrations();
  }
}
