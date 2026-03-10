import 'package:flutter/foundation.dart';
import '../models/follow_card_model.dart';
import '../models/search_result_model.dart';
import '../models/filter_dto.dart';
import '../services/follow_service.dart';
import '../services/search_service.dart';
import '../utils/api_exception.dart';

class SearchProvider extends ChangeNotifier {
  final SearchService _service = SearchService();
  final FollowService _followService = FollowService();

  List<SearchSuggestion> _suggestions = [];
  List<FollowCardModel> _followCards = [];
  Map<String, dynamic>? _searchResults;
  Map<String, dynamic>? _popular;
  List<dynamic> _history = [];
  bool _isLoading = false;
  String? _error;

  List<SearchSuggestion> get suggestions => _suggestions;
  List<FollowCardModel> get followCards => _followCards;
  Map<String, dynamic>? get searchResults => _searchResults;
  Map<String, dynamic>? get popular => _popular;
  List<dynamic> get history => _history;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchSuggestions(String query) async {
    final normalized = query.trim();
    if (normalized.isEmpty) {
      _suggestions = [];
      notifyListeners();
      return;
    }

    try {
      _suggestions = await _service.getSuggestions(normalized);
      notifyListeners();
    } catch (e) {
      debugPrint('SearchProvider.fetchSuggestions: $e');
    }
  }

  Future<void> search(String query, {String? category, FilterDto? filter}) async {
    final normalized = query.trim();
    if (normalized.isEmpty) {
      _searchResults = {'serviceProviders': [], 'businesses': [], 'amenities': []};
      _isLoading = false;
      _error = null;
      notifyListeners();
      return;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _searchResults = await _service.search(
        normalized,
        category: category,
        filter: filter,
      );
      // Save search to history in the background
      _service.saveHistory(normalized).catchError((_) {});
      _isLoading = false;
      notifyListeners();
    } on ApiException catch (e) {
      _error = e.message;
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchPopular({bool force = false, FilterDto? filter}) async {
    if (!force && _popular != null) return;

    try {
      _popular = await _service.getPopular(filter: filter);
      final rawCards = (_popular?['followCards'] as List?) ?? const [];
      _followCards = rawCards
          .whereType<Map>()
          .map((e) => FollowCardModel.fromJson(Map<String, dynamic>.from(e)))
          .toList();
      notifyListeners();
    } catch (e) {
      debugPrint('SearchProvider.fetchPopular: $e');
    }
  }

  Future<void> toggleFollow(FollowCardModel card) async {
    final index = _followCards.indexWhere(
      (item) => item.id == card.id && item.entityType == card.entityType,
    );
    if (index == -1) return;

    final existing = _followCards[index];
    if (!existing.isFollowEnabled) return;

    final optimisticFollowing = !existing.isFollowing;
    final optimisticFollowers = optimisticFollowing
        ? existing.followersCount + 1
        : (existing.followersCount > 0 ? existing.followersCount - 1 : 0);

    _followCards[index] = existing.copyWith(
      isFollowing: optimisticFollowing,
      followersCount: optimisticFollowers,
    );
    notifyListeners();

    try {
      final result = await _followService.toggleFollow(
        entityType: existing.entityType,
        entityId: existing.id,
      );
      _followCards[index] = existing.copyWith(
        isFollowing: result['isFollowing'] == true,
        followersCount: result['followersCount'] as int? ?? optimisticFollowers,
      );
    } on ApiException catch (e) {
      _error = e.message;
      _followCards[index] = existing;
    } catch (_) {
      _followCards[index] = existing;
    }

    notifyListeners();
  }

  void clearResults() {
    _searchResults = null;
    _suggestions = [];
    notifyListeners();
  }

  Future<void> fetchHistory() async {
    try {
      _history = await _service.getHistory();
      notifyListeners();
    } catch (e) {
      debugPrint('SearchProvider.fetchHistory: $e');
    }
  }

  Future<void> saveToHistory(String query) async {
    if (query.trim().isEmpty) return;
    try {
      await _service.saveHistory(query.trim());
      await fetchHistory();
    } catch (e) {
      debugPrint('SearchProvider.saveToHistory: $e');
    }
  }

  Future<void> deleteFromHistory({String? id}) async {
    try {
      await _service.deleteHistory(id: id);
      if (id != null) {
        _history.removeWhere((e) => e['id'] == id);
      } else {
        _history = [];
      }
      notifyListeners();
    } catch (e) {
      debugPrint('SearchProvider.deleteFromHistory: $e');
    }
  }
}
