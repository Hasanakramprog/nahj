import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import '../models/content_model.dart';
import '../utils/arabic_utils.dart';

class DataService {
  List<SermonModel> _allItems = [];
  Map<String, String> _explanations = {};

  Future<List<SermonModel>> loadData({String? jsonPath}) async {
    // If we already have data and no specific path is requested (or same path), we could return cached.
    // However, since we want to support different datasets, we might want to reload if the path changes.
    // For simplicity in this refactor, we will just load what is requested.
    // If we want caching per path, we'd need a Map<String, List<SermonModel>> cache.
    // For now, let's keep it simple and just load.

    final path = jsonPath ?? 'assets/scraped_output_cleaned.json';

    try {
      debugPrint('📖 Loading data from: $path');
      final String response = await rootBundle.loadString(path);
      debugPrint('✅ JSON loaded, parsing...');
      final Map<String, dynamic> data = json.decode(response);
      debugPrint('✅ JSON parsed, creating models...');

      _allItems = data.entries.map((entry) {
        return SermonModel.fromJson(
          entry.key,
          entry.value as Map<String, dynamic>,
        );
      }).toList();

      debugPrint('✅ Loaded ${_allItems.length} items');
      return _allItems;
    } catch (e, stackTrace) {
      debugPrint("❌ Error loading data from $path");
      debugPrint("Error: $e");
      debugPrint("Stack trace: $stackTrace");
      throw Exception("Failed to load data: $e");
    }
  }

  List<SermonModel> search(String query) {
    if (query.isEmpty) return _allItems;

    final normalizedQuery = ArabicUtils.normalize(query).toLowerCase();
    final keywords = normalizedQuery
        .split(' ')
        .where((s) => s.isNotEmpty)
        .toList();

    if (keywords.isEmpty) return _allItems;

    return _allItems.where((item) {
      // Check title
      bool titleMatch = true;
      for (final keyword in keywords) {
        if (!item.normalizedTitle.contains(keyword)) {
          titleMatch = false;
          break;
        }
      }
      if (titleMatch) return true;

      // Check text content
      // The item matches if the consolidated text contains ALL keywords
      bool textMatch = true;
      for (final keyword in keywords) {
        if (!item.normalizedText.contains(keyword)) {
          textMatch = false;
          break;
        }
      }
      if (textMatch) return true;

      return false;
    }).toList();
  }

  Future<void> loadExplanations() async {
    try {
      debugPrint('📖 Loading explanations from: assets/all_explanations.json');
      final String response =
          await rootBundle.loadString('assets/all_explanations.json');
      debugPrint('✅ Explanations JSON loaded, parsing...');
      final Map<String, dynamic> data = json.decode(response);
      
      // Convert to Map<String, String>
      _explanations = data.map((key, value) => MapEntry(key, value.toString()));
      
      debugPrint('✅ Loaded ${_explanations.length} explanations');
    } catch (e, stackTrace) {
      debugPrint("❌ Error loading explanations");
      debugPrint("Error: $e");
      debugPrint("Stack trace: $stackTrace");
      // Don't throw - explanations are optional
      _explanations = {};
    }
  }

  String? getExplanation(String sermonTitle) {
    // Extract sermon number from title like "الخطبة 5: title"
    // and match to key like "الخطبة5" in explanations
    final RegExp numberRegex = RegExp(r'الخطبة\s*(\d+)');
    final match = numberRegex.firstMatch(sermonTitle);
    
    if (match != null) {
      final number = match.group(1);
      final key = 'الخطبة$number';
      return _explanations[key];
    }
    
    return null;
  }

  bool hasExplanation(String sermonTitle) {
    return getExplanation(sermonTitle) != null;
  }
}
