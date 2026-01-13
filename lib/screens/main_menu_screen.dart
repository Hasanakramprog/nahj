import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';
import '../services/hikam_service.dart';
import '../models/hikam_model.dart';
import 'home_screen.dart'; // Import ContentListScreen
import 'hikam_list_screen.dart';
import 'hikam_detail_screen.dart';

class MainMenuScreen extends StatefulWidget {
  const MainMenuScreen({super.key});

  @override
  State<MainMenuScreen> createState() => _MainMenuScreenState();
}

class _MainMenuScreenState extends State<MainMenuScreen>
    with SingleTickerProviderStateMixin {
  late Future<HikamModel?> _randomHikamFuture;
  final HikamService _hikamService = HikamService();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _randomHikamFuture = _loadRandomHikam();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<HikamModel?> _loadRandomHikam() async {
    // Only load once, then pick random locally if we want to avoid reloading file?
    // HikamService usually loads from asset each time unless cached in service (it is cached in service instance but we create new instance here).
    // Ideally HikamService should be a singleton or provider, but for now this is fine.
    try {
      final hikamList = await _hikamService.loadHikam();
      if (hikamList.isEmpty) return null;
      final random = Random();
      return hikamList[random.nextInt(hikamList.length)];
    } catch (e) {
      debugPrint("Error loading random hikma: $e");
      return null;
    }
  }

  void _refreshRandomHikam() {
    setState(() {
      _randomHikamFuture = _loadRandomHikam();
      _animationController.reset();
      _animationController.forward();
    });
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 400;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          "نهج البلاغة",
          style: settings.fonts[settings.fontFamily]!(
            fontWeight: FontWeight.bold,
            fontSize: isSmallScreen ? 20 : 28,
            color: isDark ? const Color(0xFFD4AF37) : const Color(0xFF00695C),
            shadows: [
              Shadow(
                offset: const Offset(1, 1),
                blurRadius: 2,
                color: Colors.black.withOpacity(0.3),
              ),
            ],
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              settings.useSystemTheme
                  ? Icons.brightness_auto
                  : (isDark ? Icons.light_mode : Icons.dark_mode),
              color: isDark ? const Color(0xFFD4AF37) : const Color(0xFF00695C),
            ),
            tooltip: settings.useSystemTheme
                ? 'تلقائي (حسب النظام)'
                : (isDark ? 'الوضع الفاتح' : 'الوضع الداكن'),
            onPressed: () => settings.toggleThemeMode(),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1a1a1a) : const Color(0xFFF5F5F5),
          // image: const DecorationImage(
          //   image: AssetImage('assets/images/old_paper_texture.png'),
          //   fit: BoxFit.cover,
          //   opacity: 0.1,
          // ),
        ),
        child: SafeArea(
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // 1. Random Hikma Section
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: _buildDailyHikmaCard(context, settings, isDark),
                  ),
                ),
              ),

              // 2. Navigation Grid Header
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 10,
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 4,
                        height: 24,
                        decoration: BoxDecoration(
                          color: isDark
                              ? Colors.amber
                              : const Color(0xFF00695C),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'الأقسام الرئيسية',
                        style: settings.fonts[settings.fontFamily]!(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // 3. Navigation Cards
              SliverPadding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    _buildNavCard(
                      context,
                      title: "الخُطب",
                      subtitle: "مِنْ خُطب مولانا أمير المؤُمِنين (ع)",
                      icon: Icons.mic_external_on,
                      color: const Color(0xFF00695C),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ContentListScreen(
                              title: "خُطب",
                              jsonPath: "assets/scraped_output_cleaned.json",
                            ),
                          ),
                        );
                      },
                      isDark: isDark,
                      settings: settings,
                      imageAsset:
                          'assets/images/old_paper_texture.png', // Fallback or specific image
                    ),
                    const SizedBox(height: 16),
                    _buildNavCard(
                      context,
                      title: "الرسائل",
                      subtitle: "مِنْ كتب أَمِير المؤمنين (ع) ورسائله",
                      icon: Icons.mark_email_unread_outlined,
                      color: const Color(0xFF5D4037), // Brownish
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ContentListScreen(
                              title: "رسائل",
                              jsonPath: "assets/letters_output_cleaned.json",
                            ),
                          ),
                        );
                      },
                      isDark: isDark,
                      settings: settings,
                    ),
                    const SizedBox(height: 16),
                    _buildNavCard(
                      context,
                      title: "الحِكَم",
                      subtitle: "قِصار الحِكَم والمواعظ",
                      icon: Icons.lightbulb_outline,
                      color: const Color(0xFF455A64), // Blue Grey
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const HikamListScreen(),
                          ),
                        );
                      },
                      isDark: isDark,
                      settings: settings,
                    ),
                    const SizedBox(height: 40),
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDailyHikmaCard(
    BuildContext context,
    SettingsProvider settings,
    bool isDark,
  ) {
    return FutureBuilder<HikamModel?>(
      future: _randomHikamFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Card(
            elevation: 4,
            child: SizedBox(
              height: 200,
              child: Center(child: CircularProgressIndicator()),
            ),
          );
        }

        if (snapshot.hasError || !snapshot.hasData) {
          return const SizedBox.shrink();
        }

        final hikma = snapshot.data!;

        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? [const Color(0xFF424242), const Color(0xFF212121)]
                  : [const Color(0xFFFFFbf0), const Color(0xFFFFF3E0)],
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () {
                // Navigate to detail of this Hikma
                // We need to pass all hikam list for next/prev support, but for random view single item is fine
                // Or we could pass just this one.
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => HikamDetailScreen(
                      hikam: hikma,
                      allHikam: [hikma], // No next/prev context for random
                      currentIndex: 0,
                    ),
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.auto_awesome,
                              color: isDark ? Colors.amber : Colors.orange,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              "حكمة اليوم",
                              style: settings.fonts[settings.fontFamily]!(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: isDark
                                    ? Colors.amber
                                    : Colors.orange[800],
                              ),
                            ),
                          ],
                        ),
                        IconButton(
                          icon: const Icon(Icons.refresh),
                          onPressed: _refreshRandomHikam,
                          tooltip: 'حكمة أخرى',
                          color: isDark ? Colors.grey : Colors.grey[600],
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          iconSize: 20,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      (hikma.text.length > 200
                              ? "${hikma.text.substring(0, 200)}..."
                              : hikma.text)
                          .replaceAll(RegExp(r'[0-9\[\]\(\)]+'), '')
                          .replaceAll('..', '.') // Cleanup double dots if any
                          .trim(),
                      textAlign: TextAlign.center,
                      style: settings.fonts[settings.fontFamily]!(
                        fontSize: 20, // Slightly larger for impact
                        height: 1.8,
                        color: isDark ? Colors.white : const Color(0xFF3E2723),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "اضغط للقراءة الكاملة",
                      style: TextStyle(
                        fontFamily: 'Tajawal',
                        fontSize: 12,
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildNavCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    required bool isDark,
    required SettingsProvider settings,
    String? imageAsset,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2C2C2C) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(isDark ? 0.3 : 0.1),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: color, size: 30),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: settings.fonts[settings.fontFamily]!(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : color,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: settings.fonts[settings.fontFamily]!(
                          fontSize: 14,
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                          height: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: isDark ? Colors.grey[600] : Colors.grey[400],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
