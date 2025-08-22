// api/services/activity_service.dart
import 'package:trip_station/api/services/auth_service.dart';
import 'package:trip_station/models/activity_model.dart';
import 'package:trip_station/models/pagination_response_model.dart';

import '../utils/send_request.dart'; // Import PaginationResponse

/// Service class for handling activity-related API calls.
class ActivityService {
  final AuthService _authService; // Dependency on AuthService for making authenticated requests

  ActivityService(this._authService);

  /// Fetches a list of favorite activities for the authenticated user with pagination.
  /// Assumes your backend has an endpoint to get user-specific favorites.
  ///
  /// [token]: The authentication token of the user.
  /// [page]: The page number to fetch.
  /// [limit]: The number of items per page.
  Future<PaginationResponse> getFavoriteActivities(String token, {int page = 1, int limit = 10}) async {
    try {
      // Assuming your backend has an endpoint like 'activities/favorites' that accepts page and limit
      final response = await makeAuthenticatedRequest(
        'favorite?page=$page&limit=$limit', // Add pagination parameters to the query
        method: 'GET',
        isPaginated: true,
        token: token,
      );

      if (response['success'] == true && response['data'] != null) {
        // The 'data' field in the API response contains both 'data' (list of activities) and 'pagination'
        return PaginationResponse.fromJson(response['data'] as Map<String, dynamic>);
      } else {
        throw Exception(response['message'] ?? 'Failed to load favorite activities.');
      }
    } catch (e) {
      print('Error fetching favorite activities: $e');
      rethrow;
    }
  }

  /// Toggles the favorite status of an activity on the backend.
  /// The backend should receive userId and tripId in the body and return the updated activity or a success message.
  ///
  /// [activityId]: The ID of the activity (which is the tripId for the backend).
  /// [userId]: The ID of the authenticated user.
  /// [token]: The authentication token.
  /// [isFavorite]: True to add to favorites (POST), false to remove (DELETE).
  Future<bool> toggleFavoriteStatus(String activityId, String userId, String token, bool isFavorite) async {
    try {
      // The endpoint is now '/favorite' for both add and remove, with the method determining the action.
      // The `lang` parameter will be automatically appended by _authService.makeAuthenticatedRequest.
      final String endpoint = 'favorite';

      // The body now contains userId and tripId as specified.
      final Map<String, dynamic> requestBody = {
        "userId": userId,
        "tripId": activityId,
      };

      final response = await makeAuthenticatedRequest(
        endpoint,
        method: isFavorite ? 'POST' : 'DELETE', // Use POST to add, DELETE to remove
        token: token,
        body: requestBody, // Pass the new request body
      );
      if (response['success'] == true) {
        return true;
      } else {
        throw Exception(response['message'] ?? 'Failed to toggle favorite status.');
      }
    } catch (e) {
      print('Error toggling favorite status: $e');
      rethrow;
    }
  }

  /// Fetches a list of all activities for a specific country.
  Future<List<ActivityModel>> getActivitiesByCountry({
    required String countryId,
    required String token,
  }) async {
    // Endpoint is simpler now, no pagination.
    final endpoint = 'trip/country/$countryId';

    final response = await makeAuthenticatedRequest(
      endpoint,
      method: 'GET',
      token: token,
    );

    if (response['success'] == true && response['data'] is List) {
      // The 'data' field is now a direct list of activities.
      final List<dynamic> tripsData = response['data'];
      return tripsData
          .map((json) => ActivityModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } else {
      throw Exception(response['message'] ?? 'Failed to load activities.');
    }
  }

  /// Fetches the full details for a single activity/trip.
  Future<ActivityModel> getActivityDetails({
    required String activityId,
    required String token,
  }) async {
    final endpoint = 'trip/$activityId';

    final response = await makeAuthenticatedRequest(
      endpoint,
      method: 'GET',
      token: token,
    );

    if (response['success'] == true && response['data'] != null) {
      // The 'data' field contains the single activity object.
      return ActivityModel.fromJson(response['data'] as Map<String, dynamic>);
    } else {
      throw Exception(response['message'] ?? 'Failed to load activity details.');
    }
  }

  /// Fetches a filtered list of activities from the backend using a POST request.
  Future<List<ActivityModel>> filterActivities({
    required String token,
    required String countryId,
    double? minPrice,
    double? maxPrice,
    int? rating,
    String? location,
  }) async {
    const endpoint = 'trip/filter';

    // Build the request body, only including non-null or meaningful values.
    final Map<String, dynamic> body = {
      'countryId': countryId, // Scope the filter to the current country
    };
    if (minPrice != null) body['minPrice'] = minPrice;
    if (maxPrice != null) body['maxPrice'] = maxPrice;
    // Only include the rating if it's greater than 0.
    if (rating != null && rating > 0) body['rating'] = rating;
    // Only include the location if it's not empty.
    if (location != null && location.isNotEmpty) body['location'] = location;
    print(body);

    final response = await makeAuthenticatedRequest(
      endpoint,
      method: 'POST', // Use POST as required by the API
      token: token,
      body: body,
    );
    if (response['success'] == true && response['data'] is List) {
      final List<dynamic> tripsData = response['data'];
      return tripsData
          .map((json) => ActivityModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } else {
      throw Exception(response['message'] ?? 'Failed to filter activities.');
    }
  }
}
