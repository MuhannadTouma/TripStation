import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../l10n/app_localizations.dart';

import 'activity_details_screen.dart';

class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final TextEditingController _searchController = TextEditingController();
  final MapController _mapController = MapController();

  // Sample activity locations
  // Note: 'name', 'description', and 'location' in ActivityLocation model
  // are dynamic content and would typically come from a database.
  // Localizing these specific values in ARB would only make sense if they are fixed.
  final List<ActivityLocation> _activityLocations = [
    ActivityLocation(
      id: '1',
      name: 'Barta Watar',
      description: 'reiciendis numquam reiciendis iendis numquam reiciendis',
      rating: 4.5,
      position: LatLng(-8.7467, 115.1775), // Bali coordinates
      imageUrl: 'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=300&h=200&fit=crop',
    ),
    ActivityLocation(
      id: '2',
      name: 'Mountain Adventure',
      description: 'Amazing mountain hiking experience',
      rating: 4.2,
      position: LatLng(-8.7567, 115.1875),
      imageUrl: 'https://images.unsplash.com/photo-1464822759844-d150baec0494?w=300&h=200&fit=crop',
    ),
    ActivityLocation(
      id: '3',
      name: 'Beach Paradise',
      description: 'Beautiful beach with crystal clear water',
      rating: 4.8,
      position: LatLng(-8.7367, 115.1675),
      imageUrl: 'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?w=300&h=200&fit=crop',
    ),
    ActivityLocation(
      id: '4',
      name: 'Cultural Tour',
      description: 'Explore local culture and traditions',
      rating: 4.3,
      position: LatLng(-8.7667, 115.1975),
      imageUrl: 'https://images.unsplash.com/photo-1539650116574-75c0c6d73f6e?w=300&h=200&fit=crop',
    ),
    ActivityLocation(
      id: '5',
      name: 'Waterfall Trek',
      description: 'Hidden waterfall adventure',
      rating: 4.6,
      position: LatLng(-8.7267, 115.1575),
      imageUrl: 'https://images.unsplash.com/photo-1432889490240-84df33d47091?w=300&h=200&fit=crop',
    ),
  ];

  ActivityLocation? _selectedActivity;

  @override
  void initState() {
    super.initState();
    _selectedActivity = _activityLocations.first;
  }

  @override
  Widget build(BuildContext context) {
    // Access localized strings
    final s = AppLocalizations.of(context)!;

    return Scaffold(
      // Removed AppBar as requested
      body: Stack(
        children: [
          // Map
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: LatLng(-8.7467, 115.1775), // Center on Bali
              initialZoom: 13.0,
              onTap: (tapPosition, point) {
                setState(() {
                  _selectedActivity = null;
                });
              },
            ),
            children: [
              // Map tiles
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.travel_station',
              ),

              // Activity markers
              MarkerLayer(
                markers: _activityLocations.map((activity) {
                  bool isSelected = _selectedActivity?.id == activity.id;
                  return Marker(
                    point: activity.position,
                    width: isSelected ? 40 : 20,
                    height: isSelected ? 40 : 20,
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedActivity = activity;
                        });
                        _mapController.move(activity.position, 14.0);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFF294FB6), // Const for performance
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white,
                            width: isSelected ? 4 : 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.3),
                              blurRadius: 6,
                              offset: const Offset(0, 2), // Const for performance
                            ),
                          ],
                        ),
                        child: isSelected
                            ? Container(
                          width: 5,
                          height: 5,
                          decoration: BoxDecoration(
                            color: const Color(0xFF294FB6).withValues(alpha: 0.3), // Const for performance
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Container(
                              width: 5,
                              height: 5,
                              decoration: const BoxDecoration( // Const for performance
                                color: Color(0xFF294FB6),
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        )
                            : null,
                      ),
                    ),
                  );
                }).toList(),
              ),

              // Selected area circle
              if (_selectedActivity != null)
                CircleLayer(
                  circles: [
                    CircleMarker(
                      point: _selectedActivity!.position,
                      radius: 50,
                      color: const Color(0xFF294FB6).withValues(alpha: 0.2), // Const for performance
                      borderColor: const Color(0xFF294FB6).withValues(alpha: 0.5), // Const for performance
                      borderStrokeWidth: 1,
                    ),
                  ],
                ),
            ],
          ),

          // Custom Header (replaces AppBar)
          SafeArea(
            child: Container(
              margin: EdgeInsets.zero, // Changed to zero as it was previously 0
              decoration: const BoxDecoration( // Const for performance
                color: Color(0xFF294FB6),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15), // Const for performance
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Icon( // Const for performance
                        Icons.arrow_back,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const Spacer(), // Const for performance
                    Text(
                      s.appName, // Localized: "Trip Station"
                      style: const TextStyle( // Const for performance
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(), // Const for performance
                    const SizedBox(width: 24), // Const for performance // Balance the back button
                  ],
                ),
              ),
            ),
          ),

          // Search Bar
          Positioned(
            // Adjusted top padding to account for removed AppBar and custom header height
            top: MediaQuery.of(context).padding.top + 70, // Approx. height of custom header + status bar
            left: 20,
            right: 20,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 2), // Const for performance
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: s.searchHint, // Localized: "Search"
                  hintStyle: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 16,
                  ),
                  prefixIcon: Icon(
                    Icons.search,
                    color: Colors.grey[400],
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric( // Const for performance
                    horizontal: 20,
                    vertical: 15,
                  ),
                ),
              ),
            ),
          ),

          // Activity Cards at Bottom
          if (_selectedActivity != null)
            Positioned(
              bottom: 100,
              left: 0,
              right: 0,
              child: SizedBox( // Use SizedBox for fixed height
                height: 120,
                child: PageView.builder(
                  controller: PageController(
                    viewportFraction: 0.85,
                    initialPage: _activityLocations.indexOf(_selectedActivity!),
                  ),
                  onPageChanged: (index) {
                    setState(() {
                      _selectedActivity = _activityLocations[index];
                    });
                    _mapController.move(_activityLocations[index].position, 14.0);
                  },
                  itemCount: _activityLocations.length,
                  itemBuilder: (context, index) {
                    final activity = _activityLocations[index];
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 8), // Const for performance
                      child: _buildActivityCard(activity),
                    );
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildActivityCard(ActivityLocation activity) {
    return GestureDetector(
      onTap: (){
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ActivityDetailsScreen(
            activityId: activity.id,
          )),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 4), // Const for performance
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(12), // Const for performance
          child: Row(
            children: [
              // Activity Image
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  image: DecorationImage(
                    onError: (_,__){
                      // Error handling for image loading
                      return;
                    },
                    image: NetworkImage(activity.imageUrl),
                    fit: BoxFit.cover,
                  ),
                ),
              ),

              const SizedBox(width: 12), // Const for performance

              // Activity Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      activity.name, // Dynamic content, not localized in ARB
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[800],
                      ),
                    ),

                    const SizedBox(height: 4), // Const for performance

                    Text(
                      activity.description, // Dynamic content, not localized in ARB
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 8), // Const for performance

                    // Rating (dynamic content, not localized in ARB)
                    Row(
                      children: [
                        ...List.generate(5, (index) {
                          return Icon(
                            Icons.star,
                            color: index < activity.rating.floor()
                                ? Colors.orange
                                : Colors.grey[300],
                            size: 14,
                          );
                        }),
                        const SizedBox(width: 4), // Const for performance
                        Text(
                          activity.rating.toString(),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}

// Activity Location Model
class ActivityLocation {
  final String id;
  final String name;
  final String description;
  final double rating;
  final LatLng position;
  final String imageUrl;

  ActivityLocation({
    required this.id,
    required this.name,
    required this.description,
    required this.rating,
    required this.position,
    required this.imageUrl,
  });
}