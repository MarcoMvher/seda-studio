import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
import '../models/visit.dart';
import '../models/measurement.dart';
import '../models/visit_image.dart';
import '../services/visit_service.dart';
import '../utils/error_handler.dart';

class VisitProvider with ChangeNotifier {
  final VisitService _visitService = VisitService();

  List<Visit> _visits = [];
  Visit? _selectedVisit;
  bool _isLoading = false;
  AppError? _error;
  bool _mounted = true;

  List<Visit> get visits => _visits;
  Visit? get selectedVisit => _selectedVisit;
  bool get isLoading => _isLoading;
  AppError? get error => _error;
  String? get errorMessage => _error?.messageAr; // For backward compatibility
  bool get mounted => _mounted;

  @override
  void dispose() {
    _mounted = false;
    super.dispose();
  }

  void _notifyIfMounted() {
    if (_mounted) {
      notifyListeners();
    }
  }

  Future<void> loadVisits({
    String? status,
    int? customerId,
    int? orderNumber,
  }) async {
    try {
      _visits = await _visitService.getVisits(
        status: status,
        customerId: customerId,
        orderNumber: orderNumber,
      );
      if (_mounted) {
        _isLoading = false;
        _error = null;
        _notifyIfMounted();
      }
    } catch (e) {
      if (_mounted) {
        _error = ErrorHandler.parseError(e);
        _isLoading = false;
        _notifyIfMounted();
      }
    }
  }

  Future<void> loadVisit(int id) async {
    try {
      _selectedVisit = await _visitService.getVisit(id);
      if (_mounted) {
        _isLoading = false;
        _error = null;
        _notifyIfMounted();
      }
    } catch (e) {
      if (_mounted) {
        _error = ErrorHandler.parseError(e);
        _isLoading = false;
        _notifyIfMounted();
      }
    }
  }

  Future<Visit?> createVisit(int customerId, {String? notes, int? orderId}) async {
    try {
      final visit = await _visitService.createVisit(
        customerId: customerId,
        notes: notes,
        orderId: orderId,
      );

      // Add to visits list
      _visits.insert(0, visit);

      if (_mounted) {
        _isLoading = false;
        _error = null;
        _notifyIfMounted();
      }

      return visit;
    } catch (e) {
      if (_mounted) {
        _error = ErrorHandler.parseError(e);
        _isLoading = false;
        _notifyIfMounted();
      }

      return null;
    }
  }

  Future<void> updateVisitStatus(int visitId, String status) async {
    try {
      final updatedVisit = await _visitService.updateVisit(
        visitId,
        status: status,
      );

      // Update in list
      final index = _visits.indexWhere((v) => v.id == visitId);
      if (index != -1) {
        _visits[index] = updatedVisit;
      }

      // Update selected visit
      if (_selectedVisit?.id == visitId) {
        _selectedVisit = updatedVisit;
      }

      if (_mounted) {
        _isLoading = false;
        _error = null;
        _notifyIfMounted();
      }
    } catch (e) {
      if (_mounted) {
        _error = ErrorHandler.parseError(e);
        _isLoading = false;
        _notifyIfMounted();
      }
    }
  }

  Future<void> addMeasurement(int visitId, Map<String, dynamic> measurementData) async {
    try {
      final measurements = await _visitService.addMeasurements(visitId, [measurementData]);

      // Reload visit to get updated data
      await loadVisit(visitId);

      if (_mounted) {
        _isLoading = false;
        _error = null;
        _notifyIfMounted();
      }
    } catch (e) {
      if (_mounted) {
        _error = ErrorHandler.parseError(e);
        _isLoading = false;
        _notifyIfMounted();
      }
    }
  }

  Future<void> deleteMeasurement(int measurementId) async {
    try {
      await _visitService.deleteMeasurement(measurementId);

      // Reload visit to get updated data
      if (_selectedVisit != null) {
        await loadVisit(_selectedVisit!.id);
      }

      if (_mounted) {
        _isLoading = false;
        _error = null;
        _notifyIfMounted();
      }
    } catch (e) {
      if (_mounted) {
        _error = ErrorHandler.parseError(e);
        _isLoading = false;
        _notifyIfMounted();
      }
    }
  }

  Future<void> updateMeasurement(int measurementId, Map<String, dynamic> measurementData) async {
    try {
      await _visitService.updateMeasurement(measurementId, measurementData);

      // Reload visit to get updated data
      if (_selectedVisit != null) {
        await loadVisit(_selectedVisit!.id);
      }

      if (_mounted) {
        _isLoading = false;
        _error = null;
        _notifyIfMounted();
      }
    } catch (e) {
      if (_mounted) {
        _error = ErrorHandler.parseError(e);
        _isLoading = false;
        _notifyIfMounted();
      }
    }
  }

  void selectVisit(Visit visit) {
    _selectedVisit = visit;
    notifyListeners();
  }

  Future<void> cancelVisit(int visitId) async {
    try {
      final cancelledVisit = await _visitService.cancelVisit(visitId);

      // Update in list
      final index = _visits.indexWhere((v) => v.id == visitId);
      if (index != -1) {
        _visits[index] = cancelledVisit;
      }

      // Update selected visit
      if (_selectedVisit?.id == visitId) {
        _selectedVisit = cancelledVisit;
      }

      if (_mounted) {
        _isLoading = false;
        _error = null;
        _notifyIfMounted();
      }
    } catch (e) {
      if (_mounted) {
        _error = ErrorHandler.parseError(e);
        _isLoading = false;
        _notifyIfMounted();
      }
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
