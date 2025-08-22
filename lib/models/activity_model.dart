// lib/models/activity_model.dart
import 'dart:core';

/// A model for the company's contact information.
class Contact {
  final String? whatsapp;
  final String? facebook;
  final String? website;
  final String? instagram;

  Contact({
    this.whatsapp,
    this.facebook,
    this.website,
    this.instagram,
  });

  factory Contact.fromJson(Map<String, dynamic> json) {
    return Contact(
      whatsapp: json['whatsapp'],
      facebook: json['facebook'],
      website: json['website'],
      instagram: json['instagram'],
    );
  }
}

class ActivityModel {
  final String id;
  final String name;
  final String description;
  final String location;
  final double price;
  final List<String> images;
  final String status;

  // --- Nullable fields that may not exist in all API responses ---
  final String? countryId;
  final bool? isAdvertisement;
  final double? lat;
  final double? lng;
  final String? tripType;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? companyName;
  final double? companyRating;
  final Contact? contact; // <-- ADDED: To hold contact details
  final String? countryName;
  final double? rating;
  bool isFavorited; // Client-side state

  ActivityModel({
    required this.id,
    required this.name,
    required this.description,
    required this.location,
    required this.price,
    required this.images,
    required this.status,
    this.countryId,
    this.isAdvertisement,
    this.lat,
    this.lng,
    this.tripType,
    this.startDate,
    this.endDate,
    this.companyName,
    this.companyRating,
    this.contact, // <-- ADDED: To constructor
    this.countryName,
    this.rating,
    this.isFavorited = false,
  });

  factory ActivityModel.fromJson(Map<String, dynamic> json) {
    // Handle nested company object from details endpoint
    String? companyName;
    double? companyRating;
    Contact? contact; // <-- ADDED: Variable to hold parsed contact

    if (json['company'] != null && json['company'] is Map) {
      companyName = json['company']['name'];
      companyRating = (json['company']['rating'] as num?)?.toDouble();
      // <-- ADDED: Check for and parse the nested contact object
      if (json['company']['contact'] != null &&
          json['company']['contact'] is Map) {
        contact = Contact.fromJson(json['company']['contact']);
      }
    } else {
      // Fallback for flat structure from other endpoints
      companyName = json['companyName'];
      companyRating = (json['companyRating'] as num?)?.toDouble();
    }

    return ActivityModel(
      id: json['id'] ?? '',
      name: json['name'] ?? 'Untitled Activity',
      description: json['description'] ?? 'No description available.',
      location: json['location'] ?? 'N/A',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      images: List<String>.from(json['images'] ?? []),
      status: json['status'] ?? '',
      countryId: json['countryId'],
      isAdvertisement: json['isAdvertisement'],
      lat: (json['lat'] as num?)?.toDouble(),
      lng: (json['lng'] as num?)?.toDouble(),
      tripType: json['tripType'],
      startDate:
      json['startDate'] != null ? DateTime.tryParse(json['startDate']) : null,
      endDate:
      json['endDate'] != null ? DateTime.tryParse(json['endDate']) : null,
      countryName: json['countryName'],
      rating: (json['rating'] as num?)?.toDouble(),
      isFavorited: json['isFavorited'] ?? false,
      // Use the parsed company data
      companyName: companyName,
      companyRating: companyRating,
      contact: contact, // <-- ADDED: Assign parsed contact
    );
  }

  String get displayImageUrl => images.isNotEmpty
      ? images.first
      : 'https://placehold.co/300x200/cccccc/ffffff?text=No+Image';

  /// Converts an ActivityModel instance to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'location': location,
      'price': price,
      'images': images,
      'startDate': startDate?.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'isFavorited': isFavorited,
    };
  }
}