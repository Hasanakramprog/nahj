import '../utils/arabic_utils.dart';

class HikamModel {
  final String id;
  final String text;
  final Map<String, String> footnotes;

  // Normalized fields for search
  final String normalizedText;

  HikamModel({
    required this.id,
    required this.text,
    required this.footnotes,
    required this.normalizedText,
  });

  factory HikamModel.fromJson(String id, Map<String, dynamic> json) {
    final String textStr = json['text']?.toString() ?? "";

    // Parse footnotes from the JSON
    final footnotesData = json['footnotes'];
    Map<String, String> footnotesMap = {};

    if (footnotesData != null && footnotesData is Map) {
      footnotesMap = footnotesData.map(
        (key, value) => MapEntry(key.toString(), value.toString()),
      );
    }

    return HikamModel(
      id: id,
      text: textStr,
      footnotes: footnotesMap,
      normalizedText: ArabicUtils.normalize(textStr).toLowerCase(),
    );
  }

  // Get the display title (text after (عليه السلام): without numbers or symbols)
  String get displayTitle {
    // Remove footnote references like ([1])
    String cleanText = text.replaceAll(RegExp(r'\(\[\d+\]\)'), '');

    // Try to find text after (عليه السلام): or (عليه السلام)
    final patterns = [
      RegExp(r'\(عليه السلام\):(.+)'),
      RegExp(r'\(عليه السلام\)(.+)'),
    ];

    for (var pattern in patterns) {
      final match = pattern.firstMatch(cleanText);
      if (match != null && match.group(1) != null) {
        String title = match.group(1)!.trim();
        // Remove leading numbers and symbols like "1 ـ قَال"
        title = title.replaceAll(RegExp(r'^\d+\s*ـ\s*'), '');
        // Remove leading "قَال" or "وقَالَ" or similar
        title = title.replaceAll(RegExp(r'^و?قَال\s*'), '');
        return title.trim();
      }
    }

    // Fallback: return cleaned text up to first 100 characters
    return cleanText.length > 100
        ? cleanText.substring(0, 100) + '...'
        : cleanText;
  }
}
