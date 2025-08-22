import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shimmer/shimmer.dart'; // Import the shimmer package
import 'package:trip_station/api/providers/auth_provider.dart';
import 'package:trip_station/api/services/activity_service.dart';
import 'package:trip_station/models/activity_model.dart';
import 'package:url_launcher/url_launcher.dart';
import '../l10n/app_localizations.dart';

class ActivityDetailsScreen extends StatefulWidget {
  final String activityId;

  const ActivityDetailsScreen({
    super.key,
    required this.activityId,
  });

  @override
  _ActivityDetailsScreenState createState() => _ActivityDetailsScreenState();
}

class _ActivityDetailsScreenState extends State<ActivityDetailsScreen> {
  late Future<ActivityModel> _activityFuture;
  late ActivityService _activityService;
  late AuthProvider _authProvider;

  // --- NEW: Flag to track if the favorite status has changed ---
  bool _didFavoriteStatusChange = false;

  @override
  void initState() {
    super.initState();
    _activityService = Provider.of<ActivityService>(context, listen: false);
    _authProvider = Provider.of<AuthProvider>(context, listen: false);
    _activityFuture = _fetchActivityDetails();
  }

  Future<ActivityModel> _fetchActivityDetails() {
    final token = _authProvider.userToken;
    if (token == null) {
      return Future.error(Exception('User not authenticated.'));
    }
    return _activityService.getActivityDetails(
      activityId: widget.activityId,
      token: token,
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<ActivityModel>(
      future: _activityFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingScreen(); // Use the new creative loading screen
        } else if (snapshot.hasError) {
          return _buildErrorScreen(snapshot.error.toString());
        } else if (snapshot.hasData) {
          // --- MODIFIED: Wrap the screen in a PopScope to handle back navigation ---
          return PopScope(
            canPop: false,
            onPopInvoked: (didPop) {
              if (didPop) return;
              // When popping, return whether the favorite status changed.
              Navigator.pop(context, _didFavoriteStatusChange);
            },
            child: _buildDetailsScreen(context, snapshot.data!),
          );
        }
        return _buildErrorScreen('Something went wrong.');
      },
    );
  }

  /// Main UI with a SliverAppBar and sticky bottom bar.
  Widget _buildDetailsScreen(BuildContext context, ActivityModel activity) {
    final s = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Scrollable content area using CustomScrollView for slivers
          CustomScrollView(
            slivers: [
              _buildSliverAppBar(context, activity), // The new collapsing app bar
              SliverToBoxAdapter(child: _buildContent(context, s, activity)),
            ],
          ),
          // Sticky bottom action bar remains at the bottom
          _buildBottomBar(context, s, activity),
        ],
      ),
    );
  }

  /// Builds the collapsing SliverAppBar.
  Widget _buildSliverAppBar(BuildContext context, ActivityModel activity) {
    return StatefulBuilder(
      builder: (context, setIconState) {
        return SliverAppBar(
          expandedHeight: 300,
          pinned: true,
          stretch: true,
          backgroundColor: const Color(0xFF294FB6),
          elevation: 0,
          // --- MODIFIED: The back button now pops with a result ---
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context, _didFavoriteStatusChange),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.share, color: Colors.white),
              onPressed: () => _handleShare(activity),
            ),
            IconButton(
              icon: Icon(
                activity.isFavorited ? Icons.favorite : Icons.favorite_border,
                color: activity.isFavorited ? Colors.red : Colors.white,
              ),
              onPressed: () async {
                final originalState = activity.isFavorited;
                setIconState(() {
                  activity.isFavorited = !activity.isFavorited;
                });
                try {
                  await _toggleFavorite(activity);
                  // --- NEW: Mark that a change has occurred ---
                  setState(() {
                    _didFavoriteStatusChange = true;
                  });
                } catch (e) {
                  setIconState(() {
                    activity.isFavorited = originalState;
                  });
                  _showErrorSnackbar(e.toString());
                }
              },
            ),
            const SizedBox(width: 10),
          ],
          flexibleSpace: FlexibleSpaceBar(
            stretchModes: const [StretchMode.zoomBackground],
            background: _buildHeaderImage(activity),
          ),
        );
      },
    );
  }

  /// Builds the header image with an immediate background color.
  Widget _buildHeaderImage(ActivityModel activity) {
    return Container(
      color: Colors.grey[300],
      child: Stack(
        fit: StackFit.expand,
        children: [
          _buildImage(activity.displayImageUrl),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.5),
                  Colors.transparent,
                  Colors.transparent,
                ],
                stops: const [0.0, 0.5, 1.0],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the main content section below the header.
  Widget _buildContent(
      BuildContext context, AppLocalizations s, ActivityModel activity) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            activity.companyName ?? s.companyNamePlaceholder,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.location_on, color: Colors.grey[500], size: 16),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  activity.location,
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            activity.description,
            style:
            TextStyle(fontSize: 15, color: Colors.grey[700], height: 1.6),
          ),
          const SizedBox(height: 25),
          Row(
            children: [
              Row(
                children: [
                  ...List.generate(5, (index) {
                    return Icon(
                      Icons.star,
                      color: index < (activity.rating ?? 0)
                          ? Colors.orange
                          : Colors.grey[300],
                      size: 20,
                    );
                  }),
                  const SizedBox(width: 8),
                  Text(
                    (activity.rating ?? 0.0).toStringAsFixed(1),
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[700]),
                  ),
                ],
              ),
              const Spacer(),
              Text(
                '${activity.price.toStringAsFixed(0)} SAR',
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.grey[800]),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Builds the sticky bottom bar with the "Contact Us" button.
  Widget _buildBottomBar(
      BuildContext context, AppLocalizations s, ActivityModel activity) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.white.withOpacity(0.0),
              Colors.white.withOpacity(0.9),
              Colors.white,
            ],
            stops: const [0.0, 0.3, 1.0],
          ),
        ),
        child: SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: () => _handleContactUs(activity),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF294FB6),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25)),
              elevation: 2,
              shadowColor: Colors.black.withOpacity(0.2),
            ),
            child: Text(
              s.contactUsButton,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ),
    );
  }

  // --- Helper & Handler Methods ---

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
      loadingBuilder: (BuildContext context, Widget child,
          ImageChunkEvent? loadingProgress) {
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
              size: 50,
            ),
          ),
        );
      },
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

  Future<void> _toggleFavorite(ActivityModel activity) async {
    final token = _authProvider.userToken;
    final userId = _authProvider.user?.id;
    if (token == null || userId == null) {
      throw Exception('User not authenticated.');
    }
    await _activityService.toggleFavoriteStatus(
        activity.id, userId, token, activity.isFavorited);
  }

  void _handleShare(ActivityModel activity) {
    final s = AppLocalizations.of(context)!;
    final String activityName = activity.name;
    final String companyName = activity.companyName ?? s.companyNamePlaceholder;
    final String location = activity.location;
    final String price = activity.price.toStringAsFixed(0);
    final String shareText = s.shareTripMessage(
      activityName,
      companyName,
      location,
      price,
    );
    Share.share(shareText, subject: s.shareSheetTitle);
  }

  void _handleContactUs(ActivityModel activity) {
    final s = AppLocalizations.of(context)!;
    final contact = activity.contact;
    final List<Widget> contactOptions = [];

    if (contact?.whatsapp != null && contact!.whatsapp!.isNotEmpty) {
      contactOptions.add(ListTile(
        leading: const Icon(Icons.message, color: Color(0xFF294FB6)),
        title: const Text('WhatsApp'),
        subtitle: Text(contact.whatsapp!),
        onTap: () async {
          final Uri url = Uri.parse('https://wa.me/${contact.whatsapp}');
          if (await canLaunchUrl(url)) {
            await launchUrl(url, mode: LaunchMode.externalApplication);
          }
          Navigator.pop(context);
        },
      ));
    }

    if (contact?.facebook != null && contact!.facebook!.isNotEmpty) {
      contactOptions.add(ListTile(
        leading: const Icon(Icons.facebook, color: Color(0xFF294FB6)),
        title: const Text('Facebook'),
        subtitle: Text(contact.facebook!),
        onTap: () async {
          final Uri url = Uri.parse(contact.facebook!.startsWith('http')
              ? contact.facebook!
              : 'https://facebook.com/${contact.facebook!}');
          if (await canLaunchUrl(url)) {
            await launchUrl(url, mode: LaunchMode.externalApplication);
          }
          Navigator.pop(context);
        },
      ));
    }

    if (contact?.instagram != null && contact!.instagram!.isNotEmpty) {
      contactOptions.add(ListTile(
        leading: const Icon(Icons.photo_camera, color: Color(0xFF294FB6)),
        title: const Text('Instagram'),
        subtitle: Text(contact.instagram!),
        onTap: () async {
          final Uri url = Uri.parse(
              'https://instagram.com/${contact.instagram!.replaceAll('@', '')}');
          if (await canLaunchUrl(url)) {
            await launchUrl(url, mode: LaunchMode.externalApplication);
          }
          Navigator.pop(context);
        },
      ));
    }

    if (contact?.website != null && contact!.website!.isNotEmpty) {
      contactOptions.add(ListTile(
        leading: const Icon(Icons.link, color: Color(0xFF294FB6)),
        title: const Text('Website'),
        subtitle: Text(contact.website!),
        onTap: () async {
          final Uri url = Uri.parse(contact.website!.startsWith('http')
              ? contact.website!
              : 'https://${contact.website!}');
          if (await canLaunchUrl(url)) {
            await launchUrl(url, mode: LaunchMode.externalApplication);
          }
          Navigator.pop(context);
        },
      ));
    }

    if (contactOptions.isEmpty) {
      _showErrorSnackbar('No contact information is available.');
      return;
    }

    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                s.contactOptionsTitle,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Divider(height: 20),
              Flexible(
                child: ListView(
                  shrinkWrap: true,
                  children: contactOptions,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showErrorSnackbar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message.replaceFirst('Exception: ', '')),
        backgroundColor: Colors.red,
      ),
    );
  }

  /// A beautiful and creative loading placeholder screen.
  Widget _buildLoadingScreen() {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Image Placeholder
            Container(
              height: 300,
              width: double.infinity,
              color: Colors.white,
            ),
            // Content Placeholder
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title Placeholder
                  Container(
                    height: 28,
                    width: MediaQuery.of(context).size.width * 0.6,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Location Placeholder
                  Container(
                    height: 16,
                    width: MediaQuery.of(context).size.width * 0.4,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Description Placeholders
                  Container(
                    height: 15,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 15,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 15,
                    width: MediaQuery.of(context).size.width * 0.7,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorScreen(String error) {
    return Scaffold(
      appBar: AppBar(title: const Text('Error')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 60),
              const SizedBox(height: 20),
              Text(
                error.replaceFirst('Exception: ', ''),
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red, fontSize: 16),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _activityFuture = _fetchActivityDetails();
                  });
                },
                child: const Text('Retry'),
              )
            ],
          ),
        ),
      ),
    );
  }
}