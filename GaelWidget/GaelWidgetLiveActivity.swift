//
//  GaelWidgetLiveActivity.swift
//  GaelWidget
//
//  Created by Benjamin Oertel on 10/20/23.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct GaelWidgetAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var emoji: String
    }

    // Fixed non-changing properties about your activity go here!
    var name: String
}

struct GaelWidgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: GaelWidgetAttributes.self) { context in
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

extension GaelWidgetAttributes {
    fileprivate static var preview: GaelWidgetAttributes {
        GaelWidgetAttributes(name: "World")
    }
}

extension GaelWidgetAttributes.ContentState {
    fileprivate static var smiley: GaelWidgetAttributes.ContentState {
        GaelWidgetAttributes.ContentState(emoji: "😀")
     }
     
     fileprivate static var starEyes: GaelWidgetAttributes.ContentState {
         GaelWidgetAttributes.ContentState(emoji: "🤩")
     }
}

#Preview("Notification", as: .content, using: GaelWidgetAttributes.preview) {
   GaelWidgetLiveActivity()
} contentStates: {
    GaelWidgetAttributes.ContentState.smiley
    GaelWidgetAttributes.ContentState.starEyes
}
