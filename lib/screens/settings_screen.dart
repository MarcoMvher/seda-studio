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
                      if (authProvider.isAuthenticated)
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
                        )
                      else
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
}
