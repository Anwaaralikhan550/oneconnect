import 'package:flutter/foundation.dart';
import '../models/review_model.dart';
import '../services/service_provider_service.dart';
import '../services/business_service.dart';
import '../services/amenity_service.dart';
import '../utils/api_exception.dart';

class ReviewProvider extends ChangeNotifier {
  final ServiceProviderService _spService = ServiceProviderService();
  final BusinessService _bizService = BusinessService();
  final AmenityService _amenityService = AmenityService();

  bool _isSubmitting = false;
  String? _error;
  ReviewModel? _lastSubmittedReview;

  bool get isSubmitting => _isSubmitting;
  String? get error => _error;
  ReviewModel? get lastSubmittedReview => _lastSubmittedReview;

  /// Submit a review for a service provider
  Future<bool> submitServiceProviderReview(
    String providerId, {
    required double rating,
    String? ratingText,
    String? reviewText,
  }) async {
    _isSubmitting = true;
    _error = null;
    _lastSubmittedReview = null;
    notifyListeners();

    try {
      _lastSubmittedReview = await _spService.addReview(
        providerId,
        rating: rating,
        ratingText: ratingText,
        reviewText: reviewText,
      );
      _isSubmitting = false;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      _isSubmitting = false;
      notifyListeners();
      return false;
    }
  }

  /// Submit a review for a business or amenity
  Future<bool> submitBusinessReview(
    String businessId, {
    required double rating,
    String? ratingText,
    String? reviewText,
  }) async {
    _isSubmitting = true;
    _error = null;
    _lastSubmittedReview = null;
    notifyListeners();

    try {
      _lastSubmittedReview = await _bizService.addReview(
        businessId,
        rating: rating,
        ratingText: ratingText,
        reviewText: reviewText,
      );
      _isSubmitting = false;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      _isSubmitting = false;
      notifyListeners();
      return false;
    }
  }

  /// Submit a review for an amenity
  Future<bool> submitAmenityReview(
    String amenityId, {
    required double rating,
    String? ratingText,
    String? reviewText,
  }) async {
    _isSubmitting = true;
    _error = null;
    _lastSubmittedReview = null;
    notifyListeners();

    try {
      _lastSubmittedReview = await _amenityService.addReview(
        amenityId,
        rating: rating,
        ratingText: ratingText,
        reviewText: reviewText,
      );
      _isSubmitting = false;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      _isSubmitting = false;
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
