import 'package:flutter/foundation.dart';
import '../models/review_model.dart';
import '../services/service_provider_service.dart';
import '../services/business_service.dart';
import '../services/amenity_service.dart';
import '../services/user_service.dart';
import '../utils/api_exception.dart';

class ReviewProvider extends ChangeNotifier {
  final ServiceProviderService _spService = ServiceProviderService();
  final BusinessService _bizService = BusinessService();
  final AmenityService _amenityService = AmenityService();
  final UserService _userService = UserService();

  bool _isSubmitting = false;
  String? _error;
  ReviewModel? _lastSubmittedReview;
  String? _pendingMediaUrl;
  String? _pendingMediaType;

  bool get isSubmitting => _isSubmitting;
  String? get error => _error;
  ReviewModel? get lastSubmittedReview => _lastSubmittedReview;

  Future<void> setPendingMediaFromFile(String filePath, {String mediaType = 'PHOTO'}) async {
    final url = await _userService.uploadReviewMedia(filePath);
    _pendingMediaUrl = url;
    _pendingMediaType = mediaType;
  }

  void clearPendingMedia() {
    _pendingMediaUrl = null;
    _pendingMediaType = null;
  }

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
        mediaUrl: _pendingMediaUrl,
        mediaType: _pendingMediaType,
      );
      clearPendingMedia();
      _isSubmitting = false;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      clearPendingMedia();
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
        mediaUrl: _pendingMediaUrl,
        mediaType: _pendingMediaType,
      );
      clearPendingMedia();
      _isSubmitting = false;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      clearPendingMedia();
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
        mediaUrl: _pendingMediaUrl,
        mediaType: _pendingMediaType,
      );
      clearPendingMedia();
      _isSubmitting = false;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      clearPendingMedia();
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
