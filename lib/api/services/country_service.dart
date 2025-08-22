// lib/api/services/country_service.dart

import '../../models/country_model.dart';
import '../utils/send_request.dart';

class CountryService {
  /// Fetches a list of international countries.
  Future<List<Country>> getInternationalCountries(String token) async {
    final response = await makeAuthenticatedRequest(
      'countries/international',
      method: 'GET',
      token: token,
    );

    if (response['success'] == true && response['data'] is List) {
      final List<dynamic> countryData = response['data'];
      return countryData.map((json) => Country.fromJson(json)).toList();
    } else {
      throw Exception(response['message'] ?? 'Failed to load international countries.');
    }
  }

  /// Fetches a list of local countries.
  Future<List<Country>> getLocalCountries(String token) async {
    // Assuming the endpoint for local countries is 'countries/local'
    final response = await makeAuthenticatedRequest(
      'countries/local',
      method: 'GET',
      token: token,
    );

    if (response['success'] == true && response['data'] is List) {
      final List<dynamic> countryData = response['data'];
      return countryData.map((json) => Country.fromJson(json)).toList();
    } else {
      throw Exception(response['message'] ?? 'Failed to load local countries.');
    }
  }
}