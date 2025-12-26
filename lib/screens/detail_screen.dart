import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../models/content_model.dart';
import '../providers/bookmarks_provider.dart';

class DetailScreen extends StatelessWidget {
  final SermonModel sermon;
  final String? heroTag;

  const DetailScreen({super.key, required this.sermon, this.heroTag});

  void _shareContent(BuildContext context) {
    final String content = "${sermon.title}\n\n${sermon.text}";
    Share.share(content);
  }

  @override
  Widget build(BuildContext context) {
    Widget content = SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SelectableText(
            sermon.title,
            textAlign: TextAlign.center,
            style: GoogleFonts.tajawal(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 20),
          const Divider(thickness: 1),
          const SizedBox(height: 20),
          ...sermon.text.split('\n\n').map((paragraph) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: SelectableText(
                paragraph,
                textAlign: TextAlign.justify,
                style: GoogleFonts.amiri(
                  fontSize: 20,
                  height: 1.8,
                  color: Colors.black87,
                ),
              ),
            );
          }),
          const SizedBox(height: 40),
        ],
      ),
    );

    if (heroTag != null) {
      content = Hero(
        tag: heroTag!,
        child: Material(type: MaterialType.transparency, child: content),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "نهج البلاغة",
          style: GoogleFonts.tajawal(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          Consumer<BookmarksProvider>(
            builder: (context, bookmarks, child) {
              final isBookmarked = bookmarks.isBookmarked(sermon.title);
              return IconButton(
                icon: Icon(
                  isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                  color: isBookmarked ? Colors.amber : Colors.white,
                ),
                tooltip: isBookmarked ? 'إزالة من المحفوظات' : 'حفظ الخطبة',
                onPressed: () {
                  bookmarks.toggleBookmark(sermon.title);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        isBookmarked
                            ? 'تم الإزالة من المحفوظات'
                            : 'تم الحفظ في المحفوظات',
                        style: GoogleFonts.tajawal(),
                      ),
                      duration: const Duration(seconds: 1),
                    ),
                  );
                },
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.share),
            tooltip: 'مشاركة الخطبة',
            onPressed: () => _shareContent(context),
          ),
        ],
      ),
      body: SafeArea(child: content),
    );
  }
}
