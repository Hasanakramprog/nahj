import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';
import 'home_screen.dart'; // Import ContentListScreen (file name is still home_screen.dart)

class MainMenuScreen extends StatelessWidget {
  const MainMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final isDark = settings.isDarkMode;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          "نهج البلاغة",
          style: settings.fonts[settings.fontFamily]!(
            fontWeight: FontWeight.bold,
            fontSize: 32,
            color: isDark ? const Color(0xFFD4AF37) : const Color(0xFF5D4037),
            shadows: [
              Shadow(
                offset: const Offset(1, 1),
                blurRadius: 2,
                color: Colors.black.withOpacity(0.3),
              ),
            ],
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(
              settings.isDarkMode ? Icons.light_mode : Icons.dark_mode,
              color: isDark ? const Color(0xFFD4AF37) : const Color(0xFF5D4037),
            ),
            tooltip: settings.isDarkMode ? 'الوضع الفاتح' : 'الوضع الداكن',
            onPressed: () => settings.toggleThemeMode(),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF2C2C2C) : const Color(0xFFF5E6CA),
          image: const DecorationImage(
            image: AssetImage('assets/images/old_paper_texture.png'),
            fit: BoxFit.cover,
            opacity: 0.6, // Blend texture
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 80), // Spacing for AppBar
                _buildHistoricMenuButton(
                  context,
                  title:
                      " مِنْ خُطب مولانا أمير المؤُمِنين عليّ بن أبي طالب (عليه السلام)",
                  icon: Icons.mic_external_on, // More distinct icon
                  jsonPath: "assets/scraped_output_cleaned.json",
                ),
                const SizedBox(height: 30),
                _buildHistoricMenuButton(
                  context,
                  title: " مِنْ كتب أَمِير المؤمنين (عليه السلام) ورسائله",
                  icon: Icons.mark_email_unread_outlined, // More distinct icon
                  jsonPath: "assets/letters_output_cleaned.json",
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHistoricMenuButton(
    BuildContext context, {
    required String title,
    required IconData icon,
    required String jsonPath,
  }) {
    final settings = context.watch<SettingsProvider>();
    final isDark = settings.isDarkMode;

    // Determine display title based on the full title for NAVIGATION
    String navTitle = title;
    if (title == " مِنْ كتب أَمِير المؤمنين (عليه السلام) ورسائله") {
      navTitle = "رسائل";
    } else if (title ==
        " مِنْ خُطب مولانا أمير المؤُمِنين عليّ بن أبي طالب (عليه السلام)") {
      navTitle = "خُطب";
    }

    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxWidth: 400),
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF3E2723).withOpacity(0.9) // Dark Brown
            : const Color(0xFFFFF8E1).withOpacity(0.9), // Cream
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: isDark ? const Color(0xFFD4AF37) : const Color(0xFF8D6E63),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(15),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    ContentListScreen(title: navTitle, jsonPath: jsonPath),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
            child: Column(
              children: [
                // Ornamental Divider Top
                Icon(
                  Icons.auto_awesome, // Decorative icon
                  size: 20,
                  color: isDark
                      ? const Color(0xFFD4AF37)
                      : const Color(0xFF8D6E63),
                ),
                const SizedBox(height: 12),
                Icon(
                  icon,
                  size: 48,
                  color: isDark
                      ? const Color(0xFFD4AF37)
                      : const Color(0xFF5D4037),
                ),
                const SizedBox(height: 16),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: settings.fonts[settings.fontFamily]!(
                    fontSize: 22, // Keep large size
                    fontWeight: FontWeight.bold,
                    height: 1.5,
                    color: isDark
                        ? const Color(0xFFFFECB3)
                        : const Color(0xFF3E2723),
                  ),
                ),
                const SizedBox(height: 12),
                // Ornamental Divider Bottom
                Icon(
                  Icons.spa, // Decorative floral icon
                  size: 20,
                  color: isDark
                      ? const Color(0xFFD4AF37)
                      : const Color(0xFF8D6E63),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
