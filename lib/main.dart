import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'providers/bookmarks_provider.dart';
import 'providers/settings_provider.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const NahjApp());
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
              textTheme: GoogleFonts.tajawalTextTheme(),
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
              textTheme: GoogleFonts.tajawalTextTheme(
                ThemeData.dark().textTheme,
              ),
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
            home: const HomeScreen(),
          );
        },
      ),
    );
  }
}
