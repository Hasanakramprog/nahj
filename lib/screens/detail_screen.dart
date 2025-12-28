import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../models/content_model.dart';
import '../providers/bookmarks_provider.dart';
import '../providers/settings_provider.dart';
import '../utils/arabic_utils.dart';

class DetailScreen extends StatefulWidget {
  final SermonModel sermon;
  final String? heroTag;

  const DetailScreen({super.key, required this.sermon, this.heroTag});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  final ScrollController _scrollController = ScrollController();
  List<String> _paragraphs = [];
  double _readingProgress = 0.0;
  bool _showControls = false;

  @override
  void initState() {
    super.initState();
    _paragraphs = ArabicUtils.splitByPeriods(widget.sermon.text);
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    setState(() {
      _readingProgress = (currentScroll / maxScroll).clamp(0.0, 1.0);
    });
  }

  void _shareContent(BuildContext context) {
    final String content = "${widget.sermon.title}\n\n${widget.sermon.text}";
    Share.share(content);
  }

  void _toggleControls() {
    setState(() {
      _showControls = !_showControls;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settings, child) {
        final isDark = settings.isDarkMode;
        final backgroundColor = isDark ? const Color(0xFF1a1a1a) : Colors.white;
        final textColor = isDark ? Colors.white : Colors.black87;
        final titleColor = isDark
            ? Colors.amber
            : Theme.of(context).primaryColor;

        Widget content = ListView.builder(
          controller: _scrollController,
          padding: const EdgeInsets.all(20.0),
          itemCount: _paragraphs.length + 2, // Title + Divider + Paragraphs
          itemBuilder: (context, index) {
            if (index == 0) {
              // Title
              return Padding(
                padding: const EdgeInsets.only(bottom: 20.0),
                child: SelectableText(
                  widget.sermon.title,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.tajawal(
                    fontSize: settings.fontSize + 2,
                    fontWeight: FontWeight.bold,
                    color: titleColor,
                    height: 1.5,
                  ),
                ),
              );
            } else if (index == 1) {
              // Divider
              return Padding(
                padding: const EdgeInsets.only(bottom: 20.0),
                child: Divider(
                  thickness: 1,
                  color: isDark ? Colors.grey[700] : null,
                ),
              );
            } else {
              // Paragraphs
              return Padding(
                padding: const EdgeInsets.fromLTRB(0, 0, 0, 16),
                child: SelectableText(
                  _paragraphs[index - 2],
                  textAlign: TextAlign.justify,
                  style: GoogleFonts.amiri(
                    fontSize: settings.fontSize,
                    height: 1.8,
                    color: textColor,
                  ),
                ),
              );
            }
          },
        );

        if (widget.heroTag != null) {
          content = Hero(
            tag: widget.heroTag!,
            child: Material(type: MaterialType.transparency, child: content),
          );
        }

        return Scaffold(
          backgroundColor: backgroundColor,
          appBar: AppBar(
            backgroundColor: isDark ? const Color(0xFF2d2d2d) : null,
            title: Text(
              "نهج البلاغة",
              style: GoogleFonts.tajawal(fontWeight: FontWeight.bold),
            ),
            centerTitle: true,
            actions: [
              IconButton(
                icon: Icon(_showControls ? Icons.close : Icons.settings),
                tooltip: _showControls ? 'إخفاء الإعدادات' : 'الإعدادات',
                onPressed: _toggleControls,
              ),
              Consumer<BookmarksProvider>(
                builder: (context, bookmarks, child) {
                  final isBookmarked = bookmarks.isBookmarked(
                    widget.sermon.title,
                  );
                  return IconButton(
                    icon: Icon(
                      isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                      color: isBookmarked ? Colors.amber : null,
                    ),
                    tooltip: isBookmarked ? 'إزالة من المحفوظات' : 'حفظ الخطبة',
                    onPressed: () {
                      bookmarks.toggleBookmark(widget.sermon.title);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            isBookmarked
                                ? 'تم الإزالة من المحفوظات'
                                : 'تم الحفظ في المحفوظات',
                            style: GoogleFonts.tajawal(),
                          ),
                          duration: const Duration(seconds: 1),
                          backgroundColor: isDark
                              ? const Color(0xFF2d2d2d)
                              : null,
                        ),
                      );
                    },
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.share),
                tooltip: 'مشاركة الخطبة',
                onPressed: () => _shareContent(context),
              ),
            ],
          ),
          body: Stack(
            children: [
              SafeArea(child: content),
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: LinearProgressIndicator(
                  value: _readingProgress,
                  backgroundColor: isDark
                      ? const Color(0xFF2d2d2d)
                      : Colors.grey[200],
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.amber),
                  minHeight: 4,
                ),
              ),
              if (_showControls)
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF2d2d2d) : Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    child: Column(
                      children: [
                        // Font Size Controls
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'حجم الخط',
                              style: GoogleFonts.tajawal(
                                fontSize: 14,
                                color: textColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Container(
                              decoration: BoxDecoration(
                                color: isDark
                                    ? const Color(0xFF1a1a1a)
                                    : Colors.grey[100],
                                borderRadius: BorderRadius.circular(25),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.remove),
                                    iconSize: 20,
                                    color: settings.fontSize <= 14
                                        ? Colors.grey
                                        : textColor,
                                    onPressed: settings.fontSize <= 14
                                        ? null
                                        : () => settings.decreaseFontSize(),
                                    tooltip: 'تصغير الخط',
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                    ),
                                    child: Text(
                                      '${settings.fontSize.toInt()}',
                                      style: GoogleFonts.tajawal(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: titleColor,
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.add),
                                    iconSize: 20,
                                    color: settings.fontSize >= 32
                                        ? Colors.grey
                                        : textColor,
                                    onPressed: settings.fontSize >= 32
                                        ? null
                                        : () => settings.increaseFontSize(),
                                    tooltip: 'تكبير الخط',
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        // Theme Toggle
                        InkWell(
                          onTap: () => settings.toggleThemeMode(),
                          borderRadius: BorderRadius.circular(25),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? const Color(0xFF1a1a1a)
                                  : Colors.grey[100],
                              borderRadius: BorderRadius.circular(25),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  isDark ? Icons.dark_mode : Icons.light_mode,
                                  size: 20,
                                  color: titleColor,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  isDark ? 'الوضع الداكن' : 'الوضع الفاتح',
                                  style: GoogleFonts.tajawal(
                                    fontSize: 14,
                                    color: textColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Switch(
                                  value: isDark,
                                  onChanged: (_) => settings.toggleThemeMode(),
                                  activeColor: Colors.amber,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
