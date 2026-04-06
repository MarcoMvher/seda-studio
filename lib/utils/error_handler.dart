import 'dart:io';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../l10n/app_localizations.dart';

/// Enum for error types
enum ErrorType {
  network,
  authentication,
  authorization,
  notFound,
  validation,
  server,
  unknown,
}

/// Class to handle and translate errors to bilingual messages
class AppError {
  final ErrorType type;
  final String messageAr;
  final String messageEn;
  final int? statusCode;
  final String? details;

  AppError({
    required this.type,
    required this.messageAr,
    required this.messageEn,
    this.statusCode,
    this.details,
  });

  /// Get localized error message
  String getLocalizedMessage(BuildContext context) {
    final locale = Localizations.localeOf(context);
    return locale.languageCode == 'ar' ? messageAr : messageEn;
  }

  /// Get display title
  String getLocalizedTitle(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    switch (type) {
      case ErrorType.network:
        return l10n.errorNetwork;
      case ErrorType.authentication:
        return l10n.errorAuth;
      case ErrorType.authorization:
        return l10n.errorPermission;
      case ErrorType.notFound:
        return l10n.errorNotFound;
      case ErrorType.validation:
        return l10n.errorValidation;
      case ErrorType.server:
        return l10n.errorServer;
      case ErrorType.unknown:
        return l10n.error;
    }
  }

  factory AppError.fromDioException(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return AppError(
          type: ErrorType.network,
          messageAr: 'انتهت مهلة الاتصال. يرجى التحقق من اتصال الإنترنت والمحاولة مرة أخرى',
          messageEn: 'Connection timeout. Please check your internet connection and try again',
        );
      case DioExceptionType.connectionError:
        return AppError(
          type: ErrorType.network,
          messageAr: 'لا يمكن الاتصال بالخادم. يرجى التحقق من اتصال الإنترنت والمحاولة مرة أخرى',
          messageEn: 'Cannot connect to server. Please check your internet connection and try again',
        );
      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        final data = e.response?.data;

        // Try to extract error message from response
        String? serverMessage;
        if (data is Map) {
          serverMessage = data['detail']?.toString() ??
                        data['error']?.toString() ??
                        data['message']?.toString();
        }

        if (statusCode == 400) {
          return AppError(
            type: ErrorType.validation,
            messageAr: serverMessage ?? 'البيانات المدخلة غير صحيحة. يرجى التحقق من جميع الحقول والمحاولة مرة أخرى',
            messageEn: serverMessage ?? 'Invalid data. Please check all fields and try again',
            statusCode: statusCode,
            details: serverMessage,
          );
        } else if (statusCode == 401) {
          return AppError(
            type: ErrorType.authentication,
            messageAr: 'جلسة العمل منتهية. يرجى تسجيل الدخول مرة أخرى',
            messageEn: 'Session expired. Please login again',
            statusCode: statusCode,
          );
        } else if (statusCode == 403) {
          return AppError(
            type: ErrorType.authorization,
            messageAr: 'ليس لديك صلاحية للقيام بهذا الإجراء',
            messageEn: 'You do not have permission to perform this action',
            statusCode: statusCode,
          );
        } else if (statusCode == 404) {
          return AppError(
            type: ErrorType.notFound,
            messageAr: 'المورد المطلوب غير موجود',
            messageEn: 'The requested resource was not found',
            statusCode: statusCode,
          );
        } else if (statusCode == 500) {
          return AppError(
            type: ErrorType.server,
            messageAr: 'خطأ في الخادم الداخلي. يرجى المحاولة مرة أخرى لاحقاً',
            messageEn: 'Internal server error. Please try again later',
            statusCode: statusCode,
          );
        } else if (statusCode == 503) {
          return AppError(
            type: ErrorType.server,
            messageAr: 'الخدمة غير متاحة حالياً. يرجى المحاولة مرة أخرى لاحقاً',
            messageEn: 'Service unavailable. Please try again later',
            statusCode: statusCode,
          );
        } else {
          return AppError(
            type: ErrorType.server,
            messageAr: serverMessage ?? 'خطأ في الخادم (رمز: $statusCode). يرجى المحاولة مرة أخرى',
            messageEn: serverMessage ?? 'Server error (code: $statusCode). Please try again',
            statusCode: statusCode,
            details: serverMessage,
          );
        }
      case DioExceptionType.cancel:
        return AppError(
          type: ErrorType.unknown,
          messageAr: 'تم إلغاء الطلب',
          messageEn: 'Request was cancelled',
        );
      case DioExceptionType.unknown:
        // Check if it's a network error
        if (e.error is SocketException || e.message?.contains('SocketException') == true) {
          return AppError(
            type: ErrorType.network,
            messageAr: 'لا يمكن الاتصال بالخادم. يرجى التحقق من اتصال الإنترنت',
            messageEn: 'Cannot connect to server. Please check your internet connection',
          );
        }
        return AppError(
          type: ErrorType.unknown,
          messageAr: 'حدث خطأ غير متوقع. يرجى المحاولة مرة أخرى',
          messageEn: 'An unexpected error occurred. Please try again',
        );
      default:
        return AppError(
          type: ErrorType.unknown,
          messageAr: 'حدث خطأ. يرجى المحاولة مرة أخرى',
          messageEn: 'An error occurred. Please try again',
        );
    }
  }

  factory AppError.fromException(Exception e) {
    final message = e.toString();

    // Try to parse common error patterns
    if (message.contains('Failed to load visit') || message.contains('فشل تحميل الزيارات')) {
      return AppError(
        type: ErrorType.server,
        messageAr: 'فشل في تحميل بيانات الزيارة. يرجى المحاولة مرة أخرى',
        messageEn: 'Failed to load visit data. Please try again',
      );
    } else if (message.contains('Failed to create visit') || message.contains('فشل إنشاء الزيارة')) {
      return AppError(
        type: ErrorType.server,
        messageAr: 'فشل في إنشاء الزيارة. يرجى المحاولة مرة أخرى',
        messageEn: 'Failed to create visit. Please try again',
      );
    } else if (message.contains('Failed to update') || message.contains('فشل التحديث')) {
      return AppError(
        type: ErrorType.server,
        messageAr: 'فشل في تحديث البيانات. يرجى المحاولة مرة أخرى',
        messageEn: 'Failed to update data. Please try again',
      );
    } else if (message.contains('Failed to delete') || message.contains('فشل الحذف')) {
      return AppError(
        type: ErrorType.server,
        messageAr: 'فشل في الحذف. يرجى المحاولة مرة أخرى',
        messageEn: 'Failed to delete. Please try again',
      );
    } else if (message.contains('Failed to load') || message.contains('فشل التحميل')) {
      return AppError(
        type: ErrorType.server,
        messageAr: 'فشل في تحميل البيانات. يرجى المحاولة مرة أخرى',
        messageEn: 'Failed to load data. Please try again',
      );
    } else if (message.contains('Login failed') || message.contains('فشل تسجيل الدخول')) {
      return AppError(
        type: ErrorType.authentication,
        messageAr: 'فشل تسجيل الدخول. يرجى التحقق من اسم المستخدم وكلمة المرور',
        messageEn: 'Login failed. Please check your username and password',
      );
    }

    // Default error
    return AppError(
      type: ErrorType.unknown,
      messageAr: message.contains('فشل') || message.contains('خطأ') ? message : 'حدث خطأ. يرجى المحاولة مرة أخرى',
      messageEn: 'An error occurred. Please try again',
    );
  }

  @override
  String toString() {
    return 'AppError(type: $type, ar: $messageAr, en: $messageEn)';
  }
}

