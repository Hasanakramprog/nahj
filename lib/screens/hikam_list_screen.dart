import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/hikam_model.dart';
import '../services/hikam_service.dart';
import '../providers/settings_provider.dart';
import 'hikam_detail_screen.dart';
import 'main_menu_screen.dart';

class HikamListScreen extends StatefulWidget {
  const HikamListScreen({super.key});

  @override
  State<HikamListScreen> createState() => _HikamListScreenState();
}

class _HikamListScreenState extends State<HikamListScreen> {
  final HikamService _hikamService = HikamService();
  List<HikamModel> _allHikam = [];
  List<HikamModel> _filteredHikam = [];
  bool _isLoading = true;

  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final GlobalKey<TooltipState> _jumpTooltipKey = GlobalKey<TooltipState>();
  bool _isJumpPressed = false;

  @override
  void initState() {
    super.initState();
    _loadData();
    _searchController.addListener(_onSearchChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _runTooltipAnimation();
    });
  }

  Future<void> _runTooltipAnimation() async {
    await Future.delayed(const Duration(seconds: 1));
    if (!mounted) return;
    _jumpTooltipKey.currentState?.ensureTooltipVisible();
    setState(() => _isJumpPressed = true);
    await Future.delayed(const Duration(milliseconds: 200));
    setState(() => _isJumpPressed = false);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final hikam = await _hikamService.loadHikam();
    if (mounted) {
      setState(() {
        _allHikam = hikam;
        _filteredHikam = hikam;
        _isLoading = false;
      });
    }
  }

  void _onSearchChanged() {
    final query = _searchController.text;
    setState(() {
      _filteredHikam = _hikamService.search(query);
    });
  }

  @override
  Widget build(BuildContext context) {
    // Watch settings at the top level of build
    final settings = context.watch<SettingsProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final useHistoric = settings.useHistoricBackground;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'حِكَمِ أَمِير المؤمنين (عليه السلام)',
          style: settings.fonts[settings.fontFamily]!(
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        centerTitle: true,
        leadingWidth: 56,
        leading: IconButton(
          icon: Icon(
            settings.useSystemTheme
                ? Icons.brightness_auto
                : (isDark ? Icons.light_mode : Icons.dark_mode),
          ),
          tooltip: settings.useSystemTheme
              ? 'تلقائي (حسب النظام)'
              : (isDark ? 'الوضع الفاتح' : 'الوضع الداكن'),
          onPressed: () => settings.toggleThemeMode(),
        ),
        actions: [
          Tooltip(
            key: _jumpTooltipKey,
            message: 'اذهب إلى رقم الحكمة',
            child: AnimatedScale(
              scale: _isJumpPressed ? 0.8 : 1.0,
              duration: const Duration(milliseconds: 150),
              child: IconButton(
                icon: const Icon(Icons.tag),
                onPressed: () => _showJumpToHikamDialog(context),
              ),
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'بحث في الحكم...',
                hintStyle: settings.fonts[settings.fontFamily]!(
                  color: Colors.white70,
                ),
                prefixIcon: const Icon(Icons.search, color: Colors.white70),
                filled: true,
                fillColor: Colors.white.withOpacity(0.2),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
              style: settings.fonts[settings.fontFamily]!(color: Colors.white),
              cursorColor: Colors.white,
            ),
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _filteredHikam.isEmpty
          ? Center(
              child: Text(
                "لا توجد نتائج (0)",
                style: settings.fonts[settings.fontFamily]!(
                  fontSize: 18,
                  color: Colors.grey,
                ),
              ),
            )
          : RawScrollbar(
              thumbVisibility: true,
              controller: _scrollController,
              thumbColor: Theme.of(context).primaryColor,
              radius: const Radius.circular(20),
              thickness: 6,
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.symmetric(
                  vertical: 8,
                  horizontal: 16,
                ),
                itemCount: _filteredHikam.length,
                itemBuilder: (context, index) {
                  final hikam = _filteredHikam[index];
                  final globalIndex = _allHikam.indexOf(hikam);
                  final heroTag = 'hikam_${hikam.id}';

                  final numberColor = isDark
                      ? Colors.amber
                      : Theme.of(context).primaryColor;
                  final textColor = isDark
                      ? Colors.white
                      : const Color(0xFF00695C); // Green for light mode

                  return Hero(
                    tag: heroTag,
                    child: Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      elevation: 2,
                      clipBehavior: Clip.antiAlias,
                      color: useHistoric ? Colors.transparent : null,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(
                          color: Theme.of(
                            context,
                          ).primaryColor.withOpacity(0.1),
                          width: 1,
                        ),
                      ),
                      child: Container(
                        width: double.infinity,
                        decoration: useHistoric
                            ? BoxDecoration(
                                image: DecorationImage(
                                  image: const AssetImage(
                                    'assets/images/old_paper_texture.png',
                                  ),
                                  fit: BoxFit.fill,
                                  colorFilter: isDark
                                      ? ColorFilter.mode(
                                          Colors.black.withOpacity(0.8),
                                          BlendMode.darken,
                                        )
                                      : null,
                                ),
                              )
                            : null,
                        child: InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => HikamDetailScreen(
                                  hikam: hikam,
                                  searchQuery: _searchController.text.isNotEmpty
                                      ? _searchController.text
                                      : null,
                                  allHikam: _allHikam,
                                  currentIndex: globalIndex,
                                ),
                              ),
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      width: 40,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        color: isDark
                                            ? Colors.amber.withOpacity(0.2)
                                            : Theme.of(
                                                context,
                                              ).primaryColor.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      alignment: Alignment.center,
                                      child: Text(
                                        hikam.id,
                                        style:
                                            settings.fonts[settings
                                                .fontFamily]!(
                                              color: numberColor,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    // Title / Preview
                                    Expanded(
                                      child: Text(
                                        hikam.displayTitle,
                                        style:
                                            settings.fonts[settings
                                                .fontFamily]!(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              height: 1.5,
                                              color: textColor,
                                            ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                                if (hikam.footnotes.isNotEmpty) ...[
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.info_outline,
                                        size: 16,
                                        color: isDark
                                            ? Colors.white60
                                            : Colors.grey[700],
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        '${hikam.footnotes.length} حاشية',
                                        style:
                                            settings.fonts[settings
                                                .fontFamily]!(
                                              fontSize: 12,
                                              color: isDark
                                                  ? Colors.white60
                                                  : Colors.grey[700],
                                            ),
                                      ),
                                    ],
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const MainMenuScreen()),
            (route) => false,
          );
        },
        backgroundColor: isDark ? const Color(0xFF2d2d2d) : Colors.white,
        icon: Icon(
          Icons.home_rounded,
          color: isDark
              ? Colors.amber
              : const Color(0xFF00695C), // Green for light mode
          size: 24,
        ),
        label: Text(
          'القائمة الرئيسية',
          style: TextStyle(
            fontFamily: 'Tajawal',
            color: isDark
                ? Colors.amber
                : const Color(0xFF00695C), // Green for light mode
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        elevation: 6,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
          side: BorderSide(
            color: isDark
                ? Colors.amber.withOpacity(0.5)
                : const Color(0xFF8D6E63),
            width: 2,
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  void _showJumpToHikamDialog(BuildContext context) {
    final TextEditingController jumpController = TextEditingController();
    // Use showDialog builder to get context with providers if needed
    showDialog(
      context: context,
      builder: (context) {
        final settings = context.watch<SettingsProvider>();
        return AlertDialog(
          title: Text(
            'اذهب إلى رقم الحكمة',
            style: settings.fonts[settings.fontFamily]!(
              fontWeight: FontWeight.bold,
            ),
          ),
          content: TextField(
            controller: jumpController,
            keyboardType: TextInputType.number,
            autofocus: true,
            decoration: const InputDecoration(
              hintText: 'أدخل رقم الحكمة',
              border: OutlineInputBorder(),
            ),
            onSubmitted: (_) {
              _handleJumpToHikam(context, jumpController.text);
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'إلغاء',
                style: settings.fonts[settings.fontFamily]!(color: Colors.grey),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                _handleJumpToHikam(context, jumpController.text);
              },
              child: Text(
                'اذهب',
                style: settings.fonts[settings.fontFamily]!(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _handleJumpToHikam(BuildContext context, String input) {
    if (input.isNotEmpty) {
      final settings = context.read<SettingsProvider>();
      final numValue = int.tryParse(input);
      if (numValue != null && numValue > 0 && numValue <= _allHikam.length) {
        Navigator.pop(context);
        // Find the hikam with this ID (assuming id matches index+1 roughly or just finding by valid range)
        // Note: The previous logic relied on _filteredHikam or _allHikam usage.
        // Assuming IDs are effectively 1-based indices or sequential.
        // The previous code: _allHikam[num - 1] (if index backup).
        // Let's stick to safe index access.

        final index = numValue - 1;
        if (index < _allHikam.length) {
          final hikam = _allHikam[index];
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => HikamDetailScreen(
                hikam: hikam,
                allHikam: _allHikam,
                currentIndex: index,
              ),
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'رقم غير صحيح (1-${_allHikam.length})',
              style: settings.fonts[settings.fontFamily]!(),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
