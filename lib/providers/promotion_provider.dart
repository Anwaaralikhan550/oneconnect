import 'package:flutter/foundation.dart';
import '../models/promotion_model.dart';
import '../services/promotion_service.dart';
import '../utils/api_exception.dart';

class PromotionProvider extends ChangeNotifier {
  final PromotionService _service = PromotionService();

  List<PromotionModel> _promotions = [];
  bool _isLoading = false;
  String? _error;

  List<PromotionModel> get promotions => _promotions;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchPromotions() async {
    if (_promotions.isNotEmpty) {
      notifyListeners();
      return;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _promotions = await _service.getAll();
      _isLoading = false;
      notifyListeners();
    } on ApiException catch (e) {
      _error = e.message;
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearCache() {
    _promotions.clear();
    notifyListeners();
  }
}
