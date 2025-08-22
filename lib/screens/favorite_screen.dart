import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart'; // Import the shimmer package
import 'package:trip_station/api/api_constants.dart';
import '../api/providers/auth_provider.dart';
import '../l10n/app_localizations.dart';
import 'package:trip_station/models/activity_model.dart';
import 'package:trip_station/api/services/activity_service.dart';
import 'package:trip_station/models/pagination_response_model.dart';

import 'activity_details_screen.dart';
import 'home_view.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  _FavoritesScreenState createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  // Use a List to hold the activities, as they will be appended
  List<ActivityModel> _favoriteActivities = [];
  // Future that represents the initial fetch operation.
  late Future<void> _initialFetchFuture;
  late ActivityService _activityService;
  late AuthProvider _authProvider;

  // Pagination state
  int _currentPage = 1;
  int _totalPages = 1;
  bool _isLoadingMore = false; // To show loader at bottom of list
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _initialFetchFuture = Future.value(); // Initialize to a completed Future

    // Initialize services and fetch data after the first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _activityService = Provider.of<ActivityService>(context, listen: false);
      _authProvider = Provider.of<AuthProvider>(context, listen: false);
      // Trigger the initial fetch
      setState(() {
        _initialFetchFuture = _fetchFavoriteActivities(page: 1);
      });
    });

    // Add listener to scroll controller for infinite scrolling
    _scrollController.addListener(_scrollListener);
  }

  /// Listener for scroll events to detect when to load more data.
  void _scrollListener() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent &&
        _currentPage < _totalPages &&
        !_isLoadingMore) {
      _fetchMoreActivities();
    }
  }

  /// Fetches favorite activities from the backend.
  Future<void> _fetchFavoriteActivities({int page = 1}) async {
    final String? token = _authProvider.userToken;
    if (token == null) {
      if (page == 1) {
        throw Exception('User not authenticated. Please log in.');
      } else {
        _showErrorSnackbar('User not authenticated. Please log in.');
        return;
      }
    }

    try {
      final PaginationResponse response =
      await _activityService.getFavoriteActivities(
        token,
        page: page,
        limit: 10,
      );

      if (!mounted) return;
      setState(() {
        if (page == 1) {
          _favoriteActivities = response.activities;
        } else {
          _favoriteActivities.addAll(response.activities);
        }
        _currentPage = response.pagination.page;
        _totalPages = response.pagination.totalPages;
        _isLoadingMore = false;
      });
    } catch (e) {
      if (!mounted) return;
      _isLoadingMore = false;
      if (page == 1) {
        rethrow;
      } else {
        _showErrorSnackbar(e.toString().replaceFirst('Exception: ', ''));
      }
    }
  }

  /// Triggers fetching of the next page of favorite activities.
  Future<void> _fetchMoreActivities() async {
    if (_currentPage >= _totalPages || _isLoadingMore) {
      return;
    }

    setState(() {
      _isLoadingMore = true;
    });

    try {
      await _fetchFavoriteActivities(page: _currentPage + 1);
    } catch (e) {
      _showErrorSnackbar(e.toString().replaceFirst('Exception: ', ''));
      if (!mounted) return;
      setState(() {
        _isLoadingMore = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        toolbarHeight: 40,
        backgroundColor: const Color(0xFF294FB6),
        title: Text(
          s.favoritesTitle,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: RefreshIndicator(
        onRefresh: () => _fetchFavoriteActivities(page: 1),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                s.favoritesTitle,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: Colors.grey[800],
                ),
              ),
            ),
            Expanded(
              child: FutureBuilder<void>(
                future: _initialFetchFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return _buildLoadingState(); // Use the new shimmer loading state
                  } else if (snapshot.hasError) {
                    return _buildErrorState(context, snapshot.error.toString());
                  } else if (_favoriteActivities.isEmpty) {
                    return _buildEmptyState(context);
                  } else {
                    return ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount:
                      _favoriteActivities.length + (_isLoadingMore ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == _favoriteActivities.length) {
                          return _buildLoadMoreIndicator();
                        }
                        return _buildFavoriteCard(_favoriteActivities[index]);
                      },
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Enhanced image builder for loading, error, and loaded states.
  Widget _buildImage(String url) {
    return Image.network(
      url,
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
      // Loading state with shimmer
      loadingBuilder: (BuildContext context, Widget child,
          ImageChunkEvent? loadingProgress) {
        if (loadingProgress == null) return child;
        return Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Container(color: Colors.white),
        );
      },
      // Error state with placeholder
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
      // Loaded state with fade-in animation
      frameBuilder: (BuildContext context, Widget child, int? frame,
          bool wasSynchronouslyLoaded) {
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

  /// Builds a single favorite activity card.
  Widget _buildFavoriteCard(ActivityModel activity) {
    final s = AppLocalizations.of(context)!;
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(15),
          onTap: () => _navigateToActivityDetails(activity),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: SizedBox(
              height: 120,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: SizedBox(
                      width: 120,
                      height: 120,
                      child: _buildImage(activity.displayImageUrl),
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                activity.name,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey[800],
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () =>
                                  _showRemoveConfirmationDialog(activity),
                              child: const Icon(
                                Icons.favorite,
                                color: Colors.red,
                                size: 24,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: Text(
                            activity.description,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                              height: 1.4,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const Spacer(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            if (activity.startDate != null &&
                                activity.endDate != null)
                              Text(
                                '${(activity.endDate!.difference(activity.startDate!).inDays + 1)} ${s.days}',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey[500],
                                ),
                              ),
                            const Spacer(),
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
      ),
    );
  }

  /// A beautiful loading placeholder for the favorites list.
  Widget _buildLoadingState() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: ListView.builder(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: 5, // Show 5 placeholder cards
        itemBuilder: (context, index) {
          return Container(
            margin: const EdgeInsets.only(bottom: 15),
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
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
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
                        height: 20,
                        width: double.infinity,
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(4)),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        height: 14,
                        width: double.infinity,
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(4)),
                      ),
                      const SizedBox(height: 5),
                      Container(
                        height: 14,
                        width: MediaQuery.of(context).size.width * 0.3,
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(4)),
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

  /// Builds the UI for an empty state when no favorites are found.
  Widget _buildEmptyState(BuildContext context) {
    final s = AppLocalizations.of(context)!;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.favorite_border,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 20),
            Text(
              s.noFavoritesYet,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 10),
            Text(
              s.noFavoritesDescription,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[500],
                height: 1.5,
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const HomeView()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF294FB6),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
                padding:
                const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              ),
              child: Text(
                s.exploreActivitiesButton,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the UI for an error state when data fetching fails.
  Widget _buildErrorState(BuildContext context, String message) {
    final s = AppLocalizations.of(context)!;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 80,
              color: Colors.red[400],
            ),
            const SizedBox(height: 20),
            Text(
              s.errorLoadingFavorites,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: Colors.red[600],
              ),
            ),
            const SizedBox(height: 10),
            Text(
              message.replaceFirst('Exception: ', ''),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[500],
                height: 1.5,
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                _currentPage = 1;
                _favoriteActivities.clear();
                if (!mounted) return;
                setState(() {
                  _initialFetchFuture = _fetchFavoriteActivities(page: 1);
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF294FB6),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
                padding:
                const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              ),
              child: Text(
                s.retryButton,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds a loading indicator displayed at the bottom when loading more data.
  Widget _buildLoadMoreIndicator() {
    return const Padding(
      padding: EdgeInsets.all(16.0),
      child: Center(
        child: CircularProgressIndicator(
          color: Color(0xFF294FB6),
        ),
      ),
    );
  }

  /// Shows a confirmation dialog before removing an item from favorites.
  void _showRemoveConfirmationDialog(ActivityModel activity) {
    final s = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(s.removeFavoriteConfirmationTitle),
          content: Text(s.removeFavoriteConfirmationContent),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(s.cancelButton),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                _removeFavorite(activity);
              },
              child: Text(
                s.removeButton,
                style: const TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  /// Removes an activity from favorites, updating the UI optimistically.
  Future<void> _removeFavorite(ActivityModel activity) async {
    final s = AppLocalizations.of(context)!;
    final String? token = _authProvider.userToken;
    final String? userId = _authProvider.user?.id;

    if (token == null || userId == null) {
      _showErrorSnackbar(s.logoutNoTokenError);
      return;
    }

    final int originalIndex = _favoriteActivities.indexOf(activity);
    if (originalIndex == -1) return;

    if (!mounted) return;
    setState(() {
      _favoriteActivities.removeAt(originalIndex);
    });

    try {
      await _activityService.toggleFavoriteStatus(
        activity.id,
        userId,
        token,
        false,
      );
      _showSuccessSnackbar(s.removedFromFavorites);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _favoriteActivities.insert(originalIndex, activity);
      });
      print('Remove Favorite Error: $e');
      _showErrorSnackbar(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  /// --- MODIFIED: Navigates and waits for a result to refresh the list ---
  void _navigateToActivityDetails(ActivityModel activity) async {
    // Await the result from the details screen.
    // It will be `true` if the favorite status was changed.
    final bool? result = await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => ActivityDetailsScreen(activityId: activity.id)),
    );

    // If the result is true, it means an item was unfavorited.
    // We need to refresh the list to reflect this change.
    if (result == true && mounted) {
      setState(() {
        // Re-assigning the future will cause the FutureBuilder to show the
        // loading state again, providing a good UX for the refresh.
        _initialFetchFuture = _fetchFavoriteActivities(page: 1);
      });
    }
  }

  /// Displays a red snackbar for error messages.
  void _showErrorSnackbar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  /// Displays a success snackbar.
  void _showSuccessSnackbar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFF294FB6),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }
}