import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:provider/provider.dart';
import 'providers/bookmarks_provider.dart';
import 'providers/settings_provider.dart';
import 'screens/main_menu_screen.dart';

void main() async {
  // Catch any errors during app initialization
  runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();

      // Add a small delay to let iOS settle
      await Future.delayed(const Duration(milliseconds: 100));

      // Set up error widget builder for better debugging
      ErrorWidget.builder = (FlutterErrorDetails details) {
        return Material(
          child: Container(
            color: Colors.red,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'خطأ في التطبيق\nError: ${details.exception}',
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        );
      };

      runApp(const NahjApp());
    },
    (error, stack) {
      debugPrint('Caught error: $error');
      debugPrint('Stack trace: $stack');
    },
  );
}

class NahjApp extends StatelessWidget {
  const NahjApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => BookmarksProvider()),
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
      ],
      child: Consumer<SettingsProvider>(
        builder: (context, settings, child) {
          return MaterialApp(
            title: 'نهج البلاغة',
            debugShowCheckedModeBanner: false,
            themeMode: settings.themeMode,
            theme: ThemeData(
              useMaterial3: true,
              colorScheme: ColorScheme.fromSeed(
                seedColor: const Color(0xFF00695C), // Teal Green
                secondary: const Color(0xFF4CAF50), // Light Green
                surface: const Color(0xFFE8F5E9), // Very Light Green
              ),
              scaffoldBackgroundColor: const Color(0xFFE8F5E9),
              appBarTheme: const AppBarTheme(
                backgroundColor: Color(0xFF00695C),
                foregroundColor: Colors.white,
                elevation: 2,
              ),
              cardTheme: CardThemeData(
                color: const Color(0xFFF1F8F4), // Very Pale Green for cards
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              // SAFE MODE: Use default fonts
              textTheme: ThemeData.light().textTheme,
            ),
            darkTheme: ThemeData(
              useMaterial3: true,
              brightness: Brightness.dark,
              colorScheme: ColorScheme.fromSeed(
                seedColor: const Color(0xFF00695C),
                secondary: const Color(0xFFFFC107),
                brightness: Brightness.dark,
              ),
              scaffoldBackgroundColor: const Color(0xFF1a1a1a),
              appBarTheme: const AppBarTheme(
                backgroundColor: Color(0xFF2d2d2d),
                foregroundColor: Colors.white,
                elevation: 0,
              ),
              // SAFE MODE: Use default dark fonts
              textTheme: ThemeData.dark().textTheme,
            ),
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('ar', ''), // Arabic
            ],
            locale: const Locale('ar', ''),
            home: const MainMenuScreen(),
          );
        },
      ),
    );
  }
}
