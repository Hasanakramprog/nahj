import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BookmarksProvider with ChangeNotifier {
  static const String _storageKey = 'bookmarked_sermons';
  Set<String> _bookmarkedTitles = {};

  Set<String> get bookmarkedTitles => _bookmarkedTitles;

  BookmarksProvider() {
    _loadBookmarks();
  }

  Future<void> _loadBookmarks() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? stored = prefs.getStringList(_storageKey);
    if (stored != null) {
      _bookmarkedTitles = stored.toSet();
      notifyListeners();
    }
  }

  Future<void> toggleBookmark(String title) async {
    if (_bookmarkedTitles.contains(title)) {
      _bookmarkedTitles.remove(title);
    } else {
      _bookmarkedTitles.add(title);
    }
    notifyListeners();
    await _saveBookmarks();
  }

  bool isBookmarked(String title) {
    return _bookmarkedTitles.contains(title);
  }

  Future<void> _saveBookmarks() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_storageKey, _bookmarkedTitles.toList());
  }
}
