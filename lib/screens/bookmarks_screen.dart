import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import '../models/content_model.dart';
import '../providers/bookmarks_provider.dart';

import '../services/data_service.dart';
import 'detail_screen.dart';

class BookmarksScreen extends StatefulWidget {
  const BookmarksScreen({super.key});

  @override
  State<BookmarksScreen> createState() => _BookmarksScreenState();
}

class _BookmarksScreenState extends State<BookmarksScreen> {
  final DataService _dataService = DataService();
  List<SermonModel> _allSermons = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final sermons = await _dataService.loadData();
    // Load explanations in the background
    _dataService.loadExplanations();
    if (mounted) {
      setState(() {
        _allSermons = sermons;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'المحفوظات',
          style: TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Consumer<BookmarksProvider>(
              builder: (context, bookmarks, child) {
                final bookmarkedTitles = bookmarks.bookmarkedTitles;
                final savedSermons = _allSermons
                    .where((s) => bookmarkedTitles.contains(s.title))
                    .toList();

                if (savedSermons.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.bookmark_border,
                          size: 64,
                          color: Colors.grey,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'لا توجد خطب محفوظة',
                          style: TextStyle(
                            fontFamily: 'Tajawal',
                            fontSize: 18,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: savedSermons.length,
                  itemBuilder: (context, index) {
                    final sermon = savedSermons[index];
                    final originalIndex = _allSermons.indexOf(sermon) + 1;
                    final heroTag = 'bookmark_sermon_${sermon.title.hashCode}';

                    // Get dark mode status
                    final isDark =
                        Theme.of(context).brightness == Brightness.dark;
                    final titleColor = isDark ? Colors.amber : Colors.black;
                    final numberColor = isDark
                        ? Colors.amber
                        : Theme.of(context).primaryColor;
                    final textColor = isDark ? Colors.white : Colors.grey[700];

                    return Hero(
                      tag: heroTag,
                      child: Card(
                        margin: const EdgeInsets.only(bottom: 16),
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: BorderSide(
                            color: Theme.of(
                              context,
                            ).primaryColor.withOpacity(0.1),
                            width: 1,
                          ),
                        ),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: () {
                            Navigator.push(
                              context,
                              PageRouteBuilder(
                                transitionDuration: const Duration(
                                  milliseconds: 600,
                                ),
                                pageBuilder: (_, __, ___) => DetailScreen(
                                  sermon: sermon,
                                  heroTag: heroTag,
                                  allSermons: savedSermons,
                                  currentIndex: index,
                                  dataService: _dataService,
                                ),
                                transitionsBuilder: (_, animation, __, child) {
                                  return FadeTransition(
                                    opacity: animation,
                                    child: child,
                                  );
                                },
                              ),
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      width: 40,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        color: isDark
                                            ? Colors.amber.withOpacity(0.2)
                                            : Theme.of(
                                                context,
                                              ).primaryColor.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      alignment: Alignment.center,
                                      child: Text(
                                        "$originalIndex",
                                        style: TextStyle(
                                          fontFamily: 'Tajawal',
                                          color: numberColor,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        sermon.title,
                                        style: TextStyle(
                                          fontFamily: 'Tajawal',
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          height: 1.3,
                                          color: titleColor,
                                        ),
                                      ),
                                    ),
                                    const Icon(
                                      Icons.bookmark,
                                      color: Colors.amber,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                if (sermon.text.isNotEmpty)
                                  Text(
                                    sermon.text.contains('\n\n')
                                        ? sermon.text.substring(
                                            0,
                                            sermon.text.indexOf('\n\n'),
                                          )
                                        : sermon.text,
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontFamily: 'Amiri',
                                      fontSize: 16,
                                      color: textColor,
                                      height: 1.8,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
