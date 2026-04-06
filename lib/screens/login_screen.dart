import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../l10n/app_localizations.dart';
import 'customer_list_screen.dart';
import 'visits_list_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final authProvider = context.read<AuthProvider>();

    final success = await authProvider.login(
      _usernameController.text.trim(),
      _passwordController.text,
    );

    if (!mounted) return;

    if (success) {
      // Check if user is admin and show selection dialog
      if (authProvider.isAdmin) {
        _showAdminNavigationDialog();
      } else if (authProvider.isBranchUser) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const VisitsListScreen()),
        );
      } else {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const CustomerListScreen()),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.errorMessage ?? AppLocalizations.of(context)!.loginError),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showAdminNavigationDialog() {
    final l10n = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(l10n.adminSelectView),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.people),
                title: Text(l10n.delegates),
                subtitle: Text(l10n.delegatesViewDesc),
                onTap: () {
                  Navigator.of(dialogContext).pop();
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (_) => const CustomerListScreen()),
                  );
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.store),
                title: Text(l10n.branches),
                subtitle: Text(l10n.branchesViewDesc),
                onTap: () {
                  Navigator.of(dialogContext).pop();
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (_) => const VisitsListScreen()),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Logo
                  Image.asset(
                    'assets/images/logo.png',
                    width: 150,
                    height: 150,
                    errorBuilder: (context, error, stackTrace) {
                      return Icon(
                        Icons.square_foot,
                        size: 100,
                        color: Theme.of(context).colorScheme.primary,
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                  RichText(
                    textAlign: TextAlign.center,
                    textDirection: TextDirection.rtl,
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: 'ستوديو ',
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        TextSpan(
                          text: 'SEDA',
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                fontFeatures: const [FontFeature.tabularFigures()],
                              ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'تطبيق قياس الميداني',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),

                  // Login Form
                  _buildLoginForm(l10n),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoginForm(AppLocalizations l10n) {
    return Column(
      children: [
        TextFormField(
          controller: _usernameController,
          decoration: InputDecoration(
            labelText: l10n.username,
            prefixIcon: const Icon(Icons.person),
            border: const OutlineInputBorder(),
            hintText: l10n.usernameHint,
          ),
          autocorrect: false,
          textCapitalization: TextCapitalization.none,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return l10n.usernameHint;
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _passwordController,
          decoration: InputDecoration(
            labelText: l10n.password,
            prefixIcon: const Icon(Icons.lock),
            suffixIcon: IconButton(
              icon: Icon(_obscurePassword
                  ? Icons.visibility
                  : Icons.visibility_off),
              onPressed: () {
                setState(() {
                  _obscurePassword = !_obscurePassword;
                });
              },
            ),
            border: const OutlineInputBorder(),
            hintText: l10n.passwordHint,
          ),
          obscureText: _obscurePassword,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return l10n.passwordHint;
            }
            return null;
          },
        ),
        const SizedBox(height: 24),
        Consumer<AuthProvider>(
          builder: (context, authProvider, _) {
            if (authProvider.isLoading) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            return ElevatedButton(
              onPressed: _handleSubmit,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: Text(l10n.login),
            );
          },
        ),
      ],
    );
  }
}
