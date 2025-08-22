import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart'; // Import the animation package
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:trip_station/models/country_model.dart';
import 'package:trip_station/screens/activities_screen.dart';

import '../api/providers/ad_provider.dart';
import '../api/providers/auth_provider.dart';
import '../api/providers/country_provider.dart';
import '../l10n/app_localizations.dart';
import 'activity_details_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  HomeScreenState createState() => HomeScreenState();
}

// --- MODIFIED: Added WidgetsBindingObserver to detect keyboard changes ---
class HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late TabController _tabController;
  late AuthProvider _authProvider;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  // --- MODIFIED: Controller for the advertisement PageView, now starts at page 0 ---
  final PageController _adPageController =
  PageController(viewportFraction: 0.85);

  // --- MODIFIED: State for advanced carousel animation, starts at 0.0 ---
  double _adPage = 0.0;

  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _authProvider = Provider.of<AuthProvider>(context, listen: false);

    _tabController.addListener(_handleTabSelection);
    _searchController.addListener(_onSearchChanged);

    // --- MODIFIED: Add listener for carousel animation, defaults to 0.0 ---
    _adPageController.addListener(() {
      if (_adPageController.hasClients) {
        setState(() {
          _adPage = _adPageController.page ?? 0.0;
        });
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchInternationalData();
    });
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabSelection);
    _searchController.removeListener(_onSearchChanged);
    _searchFocusNode.dispose();
    _tabController.dispose();
    _searchController.dispose();
    _adPageController.dispose();

    super.dispose();
  }


  void unfocusSearchBar() {
    _searchFocusNode.unfocus();
  }

  void _onSearchChanged() {
    if (_searchQuery != _searchController.text) {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    }
  }

  void _handleTabSelection() {
    if (_tabController.indexIsChanging) {
      unfocusSearchBar();
      if (_tabController.index == 1) {
        final countryProvider =
        Provider.of<CountryProvider>(context, listen: false);
        if (countryProvider.localCountries.isEmpty &&
            !countryProvider.isLocalLoading) {
          _fetchLocalData();
        }
      }
    }
  }

  Future<void> _fetchInternationalData() async {
    final token = _authProvider.userToken;
    if (token != null) {
      await Future.wait([
        Provider.of<AdProvider>(context, listen: false)
            .fetchInternationalAds(token),
        Provider.of<CountryProvider>(context, listen: false)
            .fetchInternationalCountries(token),
      ]);
      if (mounted) {
        setState(() {});
      }
    } else {
      print("User token is null, cannot fetch international data.");
    }
  }

  Future<void> _fetchLocalData() async {
    final token = _authProvider.userToken;
    if (token != null) {
      await Future.wait([
        Provider.of<AdProvider>(context, listen: false).fetchLocalAds(token),
        Provider.of<CountryProvider>(context, listen: false)
            .fetchLocalCountries(token),
      ]);
      if (mounted) {
        setState(() {});
      }
    } else {
      print("User token is null, cannot fetch local data.");
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFF294FB6),
        title: Text(
          s.appName,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: GestureDetector(
        onTap: () => unfocusSearchBar(),
        child: Column(
          children: [
            Container(
              decoration: const BoxDecoration(
                color: Color(0xFF294FB6),
              ),
              child: TabBar(
                indicatorSize: TabBarIndicatorSize.tab,
                controller: _tabController,
                indicator: BoxDecoration(
                  color: Colors.white.withOpacity(0.3),
                ),
                overlayColor: WidgetStateProperty.all(Colors.amber),
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white.withOpacity(0.7),
                labelStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
                tabs: [
                  Tab(text: s.internationalTab),
                  Tab(text: s.localTab),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildInternationalTab(context),
                  _buildLocalTab(context),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- TAB BUILDERS ---

  Widget _buildInternationalTab(BuildContext context) {
    final s = AppLocalizations.of(context)!;
    return RefreshIndicator(
      onRefresh: _fetchInternationalData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: _buildSearchBar(s),
            ),
            const SizedBox(height: 30),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child:
              Text(s.advertisementsSection, style: _sectionTitleStyle()),
            ),
            const SizedBox(height: 15),
            _buildInternationalAdvertisementsList(s),
            const SizedBox(height: 30),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Text(s.tripsLabel, style: _sectionTitleStyle()),
            ),
            const SizedBox(height: 15),
            _buildInternationalTripsGrid(s),
          ],
        ),
      ),
    );
  }

  Widget _buildLocalTab(BuildContext context) {
    final s = AppLocalizations.of(context)!;
    return RefreshIndicator(
      onRefresh: _fetchLocalData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: _buildSearchBar(s),
            ),
            const SizedBox(height: 30),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child:
              Text(s.advertisementsSection, style: _sectionTitleStyle()),
            ),
            const SizedBox(height: 15),
            _buildLocalAdvertisementsList(s),
            const SizedBox(height: 30),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Text(s.tripsLabel, style: _sectionTitleStyle()),
            ),
            const SizedBox(height: 15),
            _buildLocalTripsGrid(s),
          ],
        ),
      ),
    );
  }

  // --- WIDGET BUILDERS ---

  TextStyle _sectionTitleStyle() {
    return TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w600,
      color: Colors.grey[800],
    );
  }

  Widget _buildSearchBar(AppLocalizations s) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 5,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        focusNode: _searchFocusNode,
        decoration: InputDecoration(
          hintText: s.searchHint,
          hintStyle: TextStyle(color: Colors.grey[400], fontSize: 16),
          prefixIcon: Icon(Icons.search, color: Colors.grey[400]),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 15,
          ),
        ),
      ),
    );
  }

  Widget _buildEmptySection({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20.0),
      height: MediaQuery.of(context).size.height / 4.8,
      width: double.infinity,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
          color: Colors.blueGrey.withOpacity(0.05),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.blueGrey.withOpacity(0.1))),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 40,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 10),
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 5),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdsLoadingPlaceholder() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: SizedBox(
        height: 250,
        child: ListView.builder(
          physics: const NeverScrollableScrollPhysics(),
          scrollDirection: Axis.horizontal,
          itemCount: 2,
          itemBuilder: (context, index) {
            return Container(
              margin: const EdgeInsets.only(bottom: 5, right: 15),
              width: 250,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildTripsLoadingPlaceholder() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: 4,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 15,
          mainAxisSpacing: 15,
          childAspectRatio: 0.9,
        ),
        itemBuilder: (context, index) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Container(
                height: 16,
                width: 100,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // --- MODIFIED: Ads list with new animation logic and finite count ---
  Widget _buildAdvertisementsList(
      AppLocalizations s, List<dynamic> ads, bool isLoading) {
    if (isLoading && ads.isEmpty) {
      return _buildAdsLoadingPlaceholder();
    }

    final filteredAds = _searchQuery.isEmpty
        ? ads
        : ads
        .where((ad) => ad.name.toLowerCase().contains(_searchQuery))
        .toList();

    if (filteredAds.isEmpty) {
      return _buildEmptySection(
        icon: Icons.campaign_outlined,
        title: s.noAdsFoundTitle,
        subtitle: s.noAdsFoundSubtitle,
      );
    }

    return SizedBox(
      height: 250,
      child: PageView.builder(
        controller: _adPageController,
        itemCount: filteredAds.length, // Use the actual item count
        clipBehavior: Clip.none, // Allow larger items to draw outside bounds
        itemBuilder: (context, index) {
          final ad = filteredAds[index];
          double scale = 1.0;
          double opacity = 1.0;

          if (_adPageController.position.haveDimensions) {
            // Calculate the difference from the center page
            double pageDifference = (_adPage - index).abs();

            // Create a scale effect that is largest at the center (0 difference)
            // and smaller on the sides. Clamped between 85% and 100%.
            scale = (1 - (pageDifference * 0.15)).clamp(0.85, 1.0);

            // Opacity effect: Center card is 100% opaque, side cards are faded
            opacity = (1 - (pageDifference * 0.5)).clamp(0.5, 1.0);
          }

          // Apply the calculated scale and opacity to the card
          return Transform.scale(
            scale: scale,
            child: Opacity(
              opacity: opacity,
              child: _buildDestinationCard(
                context,
                ad.id,
                ad.name,
                '${ad.endDate.difference(ad.startDate).inDays} ${s.days}',
                '${ad.price} SAR',
                ad.rating.toDouble(),
                ad.images.first,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildInternationalAdvertisementsList(AppLocalizations s) {
    return Consumer<AdProvider>(
      builder: (context, adProvider, child) {
        return _buildAdvertisementsList(
            s, adProvider.internationalAds, adProvider.isInternationalLoading);
      },
    );
  }

  Widget _buildLocalAdvertisementsList(AppLocalizations s) {
    return Consumer<AdProvider>(
      builder: (context, adProvider, child) {
        return _buildAdvertisementsList(
            s, adProvider.localAds, adProvider.isLocalLoading);
      },
    );
  }

  Widget _buildInternationalTripsGrid(AppLocalizations s) {
    return Consumer<CountryProvider>(
      builder: (context, countryProvider, child) {
        if (countryProvider.isInternationalLoading &&
            countryProvider.internationalCountries.isEmpty) {
          return _buildTripsLoadingPlaceholder();
        }
        if (countryProvider.internationalError != null) {
          return Center(
              child: Text('Error: ${countryProvider.internationalError}'));
        }

        final filteredCountries = _searchQuery.isEmpty
            ? countryProvider.internationalCountries
            : countryProvider.internationalCountries
            .where((country) =>
            country.name.toLowerCase().contains(_searchQuery))
            .toList();

        if (filteredCountries.isEmpty) {
          return _buildEmptySection(
            icon: Icons.explore_outlined,
            title: s.noTripsFoundTitle,
            subtitle: s.noTripsFoundSubtitle,
          );
        }

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding:
          const EdgeInsets.symmetric(horizontal: 20), // Add padding here
          itemCount: filteredCountries.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 15,
            mainAxisSpacing: 15,
            childAspectRatio: 0.9,
          ),
          itemBuilder: (context, index) {
            final country = filteredCountries[index];
            return _buildCountryGridItem(context, country)
                .animate()
                .fadeIn(delay: (index % 2 * 100).ms, duration: 500.ms)
                .slideY(begin: 0.3, duration: 400.ms, curve: Curves.easeOut);
          },
        );
      },
    );
  }

  Widget _buildLocalTripsGrid(AppLocalizations s) {
    return Consumer<CountryProvider>(
      builder: (context, countryProvider, child) {
        if (countryProvider.isLocalLoading &&
            countryProvider.localCountries.isEmpty) {
          return _buildTripsLoadingPlaceholder();
        }
        if (countryProvider.localError != null) {
          return Center(child: Text('Error: ${countryProvider.localError}'));
        }

        final filteredCountries = _searchQuery.isEmpty
            ? countryProvider.localCountries
            : countryProvider.localCountries
            .where((country) =>
            country.name.toLowerCase().contains(_searchQuery))
            .toList();

        if (filteredCountries.isEmpty) {
          return _buildEmptySection(
            icon: Icons.explore_outlined,
            title: s.noTripsFoundTitle,
            subtitle: s.noTripsFoundSubtitle,
          );
        }

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding:
          const EdgeInsets.symmetric(horizontal: 20), // Add padding here
          itemCount: filteredCountries.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 15,
            mainAxisSpacing: 15,
            childAspectRatio: 0.9,
          ),
          itemBuilder: (context, index) {
            final country = filteredCountries[index];
            return _buildCountryGridItem(context, country)
                .animate()
                .fadeIn(delay: (index % 2 * 100).ms, duration: 500.ms)
                .slideY(begin: 0.3, duration: 400.ms, curve: Curves.easeOut);
          },
        );
      },
    );
  }

  Widget _buildDestinationCard(
      BuildContext context,
      String activityId,
      String destination,
      String duration,
      String price,
      double rating,
      String imageUrl,
      ) {
    return GestureDetector(
      onTap: () {
        unfocusSearchBar();
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                ActivityDetailsScreen(activityId: activityId),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.25),
              blurRadius: 4,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: MediaQuery.of(context).size.height / 7.3,
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(15),
                  topRight: Radius.circular(15),
                ),
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(15),
                  topRight: Radius.circular(15),
                ),
                child: Stack(
                  children: [
                    _buildImage(imageUrl),
                    Positioned(
                      top: 10,
                      right: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.star,
                                color: Colors.amber, size: 16),
                            const SizedBox(width: 4),
                            Text(
                              rating.toString(),
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    destination,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[800],
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    duration,
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    price,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF294FB6),
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

  Widget _buildCountryGridItem(BuildContext context, Country country) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () {
              unfocusSearchBar();
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => ActivitiesScreen(
                      countryId: country.id,
                      countryName: country.name,
                    )),
              );
            },
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 3,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: _buildTripImageGrid(country.images),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 10, left: 4),
          child: Text(
            country.name,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildTripImageGrid(List<String> images) {
    if (images.isEmpty) {
      return Container(
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(15),
        ),
        child: const Center(
            child: Icon(Icons.image_not_supported_outlined,
                color: Colors.grey)),
      );
    }

    switch (images.length) {
      case 1:
        return _buildOneImage(images);
      case 2:
        return _buildTwoImages(images);
      case 3:
        return _buildThreeImages(images);
      default:
        return _buildFourOrMoreImages(images);
    }
  }

  Widget _buildImage(String url) {
    return Image.network(
      url,
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
      loadingBuilder: (BuildContext context, Widget child,
          ImageChunkEvent? loadingProgress) {
        if (loadingProgress == null) {
          return child;
        }
        return Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Container(
            color: Colors.white,
          ),
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
      frameBuilder: (BuildContext context, Widget child, int? frame,
          bool wasSynchronouslyLoaded) {
        if (wasSynchronouslyLoaded) {
          return child;
        }
        return AnimatedOpacity(
          opacity: frame == null ? 0 : 1,
          duration: const Duration(seconds: 1),
          curve: Curves.easeOut,
          child: child,
        );
      },
    );
  }

  Widget _buildOneImage(List<String> images) {
    return _buildImage(images[0]);
  }

  Widget _buildTwoImages(List<String> images) {
    return Row(
      children: [
        Expanded(child: _buildImage(images[0])),
        const SizedBox(width: 2),
        Expanded(child: _buildImage(images[1])),
      ],
    );
  }

  Widget _buildThreeImages(List<String> images) {
    return Row(
      children: [
        Expanded(
          flex: 1,
          child: _buildImage(images[0]),
        ),
        const SizedBox(width: 2),
        Expanded(
          flex: 1,
          child: Column(
            children: [
              Expanded(child: _buildImage(images[1])),
              const SizedBox(height: 2),
              Expanded(child: _buildImage(images[2])),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFourOrMoreImages(List<String> images) {
    return Column(
      children: [
        Expanded(
          child: Row(
            children: [
              Expanded(child: _buildImage(images[0])),
              const SizedBox(width: 2),
              Expanded(child: _buildImage(images[1])),
            ],
          ),
        ),
        const SizedBox(height: 2),
        Expanded(
          child: Row(
            children: [
              Expanded(child: _buildImage(images[2])),
              const SizedBox(width: 2),
              Expanded(child: _buildImage(images[3])),
            ],
          ),
        ),
      ],
    );
  }
}