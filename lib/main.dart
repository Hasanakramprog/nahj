import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'providers/bookmarks_provider.dart';
import 'providers/settings_provider.dart';
import 'screens/main_menu_screen.dart';

void main() {
  // Catch any errors during app initialization
  runZonedGuarded(
    () {
      WidgetsFlutterBinding.ensureInitialized();

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
      print('Caught error: $error');
      print('Stack trace: $stack');
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
                seedColor: const Color(0xFF5D4037), // Deep Brown
                secondary: const Color(0xFFC19A6B), // Desert Sand
                surface: const Color(0xFFF5E6CA), // Parchment Beige
              ),
              scaffoldBackgroundColor: const Color(0xFFF5E6CA),
              appBarTheme: const AppBarTheme(
                backgroundColor: Color(0xFF5D4037),
                foregroundColor: Color(0xFFF5E6CA),
                elevation: 2,
              ),
              cardTheme: CardThemeData(
                color: const Color(0xFFFDF5E6), // Old Lace for cards
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
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
            builder: (context, child) {
              return Theme(
                data: Theme.of(context).copyWith(
                  textTheme: (switch (settings.fontFamily) {
                    'Amiri' => GoogleFonts.amiriTextTheme(
                      Theme.of(context).textTheme,
                    ),
                    'Cairo' => GoogleFonts.cairoTextTheme(
                      Theme.of(context).textTheme,
                    ),
                    _ => GoogleFonts.tajawalTextTheme(
                      Theme.of(context).textTheme,
                    ),
                  }).apply(fontFamilyFallback: ['Arial', 'Helvetica']),
                ),
                child: child!,
              );
            },
            home: const MainMenuScreen(),
          );
        },
      ),
    );
  }
}
