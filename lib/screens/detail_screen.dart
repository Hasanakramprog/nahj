import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import '../models/content_model.dart';
import '../providers/bookmarks_provider.dart';
import '../providers/settings_provider.dart';
import '../utils/arabic_utils.dart';

class DetailScreen extends StatefulWidget {
  final SermonModel sermon;
  final String? heroTag;
  final String? searchQuery;

  const DetailScreen({
    super.key,
    required this.sermon,
    this.heroTag,
    this.searchQuery,
  });

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  final ItemScrollController _itemScrollController = ItemScrollController();
  final ItemPositionsListener _itemPositionsListener =
      ItemPositionsListener.create();
  List<String> _paragraphs = [];
  double _readingProgress = 0.0;
  bool _showControls = false;
  int? _firstMatchIndex;

  @override
  void initState() {
    super.initState();
    _paragraphs = ArabicUtils.splitByPeriods(widget.sermon.text);
    _itemPositionsListener.itemPositions.addListener(_onScroll);

    // Find first match if search query exists
    if (widget.searchQuery != null && widget.searchQuery!.isNotEmpty) {
      final query = ArabicUtils.normalize(widget.searchQuery!);
      for (int i = 0; i < _paragraphs.length; i++) {
        if (ArabicUtils.normalize(_paragraphs[i]).contains(query)) {
          _firstMatchIndex = i + 2; // +2 for Title and Divider
          break;
        }
      }

      if (_firstMatchIndex != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _itemScrollController.jumpTo(index: _firstMatchIndex!);
        });
      }
    }
  }

  @override
  void dispose() {
    _itemPositionsListener.itemPositions.removeListener(_onScroll);
    super.dispose();
  }

  void _onScroll() {
    final positions = _itemPositionsListener.itemPositions.value;
    if (positions.isEmpty) return;

    // Filter out invisible items if any (sometimes listener returns items with negative index or off-screen)
    // Though usually it returns visible items.

    // Sort to be sure
    final sorted = positions.toList()
      ..sort((a, b) => a.index.compareTo(b.index));
    final lastRequestIndex = sorted.last.index;

    // Total items count is _paragraphs.length + 2.
    // Indices are 0 to (_paragraphs.length + 1).
    final maxIndex = _paragraphs.length + 1;

    if (maxIndex <= 0) {
      setState(() => _readingProgress = 1.0);
      return;
    }

    setState(() {
      // If we are at the very end, make sure it is 1.0
      if (lastRequestIndex >= maxIndex) {
        _readingProgress = 1.0;
      } else {
        // Calculate progress ratio
        _readingProgress = (lastRequestIndex / maxIndex).clamp(0.0, 1.0);
      }
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

  TextSpan _buildHighlightedText(String text, TextStyle style) {
    if (widget.searchQuery == null || widget.searchQuery!.isEmpty) {
      return TextSpan(text: text, style: style);
    }

    final String query = ArabicUtils.normalize(widget.searchQuery!);
    if (query.isEmpty) return TextSpan(text: text, style: style);

    // Build a regex that matches the query in the original text, ignoring diacritics
    StringBuffer buffer = StringBuffer();
    for (int i = 0; i < query.length; i++) {
      String char = query[i];
      // Escape special regex characters
      if (RegExp(r'[.\[\]{}()\\*+?|^$]').hasMatch(char)) {
        char = '\\$char';
      }

      // Handle character variations
      if (char == 'ا') {
        buffer.write('[اأإآ]');
      } else if (char == 'ي') {
        buffer.write('[يى]');
      } else if (char == 'ه') {
        buffer.write('[هة]');
      } else {
        buffer.write(char);
      }

      // Allow diacritics between characters
      buffer.write(r'[\u064B-\u065F\u06D6-\u06ED]*');
    }

    final RegExp regex = RegExp(buffer.toString());
    final List<TextSpan> spans = [];
    int start = 0;

    for (final Match match in regex.allMatches(text)) {
      // Text before match
      if (match.start > start) {
        spans.add(
          TextSpan(text: text.substring(start, match.start), style: style),
        );
      }

      // Highlighted match
      spans.add(
        TextSpan(
          text: text.substring(match.start, match.end),
          style: style.copyWith(
            backgroundColor: Colors.amber.withOpacity(0.5),
            color: Colors.black, // Ensure contrast to be visible on highlight
          ),
        ),
      );

      start = match.end;
    }

    // Remaining text
    if (start < text.length) {
      spans.add(TextSpan(text: text.substring(start), style: style));
    }

    return TextSpan(children: spans);
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

        Widget content = ScrollablePositionedList.builder(
          itemScrollController: _itemScrollController,
          itemPositionsListener: _itemPositionsListener,
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
                  style: settings.fonts[settings.fontFamily]!(
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
                child: SelectableText.rich(
                  _buildHighlightedText(
                    _paragraphs[index - 2],
                    settings.fonts[settings.fontFamily]!(
                      fontSize: settings.fontSize,
                      height: 1.8,
                      color: textColor,
                    ),
                  ),
                  textAlign: TextAlign.justify,
                ),
              );
            }
          },
        );

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
              if (_showControls) ...[
                Positioned.fill(
                  child: GestureDetector(
                    onTap: () => setState(() => _showControls = false),
                    behavior: HitTestBehavior.opaque,
                    child: Container(color: Colors.transparent),
                  ),
                ),
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
                        // Font Family Selection
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: settings.fonts.keys.map((fontFamily) {
                              final isSelected =
                                  settings.fontFamily == fontFamily;
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 4,
                                ),
                                child: ChoiceChip(
                                  label: Text(
                                    fontFamily,
                                    style: settings.fonts[fontFamily]!(
                                      color: isSelected
                                          ? Colors.white
                                          : textColor,
                                      fontWeight: isSelected
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                    ),
                                  ),
                                  selected: isSelected,
                                  onSelected: (selected) {
                                    if (selected) {
                                      settings.setFontFamily(fontFamily);
                                    }
                                  },
                                  selectedColor: Colors.amber,
                                  backgroundColor: isDark
                                      ? const Color(0xFF1a1a1a)
                                      : Colors.grey[100],
                                  side: BorderSide(
                                    color: isSelected
                                        ? Colors.amber
                                        : Colors.grey.withOpacity(0.3),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
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
            ],
          ),
        );
      },
    );
  }
}
