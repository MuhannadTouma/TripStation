import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:trip_station/api/providers/auth_provider.dart';
import 'package:trip_station/api/services/activity_service.dart';
import 'package:trip_station/models/activity_model.dart';
import '../l10n/app_localizations.dart';
import 'activity_details_screen.dart';
import 'map_screen.dart';

class ActivitiesScreen extends StatefulWidget {
  final String countryId;
  final String countryName;

  const ActivitiesScreen({
    super.key,
    required this.countryId,
    required this.countryName,
  });

  @override
  _ActivitiesScreenState createState() => _ActivitiesScreenState();
}

class _ActivitiesScreenState extends State<ActivitiesScreen> {
  // Services and Providers
  late ActivityService _activityService;
  late AuthProvider _authProvider;

  // Data and UI State
  bool _isLoading = true; // For the initial page load
  bool _isFiltering = false; // For when the filter API call is in progress
  String? _error;
  List<ActivityModel> _masterActivities = []; // Source of truth from the last backend call
  List<ActivityModel> _displayedActivities = []; // The list to display after client-side search

  // Filter and Search state
  final TextEditingController _searchController = TextEditingController();
  double _minPrice = 100;
  double _maxPrice = 10000;
  int _selectedRating = 0;
  String _searchQuery = ''; // For the top search bar (client-side)
  String _locationQuery = ''; // For the filter dialog (backend)

  @override
  void initState() {
    super.initState();
    _activityService = Provider.of<ActivityService>(context, listen: false);
    _authProvider = Provider.of<AuthProvider>(context, listen: false);

    _fetchActivities(); // Initial fetch
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  // --- Data Fetching & Filtering ---

  /// Fetches the complete, unfiltered list of activities. Used for initial load and reset.
  Future<void> _fetchActivities() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final token = _authProvider.userToken;
    if (token == null) {
      setState(() {
        _error = 'User not authenticated.';
        _isLoading = false;
      });
      return;
    }

    try {
      final activities = await _activityService.getActivitiesByCountry(
        countryId: widget.countryId,
        token: token,
      );
      if (!mounted) return;
      setState(() {
        _masterActivities = activities;
        _applyClientSideNameSearch(); // Apply search to the new master list
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  /// Applies filters by calling the backend API.
  Future<void> _applyBackendFilters({
    required double minPrice,
    required double maxPrice,
    required int rating,
    required String location,
  }) async {
    setState(() {
      _isFiltering = true; // Show loading overlay
      _error = null;
    });

    final token = _authProvider.userToken;
    if (token == null) {
      setState(() {
        _error = 'User not authenticated.';
        _isFiltering = false;
      });
      return;
    }

    try {
      final filteredResults = await _activityService.filterActivities(
        token: token,
        countryId: widget.countryId,
        minPrice: minPrice,
        maxPrice: maxPrice,
        rating: rating,
        location: location,
      );

      if (!mounted) return;
      setState(() {
        _masterActivities = filteredResults;
        _applyClientSideNameSearch(); // Apply search to the new filtered list
        _isFiltering = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _isFiltering = false;
      });
    }
  }

  /// Handles the top search bar, which filters the *current* list by name.
  void _onSearchChanged() {
    if (_searchQuery != _searchController.text.toLowerCase()) {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
        _applyClientSideNameSearch();
      });
    }
  }

  /// A helper to apply the client-side name search on the current master list of activities.
  void _applyClientSideNameSearch() {
    if (_searchQuery.isEmpty) {
      // If no search query, display the full master list
      _displayedActivities = List.from(_masterActivities);
    } else {
      // Otherwise, filter the master list by name
      _displayedActivities = _masterActivities
          .where((activity) =>
          activity.name.toLowerCase().contains(_searchQuery))
          .toList();
    }
  }


  // --- UI Build Methods ---

  @override
  Widget build(BuildContext context) {
    final s = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        backgroundColor: const Color(0xFF294FB6),
        title: Text(
          widget.countryName,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          _buildSearchAndFilterBar(s),
          Expanded(child: _buildBody(s)),
        ],
      ),
    );
  }

