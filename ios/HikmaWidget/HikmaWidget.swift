import WidgetKit
import SwiftUI

let appGroupId = "group.com.hassan.nahjApp"

struct HikmaEntry: TimelineEntry {
    let date: Date
    let title: String
    let text: String
}

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> HikmaEntry {
        HikmaEntry(
            date: Date(),
            title: "حكمة اليوم",
            text: "وقال عليه السلام: لو كان جبلاً لكان فنداً، ولو كان حجراً لكان صلداً..."
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (HikmaEntry) -> ()) {
        let entry = loadEntry()
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<HikmaEntry>) -> ()) {
        let entry = loadEntry()
        // Refresh every 4 hours or when app updates
        let nextUpdate = Calendar.current.date(byAdding: .hour, value: 4, to: Date()) ?? Date().addingTimeInterval(14400)
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        completion(timeline)
    }

    private func loadEntry() -> HikmaEntry {
        let defaults = UserDefaults(suiteName: appGroupId)
        let title = defaults?.string(forKey: "hikma_title") ?? "حكمة اليوم"
        let text = defaults?.string(forKey: "hikma_text") ?? "وقال عليه السلام: مَنْ قَصَّرَ فِي الْعَمَلِ ابْتُلِيَ بِالْهَمِّ"
        return HikmaEntry(date: Date(), title: title, text: text)
    }
}

struct HikmaWidgetEntryView : View {
    var entry: Provider.Entry
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        VStack(spacing: 8) {
            // Header: Star icon + "حكمة اليوم"
            HStack {
                Image(systemName: "sparkles")
                    .foregroundColor(colorScheme == .dark ? Color.yellow : Color.orange)
                    .font(.system(size: 14, weight: .bold))

                Text(entry.title)
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(colorScheme == .dark ? Color.yellow : Color(red: 0.85, green: 0.45, blue: 0.1))

                Spacer()
            }
            .environment(\.layoutDirection, .rightToLeft)

            Spacer(minLength: 2)

            // Arabic text
            Text(entry.text)
                .font(.system(size: 14, weight: .medium, design: .serif))
                .multilineTextAlignment(.center)
                .lineSpacing(4)
                .foregroundColor(colorScheme == .dark ? Color.white : Color(red: 0.24, green: 0.15, blue: 0.14))
                .minimumScaleFactor(0.75)
                .environment(\.layoutDirection, .rightToLeft)

            Spacer(minLength: 2)

            // Footer
            Text("اضغط للقراءة الكاملة")
                .font(.system(size: 10))
                .foregroundColor(colorScheme == .dark ? Color.gray : Color.black.opacity(0.45))
        }
        .padding(12)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(backgroundGradient)
    }

    var backgroundGradient: some View {
        LinearGradient(
            gradient: Gradient(colors: colorScheme == .dark
                ? [Color(hex: "424242"), Color(hex: "212121")]
                : [Color(hex: "FFFBF0"), Color(hex: "FFF3E0")]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}

extension Color {
    init(hex: String) {
        let scanner = Scanner(string: hex)
        var rgbValue: UInt64 = 0
        scanner.scanHexInt64(&rgbValue)
        let r = Double((rgbValue & 0xFF0000) >> 16) / 255.0
        let g = Double((rgbValue & 0x00FF00) >> 8) / 255.0
        let b = Double(rgbValue & 0x0000FF) / 255.0
        self.init(red: r, green: g, blue: b)
    }
}

struct HikmaWidget: Widget {
    let kind: String = "HikmaWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            if #available(iOS 17.0, *) {
                HikmaWidgetEntryView(entry: entry)
                    .containerBackground(for: .widget) {
                        HikmaWidgetEntryView(entry: entry).backgroundGradient
                    }
            } else {
                HikmaWidgetEntryView(entry: entry)
            }
        }
        .configurationDisplayName("حكمة اليوم")
        .description("يعرض حكمة متجددة من نهج البلاغة على الشاشة الرئيسية.")
        .supportedFamilies([.systemMedium, .systemLarge])
    }
}
