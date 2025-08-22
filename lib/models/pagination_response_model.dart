// models/pagination_response_model.dart
import 'package:trip_station/models/activity_model.dart';
import 'package:trip_station/models/pagination_model.dart';

class PaginationResponse {
  final List<ActivityModel> activities;
  final PaginationModel pagination;

  PaginationResponse({
    required this.activities,
    required this.pagination,
  });

  factory PaginationResponse.fromJson(Map<String, dynamic> json) {
    return PaginationResponse(
      activities: (json['data'] as List<dynamic>)
          .map((item) => ActivityModel.fromJson(item as Map<String, dynamic>))
          .toList(),
      pagination: PaginationModel.fromJson(json['pagination'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'data': activities.map((e) => e.toJson()).toList(),
      'pagination': pagination.toJson(),
    };
  }
}
