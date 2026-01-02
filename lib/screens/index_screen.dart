import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import '../models/content_model.dart';
import '../services/data_service.dart';
import '../providers/settings_provider.dart';
import 'detail_screen.dart';

class IndexScreen extends StatefulWidget {
  final String jsonPath;
  final String title;

  const IndexScreen({super.key, required this.jsonPath, required this.title});

  @override
  State<IndexScreen> createState() => _IndexScreenState();
}

class _IndexScreenState extends State<IndexScreen> {
  final DataService _dataService = DataService();
  List<SermonModel> _allSermons = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final sermons = await _dataService.loadData(jsonPath: widget.jsonPath);
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
          widget.title,
          style: TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3, // 3 columns for small boxes
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 1.0, // Square boxes
              ),
              itemCount: _allSermons.length,
              itemBuilder: (context, index) {
                final sermon = _allSermons[index];
                // Unique hero tag for grid transition
                final heroTag = 'index_grid_${sermon.title.hashCode}';

                // Get dark mode status
                final isDark = context.watch<SettingsProvider>().isDarkMode;
                final cardColor = isDark
                    ? const Color(0xFF2d2d2d)
                    : Colors.white;
                final numberBoxColor = isDark
                    ? Colors.amber.withOpacity(0.2)
                    : Theme.of(context).primaryColor.withOpacity(0.1);
                final numberColor = isDark
                    ? Colors.amber
                    : Theme.of(context).primaryColor;
                final titleColor = isDark ? Colors.white : Colors.black87;

                return Hero(
                  tag: heroTag,
                  child: Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    color: cardColor,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () {
                        Navigator.push(
                          context,
                          PageRouteBuilder(
                            transitionDuration: const Duration(
                              milliseconds: 600,
                            ),
                            pageBuilder: (_, __, ___) =>
                                DetailScreen(sermon: sermon, heroTag: heroTag),
                            transitionsBuilder: (_, animation, __, child) {
                              return FadeTransition(
                                opacity: animation,
                                child: child,
                              );
                            },
                          ),
                        );
                      },
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: numberBoxColor,
                            ),
                            child: Text(
                              "${index + 1}",
                              style: TextStyle(
                                fontFamily: 'Tajawal',
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: numberColor,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 4.0,
                            ),
                            child: Text(
                              sermon.title,
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontFamily: 'Tajawal',
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                height: 1.2,
                                color: titleColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
