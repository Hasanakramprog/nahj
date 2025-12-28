class ArabicUtils {
  static String normalize(String text) {
    if (text.isEmpty) return text;

    String normalized = text;

    // Remove Tashkeel (Diacritics)
    normalized = normalized.replaceAll(
      RegExp(r'[\u064B-\u065F]'),
      '',
    ); // Tashkeel
    normalized = normalized.replaceAll(
      RegExp(r'[\u06D6-\u06ED]'),
      '',
    ); // Quranic marks

    // Unify Alef forms
    normalized = normalized.replaceAll(RegExp(r'[أإآ]'), 'ا');

    // Unify Yeh forms
    normalized = normalized.replaceAll(RegExp(r'[ى]'), 'ي');

    // Unify Teh Marbuta
    normalized = normalized.replaceAll(RegExp(r'ة'), 'ه');

    return normalized;
  }

  /// Formats text to create new lines only at sentence endings (periods)
  /// Removes \n\n separators and replaces them with spaces
  static String formatTextByPeriods(String text) {
    if (text.isEmpty) return text;

    // First, replace all \n\n with a space to join paragraphs
    String formatted = text.replaceAll('\n\n', ' ');

    // Also replace single \n with space
    formatted = formatted.replaceAll('\n', ' ');

    // Split by periods followed by space or end of string
    // This regex matches: period + optional spaces + (space or end of string)
    List<String> sentences = formatted.split(RegExp(r'\.\s*(?=\s|$)'));

    // Filter out empty sentences and trim whitespace
    sentences = sentences
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();

    // Join sentences with period and newline
    // Add period back to each sentence (except the last one if it doesn't need it)
    return sentences
        .map((sentence) {
          // Add period if it doesn't end with one
          if (!sentence.endsWith('.')) {
            sentence = sentence + '.';
          }

          return sentence;
        })
        .join('\n');
  }

  /// Splits text into paragraphs based on periods
  /// Returns a list of sentences for display
  static List<String> splitByPeriods(String text) {
    if (text.isEmpty) return [];

    // First, replace all \n\n with a space to join paragraphs
    String formatted = text.replaceAll('\n\n', ' ');

    // Also replace single \n with space
    formatted = formatted.replaceAll('\n', ' ');

    // Split by periods followed by space or end of string
    List<String> sentences = formatted.split(RegExp(r'\.\s*(?=\s|$)'));

    // Filter out empty sentences and trim whitespace
    sentences = sentences
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();

    // Add period back to each sentence if it doesn't have one
    return sentences.map((sentence) {
      if (!sentence.endsWith('.')) {
        return sentence + '.';
      }
      return sentence;
    }).toList();
  }
}
