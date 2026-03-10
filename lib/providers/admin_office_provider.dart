import 'package:flutter/foundation.dart';
import '../models/search_result_model.dart';
import '../services/admin_office_service.dart';
import '../utils/api_exception.dart';

class AdminOfficeProvider extends ChangeNotifier {
  final AdminOfficeService _service = AdminOfficeService();

  List<AdminOfficeModel> _offices = [];
  final Map<String, AdminOfficeModel> _officeDetails = {};
  bool _isLoading = false;
  String? _error;

  List<AdminOfficeModel> get offices => _offices;
  AdminOfficeModel? getDetail(String id) => _officeDetails[id];
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchOffices() async {
    if (_offices.isNotEmpty) {
      notifyListeners();
      return;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _offices = await _service.getAll();
      _isLoading = false;
      notifyListeners();
    } on ApiException catch (e) {
      _error = e.message;
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchDetail(String id) async {
    if (_officeDetails.containsKey(id)) {
      notifyListeners();
      return;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _officeDetails[id] = await _service.getById(id);
      _isLoading = false;
      notifyListeners();
    } on ApiException catch (e) {
      _error = e.message;
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearCache() {
    _offices.clear();
    _officeDetails.clear();
    notifyListeners();
  }
}
