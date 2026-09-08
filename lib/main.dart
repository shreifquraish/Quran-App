import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'core/constants.dart';
import 'core/theme.dart';
import 'providers/app_provider.dart';
import 'screens/main_shell.dart';
import 'services/permission_service.dart';
import 'services/salawat_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final permissionService = PermissionService();
  permissionService.initialize();
  await SalawatService.instance.initialize();
  runApp(const QuranApp());
}

class QuranApp extends StatelessWidget {
  const QuranApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppProvider()),
        ChangeNotifierProxyProvider<AppProvider, AudioProvider>(
          create: (ctx) => AudioProvider(ctx.read<AppProvider>()),
          update: (_, app, previous) => previous ?? AudioProvider(app),
        ),
      ],
      child: Consumer<AppProvider>(
        builder: (context, app, _) {
          return MaterialApp(
            title: AppConstants.appName,
            debugShowCheckedModeBanner: false,
            locale: const Locale('ar'),
            supportedLocales: const [Locale('ar')],
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            theme: AppTheme.light(),
            darkTheme: AppTheme.dark(),
            themeMode: app.isDarkMode ? ThemeMode.dark : ThemeMode.light,
            home: const PermissionWrapper(),
          );
        },
      ),
    );
  }
}

class PermissionWrapper extends StatelessWidget {
  const PermissionWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return const MainShell();
  }
}
