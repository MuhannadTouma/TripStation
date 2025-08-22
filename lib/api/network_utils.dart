import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:trip_station/api/api_constants.dart';

/// A utility class for making network requests.
class NetworkUtils {
  /// Makes a POST request to the specified endpoint with an optional language parameter.
  ///
  /// [endpoint]: The API endpoint (e.g., 'auth/login').
  /// [data]: The body of the request as a Map.
  /// [lang]: The language code (e.g., 'en', 'ar') to be sent as a query parameter.
  ///
  /// Returns a Future that resolves to a Map containing the decoded JSON response.
  /// Throws an Exception if the request fails or returns an error.
  static Future<Map<String, dynamic>> post(String endpoint, Map<String, dynamic> data, {String? lang}) async {
    // Build the URI with the language query parameter if provided
    Uri url = Uri.parse('${ApiConstants.baseUrl}/$endpoint');
    if (lang != null) {
      // Add or replace the 'lang' query parameter
      final Map<String, String> queryParams = Map.from(url.queryParameters);
      queryParams['lang'] = lang;
      url = url.replace(queryParameters: queryParams);
    }

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode(data),
    );
    return _handleResponse(response);
  }

  /// Makes a GET request to the specified endpoint with an optional language parameter.
  ///
  /// [endpoint]: The API endpoint (e.g., 'trip/local').
  /// [token]: Optional authentication token to be included in the headers.
  /// [lang]: The language code (e.g., 'en', 'ar') to be sent as a query parameter.
  ///
  /// Returns a Future that resolves to a Map containing the decoded JSON response.
  /// Throws an Exception if the request fails or returns an error.
  static Future<Map<String, dynamic>> get(String endpoint, {String? token, String? lang}) async {
    // Build the URI with the language query parameter if provided
    Uri url = Uri.parse('${ApiConstants.baseUrl}/$endpoint');
    if (lang != null) {
      // Add or replace the 'lang' query parameter
      final Map<String, String> queryParams = Map.from(url.queryParameters);
      queryParams['lang'] = lang;
      url = url.replace(queryParameters: queryParams);
    }

    final headers = <String, String>{'Content-Type': 'application/json'};
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    final response = await http.get(url, headers: headers);
    return _handleResponse(response);
  }

  /// Makes a PUT request to the specified endpoint with an optional language parameter.
  ///
  /// [endpoint]: The API endpoint.
  /// [data]: The body of the request as a Map.
  /// [token]: Optional authentication token.
  /// [lang]: The language code (e.g., 'en', 'ar').
  ///
  /// Returns a Future that resolves to a Map containing the decoded JSON response.
  /// Throws an Exception if the request fails or returns an error.
  static Future<Map<String, dynamic>> put(String endpoint, Map<String, dynamic> data, {String? token, String? lang}) async {
    Uri url = Uri.parse('${ApiConstants.baseUrl}/$endpoint');
    if (lang != null) {
      // Add or replace the 'lang' query parameter
      final Map<String, String> queryParams = Map.from(url.queryParameters);
      queryParams['lang'] = lang;
      url = url.replace(queryParameters: queryParams);
    }

    final headers = <String, String>{'Content-Type': 'application/json'};
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }

    final response = await http.put(
      url,
      headers: headers,
      body: json.encode(data),
    );
    return _handleResponse(response);
  }

  /// Makes a DELETE request to the specified endpoint with an optional language parameter.
  ///
  /// [endpoint]: The API endpoint.
  /// [data]: The body of the request as a Map (optional for DELETE).
  /// [token]: Optional authentication token.
  /// [lang]: The language code (e.g., 'en', 'ar').
  ///
  /// Returns a Future that resolves to a Map containing the decoded JSON response.
  /// Throws an Exception if the request fails or returns an error.
  static Future<Map<String, dynamic>> delete(String endpoint, {Map<String, dynamic>? data, String? token, String? lang}) async {
    Uri url = Uri.parse('${ApiConstants.baseUrl}/$endpoint');
    if (lang != null) {
      // Add or replace the 'lang' query parameter
      final Map<String, String> queryParams = Map.from(url.queryParameters);
      queryParams['lang'] = lang;
      url = url.replace(queryParameters: queryParams);
    }

    final headers = <String, String>{'Content-Type': 'application/json'};
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }

    final response = await http.delete(
      url,
      headers: headers,
      body: data != null ? json.encode(data) : null,
    );
    return _handleResponse(response);
  }


  /// Handles the HTTP response, throwing an exception for non-success status codes.
  static Map<String, dynamic> _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return json.decode(response.body);
    } else {
      final errorBody = json.decode(response.body);
      throw Exception(errorBody['message'] ?? 'Failed to load data with status: ${response.statusCode}');
    }
  }
}
