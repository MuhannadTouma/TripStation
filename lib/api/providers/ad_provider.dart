// lib/providers/ad_provider.dart
import 'package:flutter/material.dart';
import '../../models/ad_model.dart';
import '../services/ad_service.dart';

class AdProvider with ChangeNotifier {
  final AdService _adService = AdService();

  // State for International Ads
  List<Ad> _internationalAds = [];
  bool _isInternationalLoading = false;
  String? _internationalError;

  List<Ad> get internationalAds => _internationalAds;
  bool get isInternationalLoading => _isInternationalLoading;
  String? get internationalError => _internationalError;

  // State for Local Ads
  List<Ad> _localAds = [];
  bool _isLocalLoading = false;
  String? _localError;

  List<Ad> get localAds => _localAds;
  bool get isLocalLoading => _isLocalLoading;
  String? get localError => _localError;

  Future<void> fetchInternationalAds(String token) async {
    _isInternationalLoading = true;
    _internationalError = null;
    notifyListeners();
    try {
      _internationalAds = await _adService.getInternationalAds(token);
    } catch (e) {
      _internationalError = e.toString();
    } finally {
      _isInternationalLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchLocalAds(String token) async {
    _isLocalLoading = true;
    _localError = null;
    notifyListeners();
    try {
      _localAds = await _adService.getLocalAds(token);
    } catch (e) {
      _localError = e.toString();
    } finally {
      _isLocalLoading = false;
      notifyListeners();
    }
  }
}