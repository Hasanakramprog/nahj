import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import '../models/hikam_model.dart';
import '../utils/arabic_utils.dart';

class HikamService {
  List<HikamModel> _allHikam = [];

  Future<List<HikamModel>> loadHikam({String? jsonPath}) async {
    final path = jsonPath ?? 'assets/imamali_with_notes.json';

    try {
      debugPrint('📖 Loading hikam from: $path');
      final String response = await rootBundle.loadString(path);
      debugPrint('✅ JSON loaded, parsing...');
      final Map<String, dynamic> data = json.decode(response);
      debugPrint('✅ JSON parsed, creating models...');

      _allHikam = data.entries.map((entry) {
        return HikamModel.fromJson(
          entry.key,
          entry.value as Map<String, dynamic>,
        );
      }).toList();

      debugPrint('✅ Loaded ${_allHikam.length} hikam');
      return _allHikam;
    } catch (e, stackTrace) {
      debugPrint("❌ Error loading hikam from $path");
      debugPrint("Error: $e");
      debugPrint("Stack trace: $stackTrace");
      throw Exception("Failed to load hikam: $e");
    }
  }

  List<HikamModel> search(String query) {
    if (query.isEmpty) return _allHikam;

    final normalizedQuery = ArabicUtils.normalize(query).toLowerCase();
    final keywords = normalizedQuery
        .split(' ')
        .where((s) => s.isNotEmpty)
        .toList();

    if (keywords.isEmpty) return _allHikam;

    return _allHikam.where((item) {
      // Check if text content contains ALL keywords
      bool textMatch = true;
      for (final keyword in keywords) {
        if (!item.normalizedText.contains(keyword)) {
          textMatch = false;
          break;
        }
      }
      if (textMatch) return true;

      // Also check footnotes
      for (final footnote in item.footnotes.values) {
        final normalizedFootnote = ArabicUtils.normalize(
          footnote,
        ).toLowerCase();
        bool footnoteMatch = true;
        for (final keyword in keywords) {
          if (!normalizedFootnote.contains(keyword)) {
            footnoteMatch = false;
            break;
          }
        }
        if (footnoteMatch) return true;
      }

      return false;
    }).toList();
  }

  List<HikamModel> get allHikam => _allHikam;
}
