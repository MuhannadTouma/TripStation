// lib/models/country_model.dart

class Country {
  final String id;
  final String name;
  final String tripType;
  final List<String> images;

  Country({
    required this.id,
    required this.name,
    required this.tripType,
    required this.images,
  });

  factory Country.fromJson(Map<String, dynamic> json) {
    // Ensure images are parsed correctly as a list of strings
    final imagesFromJson = json['images'] as List<dynamic>? ?? [];
    final imageList = imagesFromJson.map((image) => image.toString()).toList();

    return Country(
      id: json['id'] ?? '',
      name: json['name'] ?? 'Unknown Country',
      tripType: json['tripType'] ?? '',
      images: imageList,
    );
  }
}