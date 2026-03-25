import 'package:dio/dio.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'api_service.dart';
import '../models/visit.dart';
import '../models/measurement.dart';
import '../models/visit_image.dart';
import '../config/app_config.dart';
import '../utils/error_handler.dart';

class VisitService {
  final ApiService _apiService = ApiService();

  Future<List<Visit>> getVisits({
    String? status,
    int? customerId,
    int? orderNumber,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (status != null) {
        queryParams['status'] = status;
      }
      if (customerId != null) {
        queryParams['customer'] = customerId;
      }
      if (orderNumber != null) {
        queryParams['order'] = orderNumber;
      }

      final response = await _apiService.dio.get(
        '${AppConfig.apiPath}/visits/',
        queryParameters: queryParams,
      );

      return (response.data['results'] as List)
          .map((json) => Visit.fromJson(json))
          .toList();
    } on DioException catch (e) {
      throw ErrorHandler.parseError(e);
    } catch (e) {
      throw ErrorHandler.parseError(e);
    }
  }

  Future<Visit> getVisit(int id) async {
    try {
      final response = await _apiService.dio.get(
        '${AppConfig.apiPath}/visits/$id/',
      );
      return Visit.fromJson(response.data);
    } on DioException catch (e) {
      throw ErrorHandler.parseError(e);
    } catch (e) {
      throw ErrorHandler.parseError(e);
    }
  }

  Future<Visit> createVisit({
    required int customerId,
    String? notes,
    int? orderId,
  }) async {
    try {
      final response = await _apiService.dio.post(
        '${AppConfig.apiPath}/visits/',
        data: {
          'customer': customerId,
          'status': 'pending',
          if (notes != null) 'notes': notes,
          if (orderId != null) 'order_id': orderId,
        },
      );
      return Visit.fromJson(response.data);
    } on DioException catch (e) {
      throw ErrorHandler.parseError(e);
    } catch (e) {
      throw ErrorHandler.parseError(e);
    }
  }

  Future<Visit> updateVisit(int id, {
    String? status,
    String? notes,
  }) async {
    try {
      final response = await _apiService.dio.patch(
        '${AppConfig.apiPath}/visits/$id/',
        data: {
          if (status != null) 'status': status,
          if (notes != null) 'notes': notes,
        },
      );
      return Visit.fromJson(response.data);
    } on DioException catch (e) {
      throw ErrorHandler.parseError(e);
    } catch (e) {
      throw ErrorHandler.parseError(e);
    }
  }

  Future<List<Measurement>> addMeasurements(int visitId, List<Map<String, dynamic>> measurements) async {
    try {
      final List<Measurement> createdMeasurements = [];

      // Send each measurement individually to avoid FormData parsing issues
      for (var measurement in measurements) {
        final formData = FormData();

        // Handle image field
        if (measurement.containsKey('image') && measurement['image'] != null) {
          final imageData = measurement['image'];

          if (imageData is XFile) {
            final bytes = await imageData.readAsBytes();
            final fileName = imageData.name ?? 'image.jpg';
            formData.files.add(MapEntry(
              'image',
              MultipartFile.fromBytes(bytes, filename: fileName),
            ));
          } else if (imageData is File) {
            formData.files.add(MapEntry(
              'image',
              await MultipartFile.fromFile(imageData.path),
            ));
          }
        }

        // Add all other fields (excluding image)
        // Note: visit must be included in the form data, not query params
        measurement.forEach((key, value) {
          if (key != 'image' && value != null) {
            // Convert booleans to strings properly
            if (value is bool) {
              formData.fields.add(MapEntry(key, value ? 'true' : 'false'));
            } else {
              formData.fields.add(MapEntry(key, value.toString()));
            }
          }
        });

        // Add visit ID to form data (required by backend)
        formData.fields.add(MapEntry('visit', visitId.toString()));

        // Post to the measurements endpoint directly
        final response = await _apiService.dio.post(
          '${AppConfig.apiPath}/measurements/',
          data: formData,
        );

        createdMeasurements.add(Measurement.fromJson(response.data));
      }

      return createdMeasurements;
    } on DioException catch (e) {
      throw ErrorHandler.parseError(e);
    } catch (e) {
      throw ErrorHandler.parseError(e);
    }
  }

  Future<Measurement> updateMeasurement(int measurementId, Map<String, dynamic> measurementData) async {
    try {
      final formData = FormData();

      // Handle image field
      if (measurementData.containsKey('image') && measurementData['image'] != null) {
        final imageData = measurementData['image'];

        if (imageData is XFile) {
          final bytes = await imageData.readAsBytes();
          final fileName = imageData.name ?? 'image.jpg';
          formData.files.add(MapEntry(
            'image',
            MultipartFile.fromBytes(bytes, filename: fileName),
          ));
        } else if (imageData is File) {
          formData.files.add(MapEntry(
            'image',
            await MultipartFile.fromFile(imageData.path),
          ));
        }
      }

      // Add all other fields (excluding image)
      measurementData.forEach((key, value) {
        if (key != 'image' && key != 'id' && value != null) {
          // Convert booleans to strings properly
          if (value is bool) {
            formData.fields.add(MapEntry(key, value ? 'true' : 'false'));
          } else {
            formData.fields.add(MapEntry(key, value.toString()));
          }
        }
      });

      final response = await _apiService.dio.patch(
        '${AppConfig.apiPath}/measurements/$measurementId/',
        data: formData,
      );
      return Measurement.fromJson(response.data);
    } on DioException catch (e) {
      throw ErrorHandler.parseError(e);
    } catch (e) {
      throw ErrorHandler.parseError(e);
    }
  }

  Future<void> deleteMeasurement(int measurementId) async {
    try {
      await _apiService.dio.delete(
        '${AppConfig.apiPath}/measurements/$measurementId/',
      );
    } on DioException catch (e) {
      throw ErrorHandler.parseError(e);
    } catch (e) {
      throw ErrorHandler.parseError(e);
    }
  }

  Future<VisitImage> uploadImage(int visitId, File imageFile, {String? caption}) async {
    try {
      final formData = FormData.fromMap({
        'image': await MultipartFile.fromFile(imageFile.path),
        if (caption != null) 'caption': caption,
      });

      final response = await _apiService.dio.post(
        '${AppConfig.apiPath}/visits/$visitId/images/',
        data: formData,
      );

      return VisitImage.fromJson(response.data);
    } on DioException catch (e) {
      throw ErrorHandler.parseError(e);
    } catch (e) {
      throw ErrorHandler.parseError(e);
    }
  }

  Future<void> deleteImage(int imageId) async {
    try {
      await _apiService.dio.delete(
        '${AppConfig.apiPath}/images/$imageId/',
      );
    } on DioException catch (e) {
      throw ErrorHandler.parseError(e);
    } catch (e) {
      throw ErrorHandler.parseError(e);
    }
  }
}
