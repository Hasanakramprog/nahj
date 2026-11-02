import 'package:flutter/foundation.dart';
import 'package:home_widget/home_widget.dart';
import '../models/hikam_model.dart';

class WidgetService {
  // App Group ID shared between Flutter and iOS Widget Extension
  static const String appGroupId = 'group.com.hassan.nahjApp';
  static const String iOSWidgetName = 'HikmaWidget';

  /// Initializes the App Group ID for HomeWidget
  static Future<void> init() async {
    try {
      await HomeWidget.setAppGroupId(appGroupId);
    } catch (e) {
      debugPrint('Error setting app group id: $e');
    }
  }

  /// Updates the iOS Home Screen Widget with a Hikma
  static Future<void> updateWidgetWithHikma(HikamModel hikma) async {
    try {
      await HomeWidget.setAppGroupId(appGroupId);

      // Clean text: strip footnote numbers and brackets for display
      final cleanText = (hikma.text.length > 220
              ? "${hikma.text.substring(0, 220)}..."
              : hikma.text)
          .replaceAll(RegExp(r'[0-9\[\]\(\)]+'), '')
          .replaceAll('..', '.')
          .trim();

      await HomeWidget.saveWidgetData<String>('hikma_title', 'حكمة اليوم');
      await HomeWidget.saveWidgetData<String>('hikma_text', cleanText);
      await HomeWidget.saveWidgetData<String>('hikma_id', hikma.id);

      // Request iOS WidgetKit to reload the timeline
      await HomeWidget.updateWidget(
        iOSName: iOSWidgetName,
      );
      debugPrint('✅ Widget updated with Hikma ID: ${hikma.id}');
    } catch (e) {
      debugPrint('❌ Error updating home widget: $e');
    }
  }
}
