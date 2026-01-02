import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/content_model.dart';
import '../services/data_service.dart';
import '../providers/bookmarks_provider.dart';
import '../providers/settings_provider.dart';
import 'bookmarks_screen.dart';
import 'detail_screen.dart';
import 'index_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final DataService _dataService = DataService();
  List<SermonModel> _allSermons = [];
  List<SermonModel> _filteredSermons = [];
  bool _isLoading = true;

  final TextEditingController _searchController = TextEditingController();

  final ScrollController _scrollController = ScrollController();

  final GlobalKey<TooltipState> _indexTooltipKey = GlobalKey<TooltipState>();
  final GlobalKey<TooltipState> _bookmarksTooltipKey =
      GlobalKey<TooltipState>();
  final GlobalKey<TooltipState> _jumpTooltipKey = GlobalKey<TooltipState>();

  bool _isIndexPressed = false;
  bool _isBookmarksPressed = false;
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
    _indexTooltipKey.currentState?.ensureTooltipVisible();
    setState(() => _isIndexPressed = true);
    await Future.delayed(const Duration(milliseconds: 200));
    setState(() => _isIndexPressed = false);

    await Future.delayed(const Duration(seconds: 1));
    if (!mounted) return;
    _bookmarksTooltipKey.currentState?.ensureTooltipVisible();
    setState(() => _isBookmarksPressed = true);
    await Future.delayed(const Duration(milliseconds: 200));
    setState(() => _isBookmarksPressed = false);

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
    final sermons = await _dataService.loadData();
    if (mounted) {
      setState(() {
        _allSermons = sermons;
        _filteredSermons = sermons;
        _isLoading = false;
      });
    }
  }

  void _onSearchChanged() {
    final query = _searchController.text;
    setState(() {
      _filteredSermons = _dataService.search(query);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "نهج البلاغة",
          style: GoogleFonts.tajawal(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        leadingWidth: 96,
        leading: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Consumer<SettingsProvider>(
              builder: (context, settings, child) {
                return IconButton(
                  icon: Icon(
                    settings.isDarkMode ? Icons.light_mode : Icons.dark_mode,
                  ),
                  tooltip: settings.isDarkMode
                      ? 'الوضع الفاتح'
                      : 'الوضع الداكن',
                  onPressed: () => settings.toggleThemeMode(),
                );
              },
            ),
            Tooltip(
              key: _indexTooltipKey,
              message: 'فهرس الخطب',
              child: AnimatedScale(
                scale: _isIndexPressed ? 0.8 : 1.0,
                duration: const Duration(milliseconds: 150),
                child: IconButton(
                  icon: const Icon(Icons.grid_view),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const IndexScreen(),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
        actions: [
          Tooltip(
            key: _bookmarksTooltipKey,
            message: 'الخطب المحفوظة',
            child: AnimatedScale(
              scale: _isBookmarksPressed ? 0.8 : 1.0,
              duration: const Duration(milliseconds: 150),
              child: IconButton(
                icon: const Icon(Icons.bookmarks),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const BookmarksScreen(),
                    ),
                  );
                },
              ),
            ),
          ),
          Tooltip(
            key: _jumpTooltipKey,
            message: 'اذهب إلى رقم الخطبة',
            child: AnimatedScale(
              scale: _isJumpPressed ? 0.8 : 1.0,
              duration: const Duration(milliseconds: 150),
              child: IconButton(
                icon: const Icon(Icons.tag),
                onPressed: () => _showJumpToSermonDialog(context),
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
                hintText: 'بحث...',
                hintStyle: GoogleFonts.tajawal(color: Colors.white70),
                prefixIcon: const Icon(Icons.search, color: Colors.white70),
                filled: true,
                fillColor: Colors.white.withOpacity(0.2),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
              style: GoogleFonts.tajawal(color: Colors.white),
              cursorColor: Colors.white,
            ),
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _filteredSermons.isEmpty
          ? Center(
              child: Text(
                "لا توجد نتائج",
                style: GoogleFonts.tajawal(fontSize: 18, color: Colors.grey),
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
                itemCount: _filteredSermons.length,
                itemBuilder: (context, index) {
                  final sermon = _filteredSermons[index];
                  final heroTag = 'sermon_${sermon.title.hashCode}';

                  final settings = context.watch<SettingsProvider>();
                  final isDark = settings.isDarkMode;
                  final useHistoric = settings.useHistoricBackground;

                  final titleColor = isDark
                      ? Colors.amber
                      : const Color(0xFF5D4037);
                  final numberColor = isDark
                      ? Colors.amber
                      : Theme.of(context).primaryColor;
                  final textColor = isDark
                      ? Colors.white
                      : const Color(0xFF4E342E);

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
                                builder: (context) => DetailScreen(
                                  sermon: sermon,
                                  heroTag: heroTag,
                                  searchQuery: _searchController.text.isNotEmpty
                                      ? _searchController.text
                                      : null,
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
                                        "${index + 1}",
                                        style: GoogleFonts.tajawal(
                                          color: numberColor,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        sermon.title,
                                        style: GoogleFonts.tajawal(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          height: 1.3,
                                          color: titleColor,
                                        ),
                                      ),
                                    ),
                                    if (context
                                        .watch<BookmarksProvider>()
                                        .isBookmarked(sermon.title))
                                      const Padding(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 8,
                                        ),
                                        child: Icon(
                                          Icons.bookmark,
                                          color: Colors.amber,
                                          size: 20,
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                if (sermon.text.isNotEmpty)
                                  Text(
                                    sermon.text.contains('\n\n')
                                        ? sermon.text.substring(
                                            0,
                                            sermon.text.indexOf('\n\n'),
                                          )
                                        : sermon.text,
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.amiri(
                                      fontSize: 16,
                                      color: textColor,
                                      height: 1.8,
                                    ),
                                  ),
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
    );
  }

  void _showJumpToSermonDialog(BuildContext context) {
    final TextEditingController numberController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            'اذهب إلى الخطبة برقم',
            style: GoogleFonts.tajawal(fontWeight: FontWeight.bold),
          ),
          content: TextField(
            controller: numberController,
            keyboardType: TextInputType.number,
            autofocus: true,
            decoration: const InputDecoration(
              hintText: 'أدخل رقم الخطبة',
              border: OutlineInputBorder(),
            ),
            onSubmitted: (_) {
              _handleJumpToSermon(context, numberController.text);
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'إلغاء',
                style: GoogleFonts.tajawal(color: Colors.grey),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                _handleJumpToSermon(context, numberController.text);
              },
              child: Text(
                'اذهب',
                style: GoogleFonts.tajawal(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }

  void _handleJumpToSermon(BuildContext context, String input) {
    if (input.isNotEmpty) {
      final number = int.tryParse(input);
      if (number != null && number > 0 && number <= _allSermons.length) {
        Navigator.pop(context); // Close dialog
        _navigateToSermon(number - 1);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'رقم غير صحيح (1-${_allSermons.length})',
              style: GoogleFonts.tajawal(),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _navigateToSermon(int index) {
    if (index >= 0 && index < _allSermons.length) {
      final sermon = _allSermons[index];
      // Use a generic hero tag for jumps to avoid conflict or just standard transition
      // We will reuse the same logic for Hero tag generation if possible or just unique
      final heroTag = 'jump_to_sermon_$index';

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => DetailScreen(
            sermon: sermon,
            heroTag: heroTag,
            searchQuery: _searchController.text.isNotEmpty
                ? _searchController.text
                : null,
          ),
        ),
      );
    }
  }
}
