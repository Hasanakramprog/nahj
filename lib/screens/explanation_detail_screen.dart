import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import '../providers/settings_provider.dart';
import '../utils/arabic_utils.dart';

class ExplanationDetailScreen extends StatefulWidget {
  final String sermonTitle; // e.g., "الخطبة 5: title"
  final String explanationText;

  const ExplanationDetailScreen({
    super.key,
    required this.sermonTitle,
    required this.explanationText,
  });

  @override
  State<ExplanationDetailScreen> createState() =>
      _ExplanationDetailScreenState();
}

class _ExplanationContent extends StatefulWidget {
  final String sermonTitle;
  final String explanationText;
  final SettingsProvider settings;
  final bool isDark;
  final ValueChanged<double> onProgressChanged;

  const _ExplanationContent({
    super.key,
    required this.sermonTitle,
    required this.explanationText,
    required this.settings,
    required this.isDark,
    required this.onProgressChanged,
  });

  @override
  State<_ExplanationContent> createState() => _ExplanationContentState();
}

class _ExplanationContentState extends State<_ExplanationContent> {
  final ItemScrollController _itemScrollController = ItemScrollController();
  final ItemPositionsListener _itemPositionsListener =
      ItemPositionsListener.create();
  List<String> _paragraphs = [];

  @override
  void initState() {
    super.initState();
    _loadExplanationContent();
    _itemPositionsListener.itemPositions.addListener(_onScroll);
  }

  @override
  void dispose() {
    _itemPositionsListener.itemPositions.removeListener(_onScroll);
    super.dispose();
  }

  void _loadExplanationContent() {
    _paragraphs = ArabicUtils.splitByPeriods(widget.explanationText);

    // Reset scroll position
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_itemScrollController.isAttached) {
        _itemScrollController.jumpTo(index: 0);
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

  @override
  Widget build(BuildContext context) {
    final textColor = widget.isDark
        ? Colors.white
        : const Color(0xFF00695C); // Green for light mode
    final titleColor = widget.isDark
        ? Colors.amber
        : const Color(0xFF00695C); // Green for light mode

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
              'تفسير ${widget.sermonTitle}',
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
            child: SelectableText(
              _paragraphs[index - 2],
              textAlign: TextAlign.justify,
              style: widget.settings.fonts[widget.settings.fontFamily]!(
                fontSize: widget.settings.fontSize,
                height: 1.8,
                color: textColor,
              ),
            ),
          );
        }
      },
    );
  }
}

class _ExplanationDetailScreenState extends State<ExplanationDetailScreen> {
  double _readingProgress = 0.0;
  bool _showControls = false;

  void _shareContent(BuildContext context) {
    final String content =
        "تفسير ${widget.sermonTitle}\n\n${widget.explanationText}";
    Share.share(content);
  }

  void _toggleControls() {
    setState(() {
      _showControls = !_showControls;
    });
  }

  void _showAboutDialog(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: isDark ? const Color(0xFF2d2d2d) : Colors.white,
          title: Text(
            'عن التفسير',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Tajawal',
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.amber : const Color(0xFF5D4037),
            ),
          ),
          content: SingleChildScrollView(
            child: Text(
              '"نفحات الولاية في شرح نهج البلاغة" هو شرح معاصر وشامل لنهج البلاغة للشيخ ناصر مكارم الشيرازي، يتسم بأسلوب عصري عميق يغوص في معاني كلام أمير المؤمنين (ع)، ويقدم تفسيرات فقهية وعقائدية وروحية لتراث النهج، مع التركيز على الإعجاز البياني للخطب وفهم أبعادها الإيمانية العميقة، متوفراً في مجلدات متعددة عبر مواقع إلكترونية متخصصة.',
              textAlign: TextAlign.justify,
              style: TextStyle(
                fontFamily: 'Amiri',
                fontSize: 16,
                height: 1.8,
                color: isDark ? Colors.white : const Color(0xFF4E342E),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'حسناً',
                style: TextStyle(
                  fontFamily: 'Tajawal',
                  color: isDark ? Colors.amber : const Color(0xFF5D4037),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settings, child) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final backgroundColor = isDark
            ? const Color(0xFF1a1a1a)
            : const Color(0xFFF5E6CA); // Parchment Beige

        return Scaffold(
          backgroundColor: backgroundColor,
          appBar: AppBar(
            backgroundColor: isDark ? const Color(0xFF2d2d2d) : null,
            title: const Text(
              "التفسير",
              style: TextStyle(
                fontFamily: 'Tajawal',
                fontWeight: FontWeight.bold,
              ),
            ),
            centerTitle: true,
            actions: [
              IconButton(
                icon: const Icon(Icons.info_outline),
                tooltip: 'عن التفسير',
                onPressed: () => _showAboutDialog(context),
              ),
              IconButton(
                icon: Icon(_showControls ? Icons.close : Icons.settings),
                tooltip: _showControls ? 'إخفاء الإعدادات' : 'الإعدادات',
                onPressed: _toggleControls,
              ),
              IconButton(
                icon: const Icon(Icons.share),
                tooltip: 'مشاركة التفسير',
                onPressed: () => _shareContent(context),
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
              SafeArea(
                child: _ExplanationContent(
                  key: ValueKey<String>(widget.sermonTitle),
                  sermonTitle: widget.sermonTitle,
                  explanationText: widget.explanationText,
                  settings: settings,
                  isDark: isDark,
                  onProgressChanged: (progress) {
                    setState(() {
                      _readingProgress = progress;
                    });
                  },
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
                                color: isDark
                                    ? Colors.white
                                    : const Color(0xFF4E342E),
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
                                        : (isDark
                                              ? Colors.white
                                              : const Color(0xFF4E342E)),
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
                                            : const Color(0xFF5D4037),
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.add),
                                    iconSize: 20,
                                    color: settings.fontSize >= 32
                                        ? Colors.grey
                                        : (isDark
                                              ? Colors.white
                                              : const Color(0xFF4E342E)),
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
                                          : (isDark
                                                ? Colors.white
                                                : const Color(0xFF4E342E)),
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
                                      : const Color(0xFF5D4037),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  isDark ? 'الوضع الداكن' : 'الوضع الفاتح',
                                  style: TextStyle(
                                    fontFamily: 'Tajawal',
                                    fontSize: 14,
                                    color: isDark
                                        ? Colors.white
                                        : const Color(0xFF4E342E),
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
                                  color: isDark
                                      ? Colors.amber
                                      : const Color(0xFF5D4037),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'خلفية تاريخية',
                                  style: TextStyle(
                                    fontFamily: 'Tajawal',
                                    fontSize: 14,
                                    color: isDark
                                        ? Colors.white
                                        : const Color(0xFF4E342E),
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
        );
      },
    );
  }
}
