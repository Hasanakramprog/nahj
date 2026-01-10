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

  @override
  void initState() {
    super.initState();
    _loadData();
    _searchController.addListener(_onSearchChanged);
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

  void _showJumpToHikamDialog(BuildContext context) {
    final TextEditingController jumpController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'اذهب إلى رقم الحكمة',
          textAlign: TextAlign.center,
          style: TextStyle(fontFamily: 'Tajawal'),
        ),
        content: TextField(
          controller: jumpController,
          keyboardType: TextInputType.number,
          textAlign: TextAlign.center,
          decoration: const InputDecoration(
            hintText: 'أدخل رقم الحكمة',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء', style: TextStyle(fontFamily: 'Tajawal')),
          ),
          TextButton(
            onPressed: () {
              final num = int.tryParse(jumpController.text);
              if (num != null && num > 0 && num <= _allHikam.length) {
                Navigator.pop(context);
                // Find the hikam with this ID
                final hikam = _allHikam.firstWhere(
                  (h) => h.id == num.toString(),
                  orElse: () => _allHikam[num - 1],
                );
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => HikamDetailScreen(
                      hikam: hikam,
                      allHikam: _allHikam,
                      currentIndex: _allHikam.indexOf(hikam),
                    ),
                  ),
                );
              }
            },
            child: const Text('اذهب', style: TextStyle(fontFamily: 'Tajawal')),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'حِكَمِ أَمِير المؤمنين (عليه السلام)',
          style: settings.fonts[settings.fontFamily]!(
            fontWeight: FontWeight.bold,
            fontSize: 20,
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
          IconButton(
            icon: const Icon(Icons.tag),
            tooltip: 'اذهب إلى رقم الحكمة',
            onPressed: () => _showJumpToHikamDialog(context),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: TextField(
              controller: _searchController,
              style: settings.fonts[settings.fontFamily]!(fontSize: 16),
              textAlign: TextAlign.right,
              decoration: InputDecoration(
                hintText: 'بحث في الحكم...',
                hintStyle: settings.fonts[settings.fontFamily]!(
                  color: Colors.grey,
                ),
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                        },
                      )
                    : null,
                filled: true,
                fillColor: isDark ? Colors.grey[800] : Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _filteredHikam.isEmpty
          ? Center(
              child: Text(
                'لا توجد نتائج',
                style: settings.fonts[settings.fontFamily]!(
                  fontSize: 18,
                  color: Colors.grey,
                ),
              ),
            )
          : Container(
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF2C2C2C)
                    : const Color(0xFFE8F5E9), // Light green background
                image: const DecorationImage(
                  image: AssetImage('assets/images/old_paper_texture.png'),
                  fit: BoxFit.cover,
                  opacity: 0.3,
                ),
              ),
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(16),
                itemCount: _filteredHikam.length,
                itemBuilder: (context, index) {
                  final hikam = _filteredHikam[index];
                  final globalIndex = _allHikam.indexOf(hikam);

                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    elevation: 2,
                    color: isDark
                        ? const Color(0xFF3E3E3E)
                        : Colors.white, // Pure white for cards in light mode
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
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
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Number badge
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? Colors.amber.withOpacity(0.2)
                                    : Theme.of(
                                        context,
                                      ).primaryColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                hikam.id,
                                style: settings.fonts[settings.fontFamily]!(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: isDark
                                      ? Colors.amber
                                      : Theme.of(context).primaryColor,
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            // Text preview
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    hikam.displayTitle,
                                    style: settings.fonts[settings.fontFamily]!(
                                      fontSize: 16,
                                      height: 1.8,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  if (hikam.footnotes.isNotEmpty)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 8),
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.info_outline,
                                            size: 16,
                                            color: Colors.grey[600],
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            '${hikam.footnotes.length} حاشية',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey[600],
                                              fontFamily: 'Tajawal',
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ],
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
          color: isDark ? Colors.amber : const Color(0xFF00695C),
          size: 24,
        ),
        label: Text(
          'القائمة الرئيسية',
          style: TextStyle(
            fontFamily: 'Tajawal',
            color: isDark ? Colors.amber : const Color(0xFF00695C),
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        elevation: 6,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
          side: BorderSide(
            color: isDark ? Colors.amber : const Color(0xFF8D6E63),
            width: 2,
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
