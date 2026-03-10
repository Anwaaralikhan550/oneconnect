import 'package:flutter/foundation.dart';
import '../models/filter_dto.dart';
import '../models/business_model.dart';
import '../models/amenity_model.dart';
import '../models/review_model.dart';
import '../services/business_service.dart';
import '../services/amenity_service.dart';
import '../utils/api_exception.dart';

class BusinessProvider extends ChangeNotifier {
  final BusinessService _businessService = BusinessService();
  final AmenityService _amenityService = AmenityService();

  final Map<String, List<BusinessModel>> _businessesByCategory = {};
  final Map<String, List<AmenityModel>> _amenitiesByType = {};
  final Map<String, BusinessModel> _businessDetails = {};
  final Map<String, AmenityModel> _amenityDetails = {};
  bool _isLoading = false;
  String? _error;

  List<BusinessModel> getBusinesses(String category, {FilterDto? filter}) =>
      _businessesByCategory['$category|${filter?.cacheKey ?? ''}'] ?? [];

  List<AmenityModel> getAmenities(String type, {FilterDto? filter}) =>
      _amenitiesByType['$type|${filter?.cacheKey ?? ''}'] ?? [];

  BusinessModel? getBusinessDetail(String id) => _businessDetails[id];
  AmenityModel? getAmenityDetail(String id) => _amenityDetails[id];

  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchBusinesses(
    String category, {
    FilterDto? filter,
    bool force = false,
  }) async {
    final key = '$category|${filter?.cacheKey ?? ''}';
    if (!force && _businessesByCategory.containsKey(key)) {
      notifyListeners();
      return;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _businessesByCategory[key] = await _businessService.getByCategory(
        category,
        filter: filter,
      );
      _isLoading = false;
      notifyListeners();
    } on ApiException catch (e) {
      _error = e.message;
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchAmenities(
    String type, {
    FilterDto? filter,
    bool force = false,
  }) async {
    final key = '$type|${filter?.cacheKey ?? ''}';
    if (!force && _amenitiesByType.containsKey(key)) {
      notifyListeners();
      return;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _amenitiesByType[key] = await _amenityService.getByType(
        type,
        filter: filter,
      );
      _isLoading = false;
      notifyListeners();
    } on ApiException catch (e) {
      _error = e.message;
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchBusinessDetail(String id) async {
    if (_businessDetails.containsKey(id)) {
      notifyListeners();
      return;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _businessDetails[id] = await _businessService.getById(id);
      _isLoading = false;
      notifyListeners();
    } on ApiException catch (e) {
      _error = e.message;
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchAmenityDetail(String id) async {
    if (_amenityDetails.containsKey(id)) {
      notifyListeners();
      return;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _amenityDetails[id] = await _amenityService.getById(id);
      _isLoading = false;
      notifyListeners();
    } on ApiException catch (e) {
      _error = e.message;
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshBusinessDetail(String id) async {
    _businessDetails.remove(id);
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _businessDetails[id] = await _businessService.getById(id);
      _isLoading = false;
      notifyListeners();
    } on ApiException catch (e) {
      _error = e.message;
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshAmenityDetail(String id) async {
    _amenityDetails.remove(id);
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _amenityDetails[id] = await _amenityService.getById(id);
      _isLoading = false;
      notifyListeners();
    } on ApiException catch (e) {
      _error = e.message;
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> voteAmenityReview(String amenityId, String reviewId, String voteType) async {
    final detail = _amenityDetails[amenityId];
    if (detail == null) return;

    final oldReviews = List<ReviewModel>.from(detail.reviews);
    final updatedReviews = detail.reviews.map((r) {
      if (r.id != reviewId) return r;
      if (r.userVote == voteType) {
        return r.copyWith(
          helpfulCount: voteType == 'helpful' ? r.helpfulCount - 1 : r.helpfulCount,
          unhelpfulCount: voteType == 'unhelpful' ? r.unhelpfulCount - 1 : r.unhelpfulCount,
          clearUserVote: true,
        );
      } else {
        return r.copyWith(
          helpfulCount: voteType == 'helpful' ? r.helpfulCount + 1 : (r.userVote == 'helpful' ? r.helpfulCount - 1 : r.helpfulCount),
          unhelpfulCount: voteType == 'unhelpful' ? r.unhelpfulCount + 1 : (r.userVote == 'unhelpful' ? r.unhelpfulCount - 1 : r.unhelpfulCount),
          userVote: voteType,
        );
      }
    }).toList();

    _amenityDetails[amenityId] = detail.copyWith(reviews: updatedReviews);
    notifyListeners();

    try {
      final result = await _amenityService.voteReview(amenityId, reviewId, voteType);
      final serverReviews = _amenityDetails[amenityId]!.reviews.map((r) {
        if (r.id != reviewId) return r;
        return r.copyWith(
          helpfulCount: result['helpfulCount'] as int? ?? r.helpfulCount,
          unhelpfulCount: result['unhelpfulCount'] as int? ?? r.unhelpfulCount,
          userVote: result['currentUserVote'] as String?,
          clearUserVote: result['currentUserVote'] == null,
        );
      }).toList();
      _amenityDetails[amenityId] = detail.copyWith(reviews: serverReviews);
      notifyListeners();
    } catch (_) {
      _amenityDetails[amenityId] = detail.copyWith(reviews: oldReviews);
      notifyListeners();
    }
  }

  Future<void> voteBusinessReview(String businessId, String reviewId, String voteType) async {
    final detail = _businessDetails[businessId];
    if (detail == null) return;

    final oldReviews = List<ReviewModel>.from(detail.reviews);
    final updatedReviews = detail.reviews.map((r) {
      if (r.id != reviewId) return r;
      if (r.userVote == voteType) {
        return r.copyWith(
          helpfulCount: voteType == 'helpful' ? r.helpfulCount - 1 : r.helpfulCount,
          unhelpfulCount: voteType == 'unhelpful' ? r.unhelpfulCount - 1 : r.unhelpfulCount,
          clearUserVote: true,
        );
      }
      return r.copyWith(
        helpfulCount: voteType == 'helpful' ? r.helpfulCount + 1 : (r.userVote == 'helpful' ? r.helpfulCount - 1 : r.helpfulCount),
        unhelpfulCount: voteType == 'unhelpful' ? r.unhelpfulCount + 1 : (r.userVote == 'unhelpful' ? r.unhelpfulCount - 1 : r.unhelpfulCount),
        userVote: voteType,
      );
    }).toList();

    _businessDetails[businessId] = detail.copyWith(reviews: updatedReviews);
    notifyListeners();

    try {
      final result = await _businessService.voteReview(businessId, reviewId, voteType);
      final serverReviews = _businessDetails[businessId]!.reviews.map((r) {
        if (r.id != reviewId) return r;
        return r.copyWith(
          helpfulCount: result['helpfulCount'] as int? ?? r.helpfulCount,
          unhelpfulCount: result['unhelpfulCount'] as int? ?? r.unhelpfulCount,
          userVote: result['currentUserVote'] as String?,
          clearUserVote: result['currentUserVote'] == null,
        );
      }).toList();
      _businessDetails[businessId] = detail.copyWith(reviews: serverReviews);
      notifyListeners();
    } catch (_) {
      _businessDetails[businessId] = detail.copyWith(reviews: oldReviews);
      notifyListeners();
    }
  }

  void applySubmittedAmenityReview(String amenityId, ReviewModel review) {
    final detail = _amenityDetails[amenityId];
    if (detail == null) return;
    final newCount = detail.reviewCount + 1;
    final newRating = (((detail.rating * detail.reviewCount) + review.rating) / newCount);
    _amenityDetails[amenityId] = detail.copyWith(
      rating: double.parse(newRating.toStringAsFixed(1)),
      reviewCount: newCount,
      reviews: [review, ...detail.reviews],
    );
    notifyListeners();
  }

  void applySubmittedBusinessReview(String businessId, ReviewModel review) {
    final detail = _businessDetails[businessId];
    if (detail == null) return;
    final newCount = detail.reviewCount + 1;
    final newRating = (((detail.rating * detail.reviewCount) + review.rating) / newCount);
    _businessDetails[businessId] = detail.copyWith(
      rating: double.parse(newRating.toStringAsFixed(1)),
      reviewCount: newCount,
      reviews: [review, ...detail.reviews],
    );
    notifyListeners();
  }

  void clearCache() {
    _businessesByCategory.clear();
    _amenitiesByType.clear();
    _businessDetails.clear();
    _amenityDetails.clear();
    notifyListeners();
  }
}
