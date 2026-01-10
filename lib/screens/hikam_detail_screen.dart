import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../models/hikam_model.dart';
import '../providers/settings_provider.dart';
import 'main_menu_screen.dart';

class HikamDetailScreen extends StatefulWidget {
  final HikamModel hikam;
  final String? searchQuery;
  final List<HikamModel>? allHikam;
  final int? currentIndex;

  const HikamDetailScreen({
    super.key,
    required this.hikam,
    this.searchQuery,
    this.allHikam,
    this.currentIndex,
  });

  @override
  State<HikamDetailScreen> createState() => _HikamDetailScreenState();
}

class _HikamDetailScreenState extends State<HikamDetailScreen> {
  late HikamModel _currentHikam;
  late int _currentIndex;
  final Map<String, bool> _expandedFootnotes = {};
  bool _showSettings = false;

  @override
  void initState() {
    super.initState();
    _currentHikam = widget.hikam;
    _currentIndex = widget.currentIndex ?? 0;
  }

  void _toggleSettings() {
    setState(() {
      _showSettings = !_showSettings;
    });
  }

  void _navigateToPrevious() {
    if (widget.allHikam != null && _currentIndex > 0) {
      setState(() {
        _currentIndex--;
        _currentHikam = widget.allHikam![_currentIndex];
        _expandedFootnotes.clear();
      });
    }
  }

  void _navigateToNext() {
    if (widget.allHikam != null &&
        _currentIndex < widget.allHikam!.length - 1) {
      setState(() {
        _currentIndex++;
        _currentHikam = widget.allHikam![_currentIndex];
        _expandedFootnotes.clear();
      });
    }
  }

  void _shareHikam() {
    // Remove footnote references from text
    String cleanText = _currentHikam.text.replaceAll(
      RegExp(r'\(\[\d+\]\)'),
      '',
    );

    if (_currentHikam.footnotes.isNotEmpty) {
      cleanText += '\n\n';
      cleanText += 'الحواشي:\n';
      _currentHikam.footnotes.forEach((key, value) {
        // Remove numbers from footnote text
        String cleanValue = value.replaceAll(RegExp(r'\[\d+\]ـ\s*'), '');
        cleanText += '$cleanValue\n';
      });
    }

    cleanText += '\n\nمن تطبيق نهج البلاغة';
    Share.share(cleanText);
  }

  // Remove numbers from explanation text
  String _cleanExplanationText(String text) {
    // Remove patterns like [1]ـ or [123]ـ from the beginning
    return text.replaceAll(RegExp(r'^\[\d+\]ـ\s*'), '');
  }

