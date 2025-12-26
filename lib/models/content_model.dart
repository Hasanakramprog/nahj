import '../utils/arabic_utils.dart';

class SermonModel {
  final String title;
  final String text;
  final List<String> notes;

  // Normalized fields for search
  final String normalizedTitle;
  final String normalizedText;

  SermonModel({
    required this.title,
    required this.text,
    required this.notes,
    required this.normalizedTitle,
    required this.normalizedText,
  });

  factory SermonModel.fromJson(String title, Map<String, dynamic> json) {
    // Handle both String and List<String> formats for backward compatibility
    final textData = json['text'];
    final String textStr;

    if (textData is String) {
      // New format: already a string
      textStr = textData;
    } else if (textData is List) {
      // Old format: list of strings - join them
      textStr = textData
          .map((e) => e.toString().trim())
          .where((p) => p.isNotEmpty)
          .join('\n\n');
    } else {
      textStr = "";
    }

    return SermonModel(
      title: title,
      text: textStr,
      notes: List<String>.from(json['notes'] ?? []),
      normalizedTitle: ArabicUtils.normalize(title).toLowerCase(),
      normalizedText: ArabicUtils.normalize(textStr).toLowerCase(),
    );
  }
}
