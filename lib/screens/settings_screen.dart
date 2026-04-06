import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';
import '../providers/auth_provider.dart';
import '../l10n/app_localizations.dart';
import 'login_screen.dart';
import 'customer_list_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settings),
      ),
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, _) {
          return ListView(
            children: [
              // User Status Section
              Card(
                margin: const EdgeInsets.all(16),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            authProvider.isAuthenticated
                                ? Icons.check_circle
                                : Icons.cancel,
                            color: authProvider.isAuthenticated
                                ? Colors.green
                                : Colors.red,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  authProvider.isAuthenticated
                                      ? 'تم تسجيل الدخول'
                                      : l10n.youAreNotLoggedIn,
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                                if (authProvider.isAuthenticated &&
                                    authProvider.user != null)
                                  Text(
                                    authProvider.user!.username,
                                    style: TextStyle(color: Colors.grey[600]),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      if (authProvider.isAuthenticated) ...[
                        // Change Password Button
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: () => _showChangePasswordDialog(context, authProvider, l10n),
                            icon: const Icon(Icons.lock_reset),
                            label: Text(l10n.changePassword),
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Logout Button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () async {
                              final confirmed = await showDialog<bool>(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: Text(l10n.logout),
                                  content: Text(l10n.logoutConfirm),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(context, false),
                                      child: Text(l10n.cancel),
                                    ),
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(context, true),
                                      child: Text(l10n.logout),
                                    ),
                                  ],
                                ),
                              );

                              if (confirmed == true && context.mounted) {
                                await authProvider.logout();
                                if (context.mounted) {
                                  Navigator.of(context).pushAndRemoveUntil(
                                    MaterialPageRoute(
                                      builder: (_) => const LoginScreen(),
                                    ),
                                    (route) => false,
                                  );
                                }
                              }
                            },
                            icon: const Icon(Icons.logout),
                            label: Text(l10n.logout),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ),
                      ] else
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => const LoginScreen(),
                                ),
                              );
                            },
                            icon: const Icon(Icons.login),
                            label: Text(l10n.loginAgain),
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              // Language Section
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  l10n.language,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
              Consumer<SettingsProvider>(
                builder: (context, settingsProvider, _) {
                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      children: [
                        RadioListTile<String>(
                          title: Text(l10n.arabic),
                          subtitle: const Text('العربية'),
                          value: 'ar',
                          groupValue: settingsProvider.locale.languageCode,
                          onChanged: (value) async {
                            if (value != null) {
                              await settingsProvider.setLanguage(value);
                              // Rebuild the app with new locale
                              if (context.mounted) {
                                Navigator.of(context).pushAndRemoveUntil(
                                  MaterialPageRoute(
                                    builder: (_) => const CustomerListScreen(),
                                  ),
                                  (route) => false,
                                );
                              }
                            }
                          },
                        ),
                        RadioListTile<String>(
                          title: Text(l10n.english),
                          subtitle: const Text('English'),
                          value: 'en',
                          groupValue: settingsProvider.locale.languageCode,
                          onChanged: (value) async {
                            if (value != null) {
                              await settingsProvider.setLanguage(value);
                              // Rebuild the app with new locale
                              if (context.mounted) {
                                Navigator.of(context).pushAndRemoveUntil(
                                  MaterialPageRoute(
                                    builder: (_) => const CustomerListScreen(),
                                  ),
                                  (route) => false,
                                );
                              }
                            }
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),

              const SizedBox(height: 32),
            ],
          );
        },
      ),
    );
  }

  void _showChangePasswordDialog(BuildContext context, AuthProvider authProvider, AppLocalizations l10n) {
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    bool isLoading = false;
    String? errorMessage;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: Text(l10n.changePassword),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (errorMessage != null) ...[
                  Text(
                    errorMessage!,
                    style: const TextStyle(color: Colors.red),
                  ),
                  const SizedBox(height: 8),
                ],
                TextField(
                  controller: currentPasswordController,
                  decoration: InputDecoration(
                    labelText: l10n.currentPassword,
                    hintText: l10n.currentPasswordHint,
                    prefixIcon: const Icon(Icons.lock),
                    border: const OutlineInputBorder(),
                  ),
                  obscureText: true,
                  enabled: !isLoading,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: newPasswordController,
                  decoration: InputDecoration(
                    labelText: l10n.newPassword,
                    hintText: l10n.newPasswordHint,
                    prefixIcon: const Icon(Icons.lock_outline),
                    border: const OutlineInputBorder(),
                  ),
                  obscureText: true,
                  enabled: !isLoading,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: confirmPasswordController,
                  decoration: InputDecoration(
                    labelText: l10n.confirmPassword,
                    hintText: l10n.confirmPasswordHint,
                    prefixIcon: const Icon(Icons.lock_outline),
                    border: const OutlineInputBorder(),
                  ),
                  obscureText: true,
                  enabled: !isLoading,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: isLoading ? null : () => Navigator.pop(context),
                child: Text(l10n.cancel),
              ),
              ElevatedButton(
                onPressed: isLoading ? null : () async {
                  // Validation
                  if (currentPasswordController.text.isEmpty) {
                    setDialogState(() {
                      errorMessage = l10n.currentPasswordHint;
                    });
                    return;
                  }

                  if (newPasswordController.text.length < 8) {
                    setDialogState(() {
                      errorMessage = l10n.invalidPasswordLength;
                    });
                    return;
                  }

                  if (newPasswordController.text != confirmPasswordController.text) {
                    setDialogState(() {
                      errorMessage = l10n.passwordsDoNotMatch;
                    });
                    return;
                  }

                  setDialogState(() {
                    isLoading = true;
                    errorMessage = null;
                  });

                  final success = await authProvider.changePassword(
                    currentPasswordController.text,
                    newPasswordController.text,
                  );

                  if (!context.mounted) return;

                  setDialogState(() {
                    isLoading = false;
                  });

                  if (success) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(l10n.passwordChanged),
                        backgroundColor: Colors.green,
                      ),
                    );
                  } else {
                    setDialogState(() {
                      errorMessage = authProvider.errorMessage ?? l10n.passwordChangeFailed;
                    });
                  }
                },
                child: isLoading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(l10n.save),
              ),
            ],
          );
        },
      ),
    );
  }
}
