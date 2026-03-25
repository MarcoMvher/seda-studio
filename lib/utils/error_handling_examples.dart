/// Error Handling Usage Examples
///
/// This file demonstrates how to use the new bilingual error handling system
/// in your Flutter app.

import 'package:flutter/material.dart';
import '../providers/visit_provider.dart';
import '../widgets/error_display.dart';

// ==========================================
// EXAMPLE 1: Using ErrorDisplay Widget
// ==========================================
///
/// The ErrorDisplay widget shows a full-screen error message with icon and retry button
///
/// ```dart
/// class VisitListScreen extends StatelessWidget {
///   @override
///   Widget build(BuildContext context) {
///     return Consumer<VisitProvider>(
///       builder: (context, visitProvider, _) {
///         // Show error if exists
///         if (visitProvider.error != null) {
///           return ErrorDisplay(
///             error: visitProvider.error!,
///             onRetry: () => visitProvider.loadVisits(),
///           );
///         }
///
///         // Show loading
///         if (visitProvider.isLoading) {
///           return Center(child: CircularProgressIndicator());
///         }
///
///         // Show content
///         return ListView.builder(...);
///       },
///     );
///   }
/// }
/// ```

// ==========================================
// EXAMPLE 2: Using ErrorBanner Widget
// ==========================================
///
/// The ErrorBanner widget shows a compact error banner at the top of the screen
///
/// ```dart
/// class CustomerDetailsScreen extends StatelessWidget {
///   @override
///   Widget build(BuildContext context) {
///     return Consumer<VisitProvider>(
///       builder: (context, visitProvider, _) {
///         return Column(
///           children: [
///             // Show error banner at the top
///             if (visitProvider.error != null)
///               ErrorBanner(
///                 error: visitProvider.error!,
///                 onDismiss: () => visitProvider.clearError(),
///                 onRetry: () => visitProvider.loadVisits(),
///               ),
///
///             // Rest of your content
///             Expanded(...),
///           ],
///         );
///       },
///     );
///   }
/// }
/// ```

// ==========================================
// EXAMPLE 3: Using Context Extension Methods
// ==========================================
///
/// You can use the extension methods on BuildContext to quickly show errors
///
/// ```dart
/// class VisitDetailsScreen extends StatefulWidget {
///   @override
///   _VisitDetailsScreenState createState() => _VisitDetailsScreenState();
/// }
///
/// class _VisitDetailsScreenState extends State<VisitDetailsScreen> {
///   Future<void> _deleteMeasurement(int id) async {
///     try {
///       final visitProvider = context.read<VisitProvider>();
///       await visitProvider.deleteMeasurement(id);
///     } catch (e) {
///       // Show error dialog
///       context.showErrorDialog(
///         e,
///         onRetry: () => _deleteMeasurement(id),
///       );
///
///       // OR show error snackbar
///       // context.showErrorSnackBar(e);
///     }
///   }
///
///   @override
///   Widget build(BuildContext context) {
///     return Scaffold(...);
///   }
/// }
/// ```

// ==========================================
// EXAMPLE 4: Manual Error Display in UI
// ==========================================
///
/// You can manually handle errors and display them however you want
///
/// ```dart
/// class LoginScreen extends StatefulWidget {
///   @override
///   _LoginScreenState createState() => _LoginScreenState();
/// }
///
/// class _LoginScreenState extends State<LoginScreen> {
///   final _formKey = GlobalKey<FormState>();
///   final _usernameController = TextEditingController();
///   final _passwordController = TextEditingController();
///
///   Future<void> _login() async {
///     if (!_formKey.currentState!.validate()) {
///       return;
///     }
///
///     final authProvider = context.read<AuthProvider>();
///     final success = await authProvider.login(
///       _usernameController.text,
///       _passwordController.text,
///     );
///
///     if (!success && authProvider.error != null) {
///       // Show error dialog
///       ErrorHandler.showErrorDialog(
///         context,
///         authProvider.error!,
///       );
///     }
///   }
///
///   @override
///   Widget build(BuildContext context) {
///     return Scaffold(...);
///   }
/// }
/// ```

