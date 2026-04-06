import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../utils/error_handler.dart';

/// Widget to display error messages in bilingual format
class ErrorDisplay extends StatelessWidget {
  final dynamic error;
  final VoidCallback? onRetry;
  final bool showIcon;
  final EdgeInsets? padding;

  const ErrorDisplay({
    super.key,
    required this.error,
    this.onRetry,
    this.showIcon = true,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final appError = ErrorHandler.parseError(error);

    return Container(
      padding: padding ?? const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (showIcon) ...[
            Icon(
              _getErrorIcon(appError.type),
              size: 64,
              color: _getErrorColor(appError.type),
            ),
            const SizedBox(height: 16),
          ],
          Text(
            appError.getLocalizedTitle(context),
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: _getErrorColor(appError.type),
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            appError.getLocalizedMessage(context),
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
            textDirection: TextDirection.rtl,
          ),
          if (onRetry != null) ...[
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: Text(l10n.tryAgain),
            ),
          ],
        ],
      ),
    );
  }

  IconData _getErrorIcon(ErrorType type) {
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

  Color _getErrorColor(ErrorType type) {
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

/// Compact error banner widget
class ErrorBanner extends StatelessWidget {
  final dynamic error;
  final VoidCallback? onDismiss;
  final VoidCallback? onRetry;

  const ErrorBanner({
    super.key,
    required this.error,
    this.onDismiss,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final appError = ErrorHandler.parseError(error);

    return Container(
      margin: const EdgeInsets.all(8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: _getErrorColor(appError.type).withOpacity(0.1),
        border: Border.all(
          color: _getErrorColor(appError.type),
          width: 1,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            _getErrorIcon(appError.type),
            color: _getErrorColor(appError.type),
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  appError.getLocalizedTitle(context),
                  style: TextStyle(
                    color: _getErrorColor(appError.type),
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  appError.getLocalizedMessage(context),
                  style: const TextStyle(
                    fontSize: 12,
                  ),
                  textDirection: TextDirection.rtl,
                ),
              ],
            ),
          ),
          if (onRetry != null) ...[
            TextButton(
              onPressed: onRetry,
              child: Text(AppLocalizations.of(context)!.tryAgain),
            ),
          ],
          if (onDismiss != null)
            IconButton(
              icon: const Icon(Icons.close, size: 20),
              onPressed: onDismiss,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
        ],
      ),
    );
  }

  IconData _getErrorIcon(ErrorType type) {
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

  Color _getErrorColor(ErrorType type) {
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

/// Extension method to easily show errors from any widget
extension ErrorHandling on BuildContext {
  void showErrorDialog(
    dynamic error, {
    VoidCallback? onRetry,
  }) {
    ErrorHandler.showErrorDialog(
      this,
      ErrorHandler.parseError(error),
      onRetry: onRetry,
    );
  }

  void showErrorSnackBar(
    dynamic error, {
    SnackBarAction? action,
  }) {
    ErrorHandler.showErrorSnackBar(
      this,
      ErrorHandler.parseError(error),
      action: action,
    );
  }
}
