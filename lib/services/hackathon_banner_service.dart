import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:clg_application/models/hackathon_banner_model.dart';

abstract class HackathonBannerService {
  Future<HackathonBannerModel?> getHackathonBanner();
}

class ApiHackathonBannerService implements HackathonBannerService {
  final String baseUrl;
  final http.Client client;

  ApiHackathonBannerService({
    String? baseUrl,
    http.Client? client,
  })  : baseUrl = baseUrl ?? const String.fromEnvironment('HACKATHON_API_URL', defaultValue: 'https://api.unisphere.edu/api'),
        client = client ?? http.Client();

  @override
  Future<HackathonBannerModel?> getHackathonBanner() async {
    final uri = Uri.parse('$baseUrl/hackathon-banner');

    try {
      final response = await client.get(uri).timeout(const Duration(seconds: 4));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data != null) {
          final bannerMap = data is Map<String, dynamic> && data.containsKey('data')
              ? data['data'] as Map<String, dynamic>
              : data as Map<String, dynamic>;
          return HackathonBannerModel.fromMap(bannerMap);
        }
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[HackathonBannerService] Backend endpoint $uri unreachable. Using active default banner.');
      }
    }

    // Default active hackathon registration poster payload matching backend format specification
    await Future.delayed(const Duration(milliseconds: 500));
    return HackathonBannerModel(
      id: 1,
      title: 'Smart India Hackathon 2026',
      posterImage: 'https://images.unsplash.com/photo-1526374965328-7f61d4dc18c5?w=1200&q=80',
      registrationLink: 'https://sih.gov.in',
      uploadDate: DateTime(2026, 8, 1),
      expiryDate: DateTime(2026, 8, 30),
      isActive: true,
    );
  }
}
