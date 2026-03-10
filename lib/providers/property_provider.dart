import 'package:flutter/foundation.dart';
import '../models/property_model.dart';
import '../services/property_service.dart';
import '../utils/api_exception.dart';

class PropertyProvider extends ChangeNotifier {
  final PropertyService _service = PropertyService();

  List<PropertyModel> _properties = [];
  final Map<String, List<PropertyModel>> _propertiesByKey = {};
  final Map<String, PropertyModel> _propertyDetails = {};
  bool _isLoading = false;
  String? _error;

  List<PropertyModel> get properties => _properties;
  PropertyModel? getDetail(String id) => _propertyDetails[id];
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchProperties({String? type, String? partnerId, bool force = false}) async {
    final key = '${type ?? 'all'}|${partnerId ?? ''}';

    if (!force && _propertiesByKey.containsKey(key)) {
      _properties = _propertiesByKey[key]!;
      notifyListeners();
      return;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _properties = await _service.getAll(type: type, partnerId: partnerId);
      _propertiesByKey[key] = _properties;
      _isLoading = false;
      notifyListeners();
    } on ApiException catch (e) {
      _error = e.message;
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchDetail(String id) async {
    if (_propertyDetails.containsKey(id)) {
      notifyListeners();
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      _propertyDetails[id] = await _service.getById(id);
      _isLoading = false;
      notifyListeners();
    } on ApiException catch (e) {
      _error = e.message;
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearCache() {
    _properties.clear();
    _propertiesByKey.clear();
    _propertyDetails.clear();
    notifyListeners();
  }
}
