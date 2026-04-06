import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'screens/login_screen.dart';
import 'screens/customer_list_screen.dart';
import 'screens/visits_list_screen.dart';
import 'screens/settings_screen.dart';
import 'providers/auth_provider.dart';
import 'providers/customer_provider.dart';
import 'providers/visit_provider.dart';
import 'providers/settings_provider.dart';
import 'l10n/app_localizations.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => CustomerProvider()),
        ChangeNotifierProvider(create: (_) => VisitProvider()),
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
      ],
      child: Consumer<SettingsProvider>(
        builder: (context, settingsProvider, _) {
          return MaterialApp(
            title: 'SEDA Studio',
            locale: settingsProvider.locale,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('ar'), // Arabic
              Locale('en'), // English
            ],
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
              useMaterial3: true,
            ),
            builder: (context, child) {
              // Ensure text direction is preserved on orientation changes
              return Directionality(
                textDirection: settingsProvider.locale.languageCode == 'ar'
                    ? TextDirection.rtl
                    : TextDirection.ltr,
                child: child!,
              );
            },
            home: const SplashScreen(),
            debugShowCheckedModeBanner: false,
            routes: {
              '/settings': (context) => const SettingsScreen(),
            },
          );
        },
      ),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAuthStatus();
    });
  }

  Future<void> _checkAuthStatus() async {
    final authProvider = context.read<AuthProvider>();
    await authProvider.loadToken();

    if (!mounted) return;

    if (authProvider.isAuthenticated) {
      // Debug logging
      print('DEBUG: User authenticated');
      print('DEBUG: isAdmin: ${authProvider.isAdmin}');
      print('DEBUG: isBranchUser: ${authProvider.isBranchUser}');
      print('DEBUG: isSuperuser: ${authProvider.user?.isSuperuser}');
      print('DEBUG: isStaff: ${authProvider.user?.isStaff}');

      // Navigate based on user role
      if (authProvider.isAdmin) {
        // Show dialog for admin users to choose between branches or delegates
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
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
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
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
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
            Text(
              AppLocalizations.of(context)!.appName,
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 48),
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