/// Utility class for error handling
class ErrorHandler {
  /// Parse any error and return AppError
  static AppError parseError(dynamic error) {
    if (error is AppError) {
      return error;
    } else if (error is DioException) {
      return AppError.fromDioException(error);
    } else if (error is Exception) {
      return AppError.fromException(error);
    } else {
      return AppError(
        type: ErrorType.unknown,
        messageAr: 'حدث خطأ غير متوقع: $error',
        messageEn: 'An unexpected error occurred: $error',
      );
    }
  }

  /// Show error dialog
  static void showErrorDialog(
    BuildContext context,
    AppError error, {
    VoidCallback? onRetry,
  }) {
    final l10n = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              _getErrorIcon(error.type),
              color: _getErrorColor(error.type),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                error.getLocalizedTitle(context),
                style: TextStyle(
                  color: _getErrorColor(error.type),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        content: Text(
          error.getLocalizedMessage(context),
          textDirection: TextDirection.rtl,
        ),
        actions: [
          if (onRetry != null)
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                onRetry();
              },
              child: Text(l10n.tryAgain),
            ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.close),
          ),
        ],
      ),
    );
  }

  /// Show error snackbar
  static void showErrorSnackBar(
    BuildContext context,
    AppError error, {
    SnackBarAction? action,
  }) {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    scaffoldMessenger.showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              _getErrorIcon(error.type),
              color: Colors.white,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                error.getLocalizedMessage(context),
                textDirection: TextDirection.rtl,
              ),
            ),
          ],
        ),
        backgroundColor: _getErrorColor(error.type),
        action: action,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  /// Get error icon based on type
  static IconData _getErrorIcon(ErrorType type) {
    switch (type) {
      case ErrorType.network:
        return Icons.wifi_off;
      case ErrorType.authentication:
        return Icons.lock_outline;
      case ErrorType.authorization:
        return Icons.security;
      case ErrorType.notFound:
        return Icons.search_off;
      case ErrorType.validation:
        return Icons.error_outline;
      case ErrorType.server:
        return Icons.cloud_off;
      case ErrorType.unknown:
        return Icons.error;
    }
  }

  /// Get error color based on type
  static Color _getErrorColor(ErrorType type) {
    switch (type) {
      case ErrorType.network:
        return Colors.orange;
      case ErrorType.authentication:
      case ErrorType.authorization:
        return Colors.red;
      case ErrorType.notFound:
        return Colors.blue;
      case ErrorType.validation:
        return Colors.amber;
      case ErrorType.server:
        return Colors.red.shade700;
      case ErrorType.unknown:
        return Colors.grey;
    }
  }
}