  /// --- MODIFIED: Body now shows shimmer during filtering ---
  Widget _buildBody(AppLocalizations s) {
    if (_isLoading) {
      return _buildLoadingState(); // Initial page load shimmer
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Text(
            'Error: ${_error!.replaceFirst("Exception: ", "")}',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.red),
          ),
        ),
      );
    }

    // Show shimmer while filtering, otherwise show the list.
    // This replaces the overlay with a more integrated loading effect.
    return RefreshIndicator(
      onRefresh: _fetchActivities, // Pull-to-refresh resets all filters
      child: _isFiltering ? _buildLoadingState() : _buildActivitiesList(s),
    );
  }

  Widget _buildSearchAndFilterBar(AppLocalizations s) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: s.searchHint,
                  hintStyle: TextStyle(color: Colors.grey[400], fontSize: 16),
                  prefixIcon: Icon(Icons.search, color: Colors.grey[400]),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                ),
              ),
            ),
          ),
          const SizedBox(width: 15),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFF294FB6),
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: IconButton(
              onPressed: _showFilterDialog,
              icon: const Icon(Icons.tune, color: Colors.white, size: 24),
            ),
          ),
        ],
      ),
    );
  }

  /// Helper to properly encode image URLs.
  String _getEncodedUrl(String url) {
    try {
      return Uri.parse(url).toString();
    } catch (e) {
      print('Failed to parse URL: $url. Error: $e');
      return url;
    }
  }

  /// Enhanced image builder for loading, error, and loaded states.
  Widget _buildImage(String url) {
    final encodedUrl = _getEncodedUrl(url);

    return Image.network(
      encodedUrl,
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
      loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
        if (loadingProgress == null) return child;
        return Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Container(color: Colors.white),
        );
      },
      errorBuilder: (context, error, stackTrace) {
        return Container(
          color: Colors.grey[200],
          child: Center(
            child: Icon(
              Icons.image_not_supported_outlined,
              color: Colors.grey[400],
              size: 40,
            ),
          ),
        );
      },
      frameBuilder: (BuildContext context, Widget child, int? frame, bool wasSynchronouslyLoaded) {
        if (wasSynchronouslyLoaded) return child;
        return AnimatedOpacity(
          opacity: frame == null ? 0 : 1,
          duration: const Duration(seconds: 1),
          curve: Curves.easeOut,
          child: child,
        );
      },
    );
  }

  /// A beautiful loading placeholder for the activities list.
  Widget _buildLoadingState() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: ListView.builder(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: 6, // Show 6 placeholder cards
        itemBuilder: (context, index) {
          return Container(
            margin: const EdgeInsets.only(bottom: 20),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image placeholder
                Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                const SizedBox(width: 15),
                // Text placeholders
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 5),
                      Container(
                        height: 16,
                        width: double.infinity,
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(4)
                        ),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        height: 12,
                        width: double.infinity,
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(4)
                        ),
                      ),
                      const SizedBox(height: 5),
                      Container(
                        height: 12,
                        width: MediaQuery.of(context).size.width * 0.3,
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(4)
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  /// --- NEW: A beautiful empty state widget ---
  Widget _buildEmptyList(AppLocalizations s) {
    // This widget is designed to be placed inside a RefreshIndicator,
    // so it needs to be scrollable to trigger the refresh action.
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              // Ensure the content can fill the screen vertically
              minHeight: constraints.maxHeight,
            ),
            child: Padding(
              padding: const EdgeInsets.all(30.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(
                    Icons.search_off_rounded,
                    size: 100,
                    color: Colors.grey[300],
                  ),
                  const SizedBox(height: 20),
                  Text(
                    s.noResultsFoundTitle, // New localized string
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    s.noResultsFoundSubtitle, // New localized string
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[500],
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton.icon(
                    onPressed: () {
                      // Reset all filters and fetch the original list
                      setState(() {
                        _minPrice = 100;
                        _maxPrice = 10000;
                        _selectedRating = 0;
                        _locationQuery = '';
                        _searchController.clear();
                      });
                      // Fetch the full, unfiltered list again
                      _fetchActivities();
                    },
                    icon: const Icon(Icons.refresh, size: 20),
                    label: Text(s.clearFiltersButton), // New localized string
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF294FB6),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 30, vertical: 15),
                      textStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// --- MODIFIED: Uses the new empty state widget ---
  Widget _buildActivitiesList(AppLocalizations s) {
    if (_displayedActivities.isEmpty && !_isLoading && !_isFiltering) {
      return _buildEmptyList(s); // Use the new beautiful empty state
    }
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: _displayedActivities.length,
      itemBuilder: (context, index) {
        final activity = _displayedActivities[index];
        return _buildActivityCard(activity);
      },
    );
  }

  Widget _buildActivityCard(ActivityModel activity) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ActivityDetailsScreen(
                activityId: activity.id
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: SizedBox(
            height: 90, // Set a fixed height for the card content
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: SizedBox(
                    width: 90,
                    height: 90,
                    child: _buildImage(activity.displayImageUrl),
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        activity.name,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[800],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        activity.description,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                          height: 1.4,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const Spacer(), // Use Spacer to push price to the bottom
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            '${activity.price.toStringAsFixed(0)} SAR',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF294FB6),
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
      ),
    );
  }

  void _showFilterDialog() {
    final s = AppLocalizations.of(context)!;
    double tempMinPrice = _minPrice;
    double tempMaxPrice = _maxPrice;
    int tempSelectedRating = _selectedRating;
    final locationController = TextEditingController(text: _locationQuery);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.70,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(25),
                  topRight: Radius.circular(25),
                ),
              ),
              child: Column(
                children: [
                  // Header
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text(s.cancelButton, style: TextStyle(color: Colors.grey[600], fontSize: 16)),
                        ),
                        Text(s.filterTitle, style: const TextStyle(color: Color(0xFF294FB6), fontSize: 18, fontWeight: FontWeight.w600)),
                        TextButton(
                          onPressed: () {
                            // Reset the main screen state and fetch all activities
                            setState(() {
                              _minPrice = 100;
                              _maxPrice = 10000;
                              _selectedRating = 0;
                              _locationQuery = '';
                              _searchController.clear(); // Also clear the top search bar
                            });
                            _fetchActivities();
                            Navigator.pop(context);
                          },
                          child: Text(s.resetButton, style: TextStyle(color: Colors.grey[600], fontSize: 16)),
                        ),
                      ],
                    ),
                  ),
                  // Filter Content
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Where Section
                          Text(s.whereQuestion, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Color.fromRGBO(66, 66, 66, 1))),
                          const SizedBox(height: 15),
                          Row(
                            children: [
                              Expanded(
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF8F9FA),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: Colors.grey[300]!, width: 1),
                                  ),
                                  child: TextField(
                                    controller: locationController,
                                    decoration: InputDecoration(
                                      hintText: s.exMyLocationHint,
                                      hintStyle: TextStyle(color: Colors.grey[400], fontSize: 12),
                                      prefixIcon: Icon(Icons.location_on_outlined, color: Colors.grey[400]),
                                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                                      contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              SizedBox(
                                height: 50,
                                child: ElevatedButton(
                                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => MapScreen())),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF294FB6),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    elevation: 0,
                                  ),
                                  child: Text(s.useMapButton, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 30),
                          // Ratings Section
                          Text(s.ratingsSection, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Color.fromRGBO(66, 66, 66, 1))),
                          const SizedBox(height: 15),
                          Row(
                            children: List.generate(5, (index) {
                              int rating = index + 1;
                              bool isSelected = rating == tempSelectedRating;
                              return Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 5),
                                  child: ElevatedButton(
                                    onPressed: () => setModalState(() => tempSelectedRating = isSelected ? 0 : rating),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: isSelected ? const Color(0xFF294FB6) : Colors.white,
                                      foregroundColor: isSelected ? Colors.white : Colors.grey[600],
                                      side: BorderSide(color: isSelected ? const Color(0xFF294FB6) : Colors.grey[300]!, width: 1),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                      elevation: 0,
                                      padding: EdgeInsets.zero,
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text('$rating', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                                        const SizedBox(width: 3),
                                        Icon(Icons.star, size: 16, color: isSelected ? Colors.white : Colors.amber),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            }),
                          ),
                          const SizedBox(height: 30),
                          // Price Ranges Section
                          Text(s.priceRangesSection, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Color.fromRGBO(66, 66, 66, 1))),
                          const SizedBox(height: 20),
                          RangeSlider(
                            values: RangeValues(tempMinPrice, tempMaxPrice),
                            min: 100,
                            max: 10000,
                            divisions: 100,
                            activeColor: const Color(0xFF294FB6),
                            inactiveColor: Colors.grey[300],
                            onChanged: (RangeValues values) {
                              setModalState(() {
                                tempMinPrice = values.start;
                                tempMaxPrice = values.end;
                              });
                            },
                          ),
                          Text('${tempMinPrice.round()} SAR - ${tempMaxPrice.round()} SAR', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.grey[800])),
                          const Spacer(),
                          // Apply Button
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: () {
                                // Capture the current values from the dialog's state
                                final newMinPrice = tempMinPrice;
                                final newMaxPrice = tempMaxPrice;
                                final newRating = tempSelectedRating;
                                final newLocation = locationController.text.toLowerCase();

                                // Update the screen's state so the dialog opens with the correct values next time
                                setState(() {
                                  _minPrice = newMinPrice;
                                  _maxPrice = newMaxPrice;
                                  _selectedRating = newRating;
                                  _locationQuery = newLocation;
                                });

                                // Call the filter function with the new values directly
                                _applyBackendFilters(
                                  minPrice: newMinPrice,
                                  maxPrice: newMaxPrice,
                                  rating: newRating,
                                  location: newLocation,
                                );
                                Navigator.pop(context);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF294FB6),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                elevation: 0,
                              ),
                              child: Text(s.applyButton, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600, letterSpacing: 1)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}