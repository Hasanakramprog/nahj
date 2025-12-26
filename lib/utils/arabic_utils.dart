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
}
