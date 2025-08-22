// lib/api/services/ad_service.dart (Example)
import '../../models/ad_model.dart'; // Assuming you have an AdModel
import '../utils/send_request.dart';

class AdService {
  Future<List<Ad>> getInternationalAds(String token) async {
    final response = await makeAuthenticatedRequest(
      'trip/ads/international',
      method: 'GET',
      token: token,
    );
    if (response['success'] == true && response['data'] is List) {
      final List<dynamic> adData = response['data'];
      return adData.map((json) => Ad.fromJson(json)).toList();
    } else {
      throw Exception(response['message'] ?? 'Failed to load international ads.');
    }
  }

  Future<List<Ad>> getLocalAds(String token) async {
    final response = await makeAuthenticatedRequest(
      'trip/ads/local',
      method: 'GET',
      token: token,
    );
    if (response['success'] == true && response['data'] is List) {
      final List<dynamic> adData = response['data'];
      return adData.map((json) => Ad.fromJson(json)).toList();
    } else {
      throw Exception(response['message'] ?? 'Failed to load local ads.');
    }
  }
}