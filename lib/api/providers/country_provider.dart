// lib/api/providers/country_provider.dart
import 'package:flutter/material.dart';
import '../../models/country_model.dart';
import '../services/country_service.dart';

class CountryProvider with ChangeNotifier {
  final CountryService _countryService = CountryService();

  // State for International Countries
  List<Country> _internationalCountries = [];
  bool _isInternationalLoading = false;
  String? _internationalError;

  List<Country> get internationalCountries => _internationalCountries;
  bool get isInternationalLoading => _isInternationalLoading;
  String? get internationalError => _internationalError;

  // State for Local Countries
  List<Country> _localCountries = [];
  bool _isLocalLoading = false;
  String? _localError;

  List<Country> get localCountries => _localCountries;
  bool get isLocalLoading => _isLocalLoading;
  String? get localError => _localError;

  Future<void> fetchInternationalCountries(String token) async {
    _isInternationalLoading = true;
    _internationalError = null;
    notifyListeners();

    try {
      _internationalCountries = await _countryService.getInternationalCountries(token);
    } catch (e) {
      _internationalError = e.toString();
    } finally {
      _isInternationalLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchLocalCountries(String token) async {
    _isLocalLoading = true;
    _localError = null;
    notifyListeners();

    try {
      _localCountries = await _countryService.getLocalCountries(token);
    } catch (e) {
      _localError = e.toString();
    } finally {
      _isLocalLoading = false;
      notifyListeners();
    }
  }
}