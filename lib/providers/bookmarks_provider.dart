import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BookmarksProvider with ChangeNotifier {
  static const String _storageKey = 'bookmarked_sermons';
  Set<String> _bookmarkedTitles = {};

  Set<String> get bookmarkedTitles => _bookmarkedTitles;

  BookmarksProvider() {
    _loadBookmarks().catchError((error) {
      debugPrint('Error loading bookmarks: $error');
      // Continue with empty bookmarks if loading fails
    });
  }

  Future<void> _loadBookmarks() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<String>? stored = prefs.getStringList(_storageKey);
      if (stored != null) {
        _bookmarkedTitles = stored.toSet();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading bookmarks: $e');
      // Continue with empty set
    }
  }

  Future<void> toggleBookmark(String title) async {
    if (_bookmarkedTitles.contains(title)) {
      _bookmarkedTitles.remove(title);
    } else {
      _bookmarkedTitles.add(title);
    }
    notifyListeners();
    _saveBookmarks().catchError((error) {
      debugPrint('Error saving bookmarks: $error');
    });
  }

  bool isBookmarked(String title) {
    return _bookmarkedTitles.contains(title);
  }

  Future<void> _saveBookmarks() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_storageKey, _bookmarkedTitles.toList());
    } catch (e) {
      debugPrint('Error saving bookmarks: $e');
      rethrow;
    }
  }
}
