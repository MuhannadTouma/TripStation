class Ad {
  final String id;
  final int price;
  final List<String> images;
  final String location;
  final int rating;
  final DateTime startDate;
  final DateTime endDate;
  final double lat;
  final double lng;
  final String name;
  final String description;

  Ad({
    required this.id,
    required this.price,
    required this.images,
    required this.location,
    required this.rating,
    required this.startDate,
    required this.endDate,
    required this.lat,
    required this.lng,
    required this.name,
    required this.description,
  });

  factory Ad.fromJson(Map<String, dynamic> json) {
    return Ad(
      id: json['id'],
      price: json['price'],
      images: List<String>.from(json['images']),
      location: json['location'],
      rating: json['rating'],
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),
      lat: json['lat'].toDouble(),
      lng: json['lng'].toDouble(),
      name: json['name'],
      description: json['description'],
    );
  }
}
