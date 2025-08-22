import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../main.dart';
import '../api_constants.dart';
import 'package:http_parser/http_parser.dart'; // Required for MediaType

String _getCurrentLang() {
  return localeNotifier.locale.languageCode.toLowerCase();
}

Future<Map<String, dynamic>> sendApiRequest(
    String endpoint,
    {
      bool isPaginated = false,
      String method = 'POST',
      Map<String, dynamic>? body,
      File? imageFile,
      String? token,
      Map<String, String>? additionalHeaders,
    }) async {
  final String currentLang = _getCurrentLang();
  // The lang parameter is included in the URI for all requests
  final api =  '${ApiConstants.baseUrl}/$endpoint${isPaginated ? '&': '?'}lang=$currentLang';
  print(api);
  final Uri uri = Uri.parse(api);
  http.Response response;

  // Prepare headers for JSON requests and general authentication
  Map<String, String> headers = {
    'Content-Type': 'application/json',
    'X-Lang': currentLang, // Adding the custom language header
    if (token != null) 'Authorization': 'Bearer $token',
    if (additionalHeaders != null) ...additionalHeaders,
  };

  try {
    if (imageFile != null) {
      // Handle multipart request for image upload
      var request = http.MultipartRequest(method, uri);

      // Add headers for multipart request (Authorization and custom language header are crucial here)
      request.headers.addAll({
        'X-Lang': currentLang, // Adding the custom language header for multipart
        if (token != null) 'Authorization': 'Bearer $token',
        if (additionalHeaders != null) ...additionalHeaders,
      });

      // Add fields from the body
      if (body != null) {
        body.forEach((key, value) {
          request.fields[key] = value.toString();
        });
      }

      // Add the image file
      request.files.add(await http.MultipartFile.fromPath(
        'profileImage', // This must match the field name expected by your backend
        imageFile.path,
        contentType: MediaType('image', 'jpeg'), // Adjust content type as needed
      ));

      var streamedResponse = await request.send();
      response = await http.Response.fromStream(streamedResponse);
    } else {
      // Handle regular JSON request
      switch (method) {
        case 'POST':
          response = await http.post(uri, headers: headers, body: json.encode(body));
          // print(response.body);
          break;
        case 'GET':
          response = await http.get(uri, headers: headers);
          break;
        case 'PUT':
          response = await http.put(uri, headers: headers, body: json.encode(body));
          break;
        case 'DELETE':
          response = await http.delete(uri, headers: headers, body: json.encode(body));
          break;
        default:
          throw Exception('Unsupported HTTP method: $method');
      }
    }

    // Check for success status codes before decoding
    if (response.statusCode < 200 || response.statusCode >= 300) {
      final Map<String, dynamic> errorData = json.decode(response.body);
      throw Exception(errorData['message'] ?? 'Request failed with status: ${response.statusCode}');
    }

    final Map<String, dynamic> responseData = json.decode(response.body);
    // print(responseData);
    return responseData;
  } on SocketException {
    throw Exception('No Internet connection. Please check your network.');
  } on FormatException {
    throw Exception('Bad response format from server.');
  } on http.ClientException catch (e) {
    throw Exception('Network client error: ${e.message}');
  } catch (e) {
    throw Exception('An unexpected error occurred: $e');
  }
}


/// Public method for other services to make authenticated API requests.
/// This is now a direct pass-through to the centralized `sendApiRequest` function.
Future<Map<String, dynamic>> makeAuthenticatedRequest(
    String endpoint, {
      bool isPaginated = false,
      String method = 'GET',
      Map<String, dynamic>? body,
      File? imageFile,
      required String token,
      Map<String, String>? additionalHeaders,
    }) async {
  return sendApiRequest(
    endpoint,
    isPaginated: isPaginated,
    method: method,
    body: body,
    imageFile: imageFile,
    token: token,
    additionalHeaders: additionalHeaders,
  );
}