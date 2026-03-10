import 'package:flutter/foundation.dart';
import '../models/filter_dto.dart';
import '../models/service_provider_model.dart';
import '../models/review_model.dart';
import '../services/service_provider_service.dart';
import '../utils/api_exception.dart';

class ServiceProviderProvider extends ChangeNotifier {
  final ServiceProviderService _service = ServiceProviderService();

  // Cache by service type
  final Map<String, List<ServiceProviderModel>> _providersByType = {};
  final Map<String, ServiceProviderModel> _providerDetails = {};
  final Map<String, List<MediaItem>> _providerMedia = {};
  bool _isLoading = false;
  String? _error;

  List<ServiceProviderModel> getProviders(String type, {FilterDto? filter}) =>
      _providersByType['$type|${filter?.cacheKey ?? ''}'] ?? [];

  ServiceProviderModel? getDetail(String id) => _providerDetails[id];
  List<MediaItem> getProviderMedia(String id) => _providerMedia[id] ?? const [];
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchByType(
    String type, {
    FilterDto? filter,
    String? city,
    bool force = false,
  }) async {
    final key = '$type|${filter?.cacheKey ?? ''}';
    if (force) {
      _providersByType.remove(key);
    }
    // Return cached if available
    if (!force && _providersByType.containsKey(key)) {
      notifyListeners();
      return;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final providers = await _service.getByType(
        type,
        filter: filter,
        city: city,
      );
      _providersByType[key] = providers;
      _isLoading = false;
      notifyListeners();
    } on ApiException catch (e) {
      _error = e.message;
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchDetail(String id) async {
    if (_providerDetails.containsKey(id)) {
      notifyListeners();
      return;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _providerDetails[id] = await _service.getById(id);
      _isLoading = false;
      notifyListeners();
    } on ApiException catch (e) {
      _error = e.message;
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Force-refresh detail data (bypasses cache)
  Future<void> refreshDetail(String id) async {
    _providerDetails.remove(id);
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _providerDetails[id] = await _service.getById(id);
      _isLoading = false;
      notifyListeners();
    } on ApiException catch (e) {
      _error = e.message;
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Vote on a review (helpful/unhelpful) with optimistic update
  Future<void> voteReview(String providerId, String reviewId, String voteType) async {
    final detail = _providerDetails[providerId];
    if (detail == null) return;

    // Save snapshot for revert
    final oldReviews = List<ReviewModel>.from(detail.reviews);

    // Optimistic update
    final updatedReviews = detail.reviews.map((review) {
      if (review.id != reviewId) return review;

      if (review.userVote == voteType) {
        // Toggle off
        return review.copyWith(
          helpfulCount: voteType == 'helpful' ? review.helpfulCount - 1 : null,
          unhelpfulCount: voteType == 'unhelpful' ? review.unhelpfulCount - 1 : null,
          clearUserVote: true,
        );
      } else {
        // Switch vote or new vote
        int helpfulDelta = 0;
        int unhelpfulDelta = 0;
        if (review.userVote == 'helpful') helpfulDelta = -1;
        if (review.userVote == 'unhelpful') unhelpfulDelta = -1;
        if (voteType == 'helpful') helpfulDelta += 1;
        if (voteType == 'unhelpful') unhelpfulDelta += 1;

        return review.copyWith(
          helpfulCount: review.helpfulCount + helpfulDelta,
          unhelpfulCount: review.unhelpfulCount + unhelpfulDelta,
          userVote: voteType,
        );
      }
    }).toList();

    _providerDetails[providerId] = detail.copyWithReviews(updatedReviews);
    notifyListeners();

    try {
      final result = await _service.voteReview(providerId, reviewId, voteType);
      // Update with server-authoritative counts
      final serverReviews = _providerDetails[providerId]!.reviews.map((review) {
        if (review.id != reviewId) return review;
        return review.copyWith(
          helpfulCount: result['helpfulCount'] ?? review.helpfulCount,
          unhelpfulCount: result['unhelpfulCount'] ?? review.unhelpfulCount,
          userVote: result['currentUserVote'],
          clearUserVote: result['currentUserVote'] == null,
        );
      }).toList();
      _providerDetails[providerId] = _providerDetails[providerId]!.copyWithReviews(serverReviews);
      notifyListeners();
    } catch (_) {
      // Revert on failure
      _providerDetails[providerId] = detail.copyWithReviews(oldReviews);
      notifyListeners();
    }
  }

  Future<bool> toggleFavorite(String id) async {
    try {
      return await _service.toggleFavorite(id);
    } catch (_) {
      return false;
    }
  }

  Future<void> fetchProviderMedia(String id, {bool force = false}) async {
    if (!force && _providerMedia.containsKey(id)) {
      notifyListeners();
      return;
    }

    try {
      _providerMedia[id] = await _service.getProviderMedia(id);
      notifyListeners();
    } on ApiException catch (e) {
      _error = e.message;
      notifyListeners();
    }
  }

  void applySubmittedReview(String providerId, ReviewModel review) {
    final detail = _providerDetails[providerId];
    if (detail == null) return;

    final newCount = detail.reviewCount + 1;
    final newRating = newCount > 0
        ? (((detail.rating * detail.reviewCount) + review.rating) / newCount)
        : review.rating;
    final updatedReviews = [review, ...detail.reviews];

    _providerDetails[providerId] = detail.copyWith(
      rating: double.parse(newRating.toStringAsFixed(1)),
      reviewCount: newCount,
      reviews: updatedReviews,
    );
    notifyListeners();
  }

  void clearCache() {
    _providersByType.clear();
    _providerDetails.clear();
    _providerMedia.clear();
    notifyListeners();
  }
}
