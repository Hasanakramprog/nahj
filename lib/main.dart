import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'providers/bookmarks_provider.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const NahjApp());
}

class NahjApp extends StatelessWidget {
  const NahjApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => BookmarksProvider())],
      child: MaterialApp(
        title: 'نهج البلاغة',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF00695C), // Islamic Teal
            secondary: const Color(0xFFFFC107), // Gold accent
            surface: const Color(0xFFFAFAFA), // Cream background
          ),
          scaffoldBackgroundColor: const Color(0xFFFAFAFA),
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFF00695C),
            foregroundColor: Colors.white,
            elevation: 0,
          ),
          textTheme: GoogleFonts.tajawalTextTheme(),
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
      ),
    );
  }
}