  // Show explanation in a dialog
  void _showExplanationDialog(
    String explanation,
    SettingsProvider settings,
    bool isDark,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF3E3E3E) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(
              Icons.info_outline,
              color: isDark ? Colors.amber : Theme.of(context).primaryColor,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'الشرح',
                style: settings.fonts[settings.fontFamily]!(
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.amber : Theme.of(context).primaryColor,
                ),
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Text(
            _cleanExplanationText(explanation),
            style: settings.fonts[settings.fontFamily]!(
              fontSize: settings.fontSize * 0.95,
              height: 1.8,
              color: isDark ? Colors.white : Colors.black87,
            ),
            textAlign: TextAlign.justify,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'إغلاق',
              style: settings.fonts[settings.fontFamily]!(
                color: isDark ? Colors.amber : Theme.of(context).primaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<InlineSpan> _buildTextWithFootnotes(
    String text,
    SettingsProvider settings,
    bool isDark,
  ) {
    final List<InlineSpan> spans = [];
    final regex = RegExp(r'\(\[(\d+)\]\)');
    int lastIndex = 0;

    // Find all matches
    final matches = regex.allMatches(text).toList();

    for (int i = 0; i < matches.length; i++) {
      final match = matches[i];
      final footnoteNum = match.group(1) ?? '';
      final footnoteText = _currentHikam.footnotes[footnoteNum];

      if (footnoteText == null) continue;

      // Get text before this footnote
      String textBefore = text.substring(lastIndex, match.start);

      // Find the last word in textBefore
      int wordStart = textBefore.lastIndexOf(RegExp(r'\s+'));
      if (wordStart == -1) {
        wordStart = 0;
      } else {
        wordStart++; // Move past the space
      }

      // Add text before the word (if any)
      if (wordStart > 0) {
        spans.add(TextSpan(text: textBefore.substring(0, wordStart)));
      }

      // Add the highlighted word with tap gesture
      final highlightedWord = textBefore.substring(wordStart);
      spans.add(
        WidgetSpan(
          child: GestureDetector(
            onTap: () {
              _showExplanationDialog(footnoteText, settings, isDark);
            },
            child: Container(
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.amber.withOpacity(0.3)
                    : Colors.blue.withOpacity(0.2),
                borderRadius: BorderRadius.circular(4),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
              child: Text(
                highlightedWord,
                style: settings.fonts[settings.fontFamily]!(
                  fontSize: settings.fontSize,
                  height: 2.0,
                  color: isDark ? Colors.amber[200] : Colors.blue[900],
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          alignment: PlaceholderAlignment.baseline,
          baseline: TextBaseline.alphabetic,
        ),
      );

      lastIndex = match.end;
    }

    // Add remaining text
    if (lastIndex < text.length) {
      spans.add(TextSpan(text: text.substring(lastIndex)));
    }

    return spans;
  }

  Widget _buildExpandedFootnote(
    String footnoteNum,
    String footnoteText,
    SettingsProvider settings,
    bool isDark,
  ) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.amber.withOpacity(0.1)
            : Colors.blue.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isDark
              ? Colors.amber.withOpacity(0.3)
              : Colors.blue.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: isDark ? Colors.amber : Colors.blue,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              footnoteNum,
              style: TextStyle(
                fontSize: settings.fontSize * 0.75,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              footnoteText,
              style: settings.fonts[settings.fontFamily]!(
                fontSize: settings.fontSize * 0.9,
                height: 1.8,
                color: isDark ? Colors.amber[100] : Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Extract footnote numbers that appear in the text
    final textFootnotes = <String>[];
    final regex = RegExp(r'\[\[(\d+)\]\]|\[(\d+)\]');
    for (final match in regex.allMatches(_currentHikam.text)) {
      final num = match.group(1) ?? match.group(2);
      if (num != null && !textFootnotes.contains(num)) {
        textFootnotes.add(num);
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'حكمة ${_currentHikam.id}',
          style: settings.fonts[settings.fontFamily]!(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: _shareHikam,
            tooltip: 'مشاركة',
          ),
          IconButton(
            icon: Icon(_showSettings ? Icons.close : Icons.settings),
            tooltip: _showSettings ? 'إخفاء الإعدادات' : 'الإعدادات',
            onPressed: _toggleSettings,
          ),
        ],
      ),
      body: Stack(
        children: [
          Container(
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
            child: Column(
              children: [
                // Navigation buttons
                if (widget.allHikam != null && widget.allHikam!.length > 1)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    color: isDark
                        ? Colors.black.withOpacity(0.2)
                        : Colors.white.withOpacity(0.5),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ElevatedButton.icon(
                          onPressed: _currentIndex < widget.allHikam!.length - 1
                              ? _navigateToNext
                              : null,
                          icon: const Icon(Icons.arrow_back),
                          label: const Text(
                            'التالي',
                            style: TextStyle(fontFamily: 'Tajawal'),
                          ),
                        ),
                        Text(
                          '${_currentIndex + 1} من ${widget.allHikam!.length}',
                          style: settings.fonts[settings.fontFamily]!(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: _currentIndex > 0
                              ? _navigateToPrevious
                              : null,
                          icon: const Icon(Icons.arrow_forward),
                          label: const Text(
                            'السابق',
                            style: TextStyle(fontFamily: 'Tajawal'),
                          ),
                        ),
                      ],
                    ),
                  ),
                // Content
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Card(
                      elevation: 4,
                      color: isDark
                          ? const Color(0xFF3E3E3E).withOpacity(0.95)
                          : Colors.white, // Pure white for card in light mode
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Hikam text with inline footnote references
                            RichText(
                              textAlign: TextAlign.justify,
                              text: TextSpan(
                                style: settings.fonts[settings.fontFamily]!(
                                  fontSize: settings.fontSize,
                                  height: 2.0,
                                  color: isDark ? Colors.white : Colors.black87,
                                ),
                                children: _buildTextWithFootnotes(
                                  _currentHikam.text,
                                  settings,
                                  isDark,
                                ),
                              ),
                            ),

                            // Expanded footnotes (shown when tapped)
                            ...textFootnotes
                                .where((num) => _expandedFootnotes[num] == true)
                                .map((num) {
                                  final footnoteText =
                                      _currentHikam.footnotes[num];
                                  if (footnoteText == null)
                                    return const SizedBox.shrink();
                                  return _buildExpandedFootnote(
                                    num,
                                    footnoteText,
                                    settings,
                                    isDark,
                                  );
                                })
                                .toList(),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Settings panel overlay
          if (_showSettings) ...[
            Positioned.fill(
              child: GestureDetector(
                onTap: () => setState(() => _showSettings = false),
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
                            color: isDark
                                ? Colors.white
                                : const Color(
                                    0xFF00695C,
                                  ), // Green for light mode
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
                                    : isDark
                                    ? Colors.white
                                    : const Color(
                                        0xFF00695C,
                                      ), // Green for light mode
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
                                    color: isDark
                                        ? Colors.amber
                                        : const Color(
                                            0xFF00695C,
                                          ), // Green for light mode
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.add),
                                iconSize: 20,
                                color: settings.fontSize >= 32
                                    ? Colors.grey
                                    : isDark
                                    ? Colors.white
                                    : const Color(
                                        0xFF00695C,
                                      ), // Green for light mode
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
                          final isSelected = settings.fontFamily == fontFamily;
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: ChoiceChip(
                              label: Text(
                                fontFamily,
                                style: settings.fonts[fontFamily]!(
                                  color: isSelected
                                      ? Colors.white
                                      : isDark
                                      ? Colors.white
                                      : const Color(
                                          0xFF00695C,
                                        ), // Green for light mode
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
                              color: isDark
                                  ? Colors.amber
                                  : const Color(
                                      0xFF00695C,
                                    ), // Green for light mode
                            ),
                            const SizedBox(width: 8),
                            Text(
                              isDark ? 'الوضع الداكن' : 'الوضع الفاتح',
                              style: TextStyle(
                                fontFamily: 'Tajawal',
                                fontSize: 14,
                                color: isDark
                                    ? Colors.white
                                    : const Color(
                                        0xFF00695C,
                                      ), // Green for light mode
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
}
