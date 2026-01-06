import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import '../models/content_model.dart';
import '../providers/bookmarks_provider.dart';
import '../providers/settings_provider.dart';
import '../services/data_service.dart';
import '../utils/arabic_utils.dart';
import 'explanation_detail_screen.dart';

class DetailScreen extends StatefulWidget {
  final SermonModel sermon;
  final String? heroTag;
  final String? searchQuery;
  final List<SermonModel>? allSermons;
  final int? currentIndex;
  final DataService dataService;

  const DetailScreen({
    super.key,
    required this.sermon,
    this.heroTag,
    this.searchQuery,
    this.allSermons,
    this.currentIndex,
    required this.dataService,
  });

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

// Separate widget for scrollable content to avoid controller conflicts
class _SermonContent extends StatefulWidget {
  final SermonModel sermon;
  final String? searchQuery;
  final SettingsProvider settings;
  final bool isDark;
  final ValueChanged<double> onProgressChanged;

  const _SermonContent({
    super.key,
    required this.sermon,
    required this.searchQuery,
    required this.settings,
    required this.isDark,
    required this.onProgressChanged,
  });

  @override
  State<_SermonContent> createState() => _SermonContentState();
}

class _SermonContentState extends State<_SermonContent> {
  final ItemScrollController _itemScrollController = ItemScrollController();
  final ItemPositionsListener _itemPositionsListener =
      ItemPositionsListener.create();
  List<String> _paragraphs = [];
  int? _firstMatchIndex;

  @override
  void initState() {
    super.initState();
    _loadSermonContent();
    _itemPositionsListener.itemPositions.addListener(_onScroll);
  }

  @override
  void dispose() {
    _itemPositionsListener.itemPositions.removeListener(_onScroll);
    super.dispose();
  }

