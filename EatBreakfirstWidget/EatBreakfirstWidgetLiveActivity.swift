//
//  EatBreakfirstWidgetLiveActivity.swift
//  EatBreakfirstWidget
//
//  Created by Sheng Ma on 3/7/25.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct EatBreakfirstWidgetAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var emoji: String
    }

    // Fixed non-changing properties about your activity go here!
    var name: String
}

struct EatBreakfirstWidgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: EatBreakfirstWidgetAttributes.self) { context in
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

extension EatBreakfirstWidgetAttributes {
    fileprivate static var preview: EatBreakfirstWidgetAttributes {
        EatBreakfirstWidgetAttributes(name: "World")
    }
}

extension EatBreakfirstWidgetAttributes.ContentState {
    fileprivate static var smiley: EatBreakfirstWidgetAttributes.ContentState {
        EatBreakfirstWidgetAttributes.ContentState(emoji: "😀")
     }
     
     fileprivate static var starEyes: EatBreakfirstWidgetAttributes.ContentState {
         EatBreakfirstWidgetAttributes.ContentState(emoji: "🤩")
     }
}

#Preview("Notification", as: .content, using: EatBreakfirstWidgetAttributes.preview) {
   EatBreakfirstWidgetLiveActivity()
} contentStates: {
    EatBreakfirstWidgetAttributes.ContentState.smiley
    EatBreakfirstWidgetAttributes.ContentState.starEyes
}
