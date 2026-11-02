//
//  HikmaWidgetLiveActivity.swift
//  HikmaWidget
//
//  Created by Macbook on 03/11/2026.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct HikmaWidgetAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var emoji: String
    }

    // Fixed non-changing properties about your activity go here!
    var name: String
}

struct HikmaWidgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: HikmaWidgetAttributes.self) { context in
            // Lock screen/banner UI goes here
            VStack {
                Text("Hello \(context.state.emoji)")
            }
            .activityBackgroundTint(Color.cyan)
            .activitySystemActionForegroundColor(Color.black)

        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI goes here.  Compose the expanded UI through
                // various regions, like leading/trailing/center/bottom
                DynamicIslandExpandedRegion(.leading) {
                    Text("Leading")
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text("Trailing")
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text("Bottom \(context.state.emoji)")
                    // more content
                }
            } compactLeading: {
                Text("L")
            } compactTrailing: {
                Text("T \(context.state.emoji)")
            } minimal: {
                Text(context.state.emoji)
            }
            .widgetURL(URL(string: "http://www.apple.com"))
            .keylineTint(Color.red)
        }
    }
}

extension HikmaWidgetAttributes {
    fileprivate static var preview: HikmaWidgetAttributes {
        HikmaWidgetAttributes(name: "World")
    }
}

extension HikmaWidgetAttributes.ContentState {
    fileprivate static var smiley: HikmaWidgetAttributes.ContentState {
        HikmaWidgetAttributes.ContentState(emoji: "😀")
     }
     
     fileprivate static var starEyes: HikmaWidgetAttributes.ContentState {
         HikmaWidgetAttributes.ContentState(emoji: "🤩")
     }
}

#Preview("Notification", as: .content, using: HikmaWidgetAttributes.preview) {
   HikmaWidgetLiveActivity()
} contentStates: {
    HikmaWidgetAttributes.ContentState.smiley
    HikmaWidgetAttributes.ContentState.starEyes
}