// ==========================================
// EXAMPLE 5: Handling Errors in initState
// ==========================================
///
/// ```dart
/// class VisitListScreen extends StatefulWidget {
///   @override
///   _VisitListScreenState createState() => _VisitListScreenState();
/// }
///
/// class _VisitListScreenState extends State<VisitListScreen> {
///   @override
///   void initState() {
///     super.initState();
///     WidgetsBinding.instance.addPostFrameCallback((_) {
///       _loadData();
///     });
///   }
///
///   Future<void> _loadData() async {
///     final visitProvider = context.read<VisitProvider>();
///     await visitProvider.loadVisits();
///
///     // Check for error after loading
///     if (mounted && visitProvider.error != null) {
///       context.showErrorSnackBar(
///         visitProvider.error!,
///       );
///     }
///   }
///
///   @override
///   Widget build(BuildContext context) {
///     return Scaffold(...);
///   }
/// }
/// ```

// ==========================================
// EXAMPLE 6: Custom Error Handling
// ==========================================
///
/// If you need custom error handling for specific cases
///
/// ```dart
/// import '../utils/error_handler.dart';
///
/// class CustomErrorHandling extends StatefulWidget {
///   @override
///   _CustomErrorHandlingState createState() => _CustomErrorHandlingState();
/// }
///
/// class _CustomErrorHandlingState extends State<CustomErrorHandling> {
///   Future<void> _performSpecialAction() async {
///     try {
///       // Your async operation here
///       await someSpecialOperation();
///     } catch (e) {
///       final appError = ErrorHandler.parseError(e);
///
///       // Handle specific error types differently
///       if (appError.type == ErrorType.network) {
///         // Show network error specific UI
///         _showNetworkErrorDialog();
///       } else if (appError.type == ErrorType.authentication) {
///         // Redirect to login
///         Navigator.of(context).pushReplacementNamed('/login');
///       } else {
///         // Show generic error
///         context.showErrorDialog(appError);
///       }
///     }
///   }
///
///   void _showNetworkErrorDialog() {
///     showDialog(
///       context: context,
///       builder: (context) => AlertDialog(
///         title: Text('No Internet'),
///         content: Text('Please check your connection'),
///         actions: [
///           TextButton(
///             onPressed: () => Navigator.pop(context),
///             child: Text('OK'),
///           ),
///         ],
///       ),
///     );
///   }
///
///   @override
///   Widget build(BuildContext context) {
///     return Scaffold(...);
///   }
/// }
/// ```
///
/// ==========================================
/// ERROR TYPES
/// ==========================================
///
/// The system categorizes errors into these types:
/// - ErrorType.network: Network connectivity issues
/// - ErrorType.authentication: Authentication failures (401)
/// - ErrorType.authorization: Permission issues (403)
/// - ErrorType.notFound: Resource not found (404)
/// - ErrorType.validation: Invalid data (400)
/// - ErrorType.server: Server errors (500, 503)
/// - ErrorType.unknown: Unexpected errors
///
/// Each error type has:
/// - A localized title (in Arabic and English)
/// - A localized message
/// - An associated icon and color
/// - Automatic retry suggestions
///
/// ==========================================
/// BEST PRACTICES
/// ==========================================
///
/// 1. Always use the ErrorHandler.parseError() to convert any exception to AppError
/// 2. Use ErrorDisplay widget for full-page errors
/// 3. Use ErrorBanner widget for inline errors
/// 4. Use context.showErrorDialog() for modal error dialogs
/// 5. Use context.showErrorSnackBar() for temporary error messages
/// 6. Check provider.error != null in UI to display errors
/// 7. Always call provider.clearError() after user dismisses error
/// 8. Provide onRetry callback when possible for better UX
///
/// ==========================================
/// MIGRATION FROM OLD ERROR HANDLING
/// ==========================================
///
/// OLD CODE:
/// ```dart
/// try {
///   await visitProvider.loadVisits();
/// } catch (e) {
///   if (visitProvider.errorMessage != null) {
///     showDialog(
///       context: context,
///       builder: (context) => AlertDialog(
///         title: Text('Error'),
///         content: Text(visitProvider.errorMessage!),
///       ),
///     );
///   }
/// }
/// ```
///
/// NEW CODE:
/// ```dart
/// await visitProvider.loadVisits();
/// if (visitProvider.error != null) {
///   context.showErrorDialog(visitProvider.error!);
/// }
/// ```
///
/// OR using ErrorDisplay widget:
/// ```dart
/// Widget build(BuildContext context) {
///   return Consumer<VisitProvider>(
///     builder: (context, visitProvider, _) {
///       if (visitProvider.error != null) {
///         return ErrorDisplay(
///           error: visitProvider.error!,
///           onRetry: () => visitProvider.loadVisits(),
///         );
///       }
///       // Your normal content
///     },
///   );
/// }
/// ```