  void _loadSermonContent() {
    _paragraphs = ArabicUtils.splitByPeriods(widget.sermon.text);

    // Find first match if search query exists
    if (widget.searchQuery != null && widget.searchQuery!.isNotEmpty) {
      final query = ArabicUtils.normalize(widget.searchQuery!);
      _firstMatchIndex = null;
      for (int i = 0; i < _paragraphs.length; i++) {
        if (ArabicUtils.normalize(_paragraphs[i]).contains(query)) {
          _firstMatchIndex = i + 2; // +2 for Title and Divider
          break;
        }
      }
    }

    // Reset scroll position
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_itemScrollController.isAttached) {
        if (_firstMatchIndex != null) {
          _itemScrollController.jumpTo(index: _firstMatchIndex!);
        } else {
          _itemScrollController.jumpTo(index: 0);
        }
      }
    });
  }

  void _onScroll() {
    final positions = _itemPositionsListener.itemPositions.value;
    if (positions.isEmpty) return;

    final sorted = positions.toList()
      ..sort((a, b) => a.index.compareTo(b.index));
    final lastRequestIndex = sorted.last.index;
    final maxIndex = _paragraphs.length + 1;

    if (maxIndex <= 0) {
      widget.onProgressChanged(1.0);
      return;
    }

    double progress;
    if (lastRequestIndex >= maxIndex) {
      progress = 1.0;
    } else {
      progress = (lastRequestIndex / maxIndex).clamp(0.0, 1.0);
    }
    widget.onProgressChanged(progress);
  }

  TextSpan _buildHighlightedText(String text, TextStyle style) {
    if (widget.searchQuery == null || widget.searchQuery!.isEmpty) {
      return TextSpan(text: text, style: style);
    }

    final String query = ArabicUtils.normalize(widget.searchQuery!);
    if (query.isEmpty) return TextSpan(text: text, style: style);

    StringBuffer buffer = StringBuffer();
    for (int i = 0; i < query.length; i++) {
      String char = query[i];
      if (RegExp(r'[.\[\]{}()\\*+?|^$]').hasMatch(char)) {
        char = '\\$char';
      }

      if (char == 'ا') {
        buffer.write('[اأإآ]');
      } else if (char == 'ي') {
        buffer.write('[يى]');
      } else if (char == 'ه') {
        buffer.write('[هة]');
      } else {
        buffer.write(char);
      }

      buffer.write(r'[\u064B-\u065F\u06D6-\u06ED]*');
    }

    final RegExp regex = RegExp(buffer.toString());
    final List<TextSpan> spans = [];
    int start = 0;

    for (final Match match in regex.allMatches(text)) {
      if (match.start > start) {
        spans.add(
          TextSpan(text: text.substring(start, match.start), style: style),
        );
      }

      spans.add(
        TextSpan(
          text: text.substring(match.start, match.end),
          style: style.copyWith(
            backgroundColor: Colors.amber.withOpacity(0.5),
            color: Colors.black,
          ),
        ),
      );

      start = match.end;
    }

    if (start < text.length) {
      spans.add(TextSpan(text: text.substring(start), style: style));
    }

    return TextSpan(children: spans);
  }

  @override
  Widget build(BuildContext context) {
    final textColor = widget.isDark ? Colors.white : const Color(0xFF4E342E);
    final titleColor = widget.isDark ? Colors.amber : const Color(0xFF5D4037);

    return ScrollablePositionedList.builder(
      itemScrollController: _itemScrollController,
      itemPositionsListener: _itemPositionsListener,
      padding: const EdgeInsets.all(20.0),
      itemCount: _paragraphs.length + 2,
      itemBuilder: (context, index) {
        if (index == 0) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 20.0),
            child: SelectableText(
              widget.sermon.title,
              textAlign: TextAlign.center,
              style: widget.settings.fonts[widget.settings.fontFamily]!(
                fontSize: widget.settings.fontSize + 2,
                fontWeight: FontWeight.bold,
                color: titleColor,
                height: 1.5,
              ),
            ),
          );
        } else if (index == 1) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 20.0),
            child: Divider(
              thickness: 1,
              color: widget.isDark ? Colors.grey[700] : null,
            ),
          );
        } else {
          return Padding(
            padding: const EdgeInsets.fromLTRB(0, 0, 0, 16),
            child: SelectableText.rich(
              _buildHighlightedText(
                _paragraphs[index - 2],
                widget.settings.fonts[widget.settings.fontFamily]!(
                  fontSize: widget.settings.fontSize,
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
  }
}

class _DetailScreenState extends State<DetailScreen> {
  double _readingProgress = 0.0;
  bool _showControls = false;

  late SermonModel _currentSermon;
  late int? _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentSermon = widget.sermon;
    _currentIndex = widget.currentIndex;
  }

  void _shareContent(BuildContext context) {
    final String content = "${_currentSermon.title}\n\n${_currentSermon.text}";
    Share.share(content);
  }

  void _toggleControls() {
    setState(() {
      _showControls = !_showControls;
    });
  }

  void _navigateToSermon(int newIndex) {
    if (widget.allSermons == null ||
        newIndex < 0 ||
        newIndex >= widget.allSermons!.length) {
      return;
    }

    setState(() {
      _currentSermon = widget.allSermons![newIndex];
      _currentIndex = newIndex;
      _readingProgress = 0.0;
    });
  }

  void _navigateToPrevious() {
    if (_currentIndex != null && _currentIndex! > 0) {
      _navigateToSermon(_currentIndex! - 1);
    }
  }

  void _navigateToNext() {
    if (_currentIndex != null &&
        widget.allSermons != null &&
        _currentIndex! < widget.allSermons!.length - 1) {
      _navigateToSermon(_currentIndex! + 1);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settings, child) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final backgroundColor = isDark
            ? const Color(0xFF1a1a1a)
            : const Color(0xFFF5E6CA); // Parchment Beige
        final textColor = isDark
            ? Colors.white
            : const Color(0xFF4E342E); // Deep brown for text
        final titleColor = isDark
            ? Colors.amber
            : const Color(0xFF5D4037); // Use primary brown for title

        return Scaffold(
          backgroundColor: backgroundColor,
          appBar: AppBar(
            backgroundColor: isDark ? const Color(0xFF2d2d2d) : null,
            leading: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                if (widget.dataService.hasExplanation(_currentSermon.title))
                  IconButton(
                    icon: const Icon(Icons.lightbulb_outline),
                    tooltip: 'التفسير',
                    color: Colors.amber,
                    onPressed: () {
                      final explanation = widget.dataService.getExplanation(
                        _currentSermon.title,
                      );
                      if (explanation != null) {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => ExplanationDetailScreen(
                              sermonTitle: _currentSermon.title,
                              explanationText: explanation,
                            ),
                          ),
                        );
                      }
                    },
                  ),
              ],
            ),
            leadingWidth: widget.dataService.hasExplanation(_currentSermon.title) ? 112 : 56,
            title: const Text(
              "نهج البلاغة",
              style: TextStyle(
                fontFamily: 'Tajawal',
                fontWeight: FontWeight.bold,
              ),
            ),
            centerTitle: true,
            actions: [
              IconButton(
                icon: const Icon(Icons.share),
                tooltip: 'مشاركة الخطبة',
                onPressed: () => _shareContent(context),
              ),
              Consumer<BookmarksProvider>(
                builder: (context, bookmarks, child) {
                  final isBookmarked = bookmarks.isBookmarked(
                    _currentSermon.title,
                  );
                  return IconButton(
                    icon: Icon(
                      isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                      color: isBookmarked ? Colors.amber : null,
                    ),
                    tooltip: isBookmarked ? 'إزالة من المحفوظات' : 'حفظ الخطبة',
                    onPressed: () {
                      bookmarks.toggleBookmark(_currentSermon.title);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            isBookmarked
                                ? 'تم الإزالة من المحفوظات'
                                : 'تم الحفظ في المحفوظات',
                            style: TextStyle(fontFamily: 'Tajawal'),
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
                icon: Icon(_showControls ? Icons.close : Icons.settings),
                tooltip: _showControls ? 'إخفاء الإعدادات' : 'الإعدادات',
                onPressed: _toggleControls,
              ),
            ],
          ),
          body: Stack(
            children: [
              if (settings.useHistoricBackground)
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
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
                    ),
                  ),
                ),
              GestureDetector(
                onHorizontalDragEnd: (details) {
                  final velocity = details.primaryVelocity ?? 0;
                  // Swipe right (to go to previous)
                  if (velocity > 500) {
                    _navigateToPrevious();
                  }
                  // Swipe left (to go to next)
                  else if (velocity < -500) {
                    _navigateToNext();
                  }
                },
                child: SafeArea(
                  child: _SermonContent(
                    key: ValueKey<String>(_currentSermon.title),
                    sermon: _currentSermon,
                    searchQuery: widget.searchQuery,
                    settings: settings,
                    isDark: isDark,
                    onProgressChanged: (progress) {
                      setState(() {
                        _readingProgress = progress;
                      });
                    },
                  ),
                ),
              ),
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
                              style: TextStyle(
                                fontFamily: 'Tajawal',
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
                                      style: TextStyle(
                                        fontFamily: 'Tajawal',
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
                                  style: TextStyle(
                                    fontFamily: 'Tajawal',
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
                        const SizedBox(height: 12),
                        // Background Style Toggle
                        InkWell(
                          onTap: () => settings.setUseHistoricBackground(
                            !settings.useHistoricBackground,
                          ),
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
                                  Icons.article_outlined,
                                  size: 20,
                                  color: titleColor,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'خلفية تاريخية',
                                  style: TextStyle(
                                    fontFamily: 'Tajawal',
                                    fontSize: 14,
                                    color: textColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Switch(
                                  value: settings.useHistoricBackground,
                                  onChanged: (val) =>
                                      settings.setUseHistoricBackground(val),
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
          floatingActionButton:
              widget.allSermons != null &&
                  _currentIndex != null &&
                  _readingProgress >= 0.75
              ? Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Previous Button
                      if (_currentIndex! > 0)
                        Container(
                          decoration: BoxDecoration(
                            color: isDark
                                ? const Color(0xFF2d2d2d)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(
                              color: isDark
                                  ? Colors.amber.withOpacity(0.5)
                                  : const Color(0xFF8D6E63),
                              width: 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.15),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(30),
                              onTap: _navigateToPrevious,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 12,
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.arrow_back_ios_rounded,
                                      color: isDark
                                          ? Colors.amber
                                          : const Color(0xFF5D4037),
                                      size: 18,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'السابق',
                                      style: TextStyle(
                                        fontFamily: 'Tajawal',
                                        color: isDark
                                            ? Colors.amber
                                            : const Color(0xFF5D4037),
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      const SizedBox(width: 16),
                      // Page Indicator
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF2d2d2d)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isDark
                                ? Colors.amber.withOpacity(0.5)
                                : const Color(0xFF8D6E63),
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.15),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Text(
                          '${_currentIndex! + 1} / ${widget.allSermons!.length}',
                          style: TextStyle(
                            fontFamily: 'Tajawal',
                            color: isDark
                                ? Colors.amber
                                : const Color(0xFF5D4037),
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Next Button
                      if (_currentIndex! < widget.allSermons!.length - 1)
                        Container(
                          decoration: BoxDecoration(
                            color: isDark
                                ? const Color(0xFF2d2d2d)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(
                              color: isDark
                                  ? Colors.amber.withOpacity(0.5)
                                  : const Color(0xFF8D6E63),
                              width: 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.15),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(30),
                              onTap: _navigateToNext,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 12,
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      'التالي',
                                      style: TextStyle(
                                        fontFamily: 'Tajawal',
                                        color: isDark
                                            ? Colors.amber
                                            : const Color(0xFF5D4037),
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Icon(
                                      Icons.arrow_forward_ios_rounded,
                                      color: isDark
                                          ? Colors.amber
                                          : const Color(0xFF5D4037),
                                      size: 18,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                )
              : null,
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerFloat,
        );
      },
    );
  }
}
