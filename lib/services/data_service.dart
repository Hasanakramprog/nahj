import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/content_model.dart';
import '../utils/arabic_utils.dart';

class DataService {
  List<SermonModel> _allItems = [];

  Future<List<SermonModel>> loadData() async {
    if (_allItems.isNotEmpty) return _allItems;

    try {
      final String response = await rootBundle.loadString('assets/output.json');
      final Map<String, dynamic> data = json.decode(response);

      _allItems = data.entries.map((entry) {
        return SermonModel.fromJson(
          entry.key,
          entry.value as Map<String, dynamic>,
        );
      }).toList();

      return _allItems;
    } catch (e) {
      print("Error loading data: $e");
      return [];
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
