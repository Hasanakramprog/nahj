import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/content_model.dart';
import '../utils/arabic_utils.dart';

class DataService {
  List<SermonModel> _allItems = [];

  Future<List<SermonModel>> loadData({String? jsonPath}) async {
    // If we already have data and no specific path is requested (or same path), we could return cached.
    // However, since we want to support different datasets, we might want to reload if the path changes.
    // For simplicity in this refactor, we will just load what is requested.
    // If we want caching per path, we'd need a Map<String, List<SermonModel>> cache.
    // For now, let's keep it simple and just load.

    final path = jsonPath ?? 'assets/scraped_output_cleaned.json';

    try {
      final String response = await rootBundle.loadString(path);
      final Map<String, dynamic> data = json.decode(response);

      _allItems = data.entries.map((entry) {
        return SermonModel.fromJson(
          entry.key,
          entry.value as Map<String, dynamic>,
        );
      }).toList();

      return _allItems;
    } catch (e, stackTrace) {
      print("❌ Error loading data from $path");
      print("Error: $e");
      print("Stack trace: $stackTrace");
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
}
